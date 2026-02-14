const std = @import("std");


const NDEV: u64 = 10;
const NFILE: u64 = 100;
const MAXOPBLOCKS: i32 = 10;
const BSIZE: i32 = 1024;

const FD_NONE: i32 = 0;
const FD_PIPE: i32 = 1;
const FD_INODE: i32 = 2;
const FD_DEVICE: i32 = 3;

const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const File = extern struct {
    type: i32,
    ref: i32,
    readable: u8,
    writable: u8,
    pipe: ?*anyopaque,
    ip: ?*anyopaque,
    off: u32,
    major: i16,
};

const Devsw = extern struct {
    read: ?*const fn (i32, u64, i32) callconv(.c) i32,
    write: ?*const fn (i32, u64, i32) callconv(.c) i32,
};

const Stat = extern struct {
    dev: i32,
    ino: u32,
    type: i16,
    nlink: i16,
    size: u64,
};

const Proc = extern struct {
    lock: Spinlock,
    state: i32,
    chan: ?*anyopaque,
    killed: i32,
    xstate: i32,
    pid: i32,
    parent: ?*anyopaque,
    kstack: u64,
    sz: u64,
    pagetable: ?*anyopaque,
};

const FileTable = extern struct {
    lock: Spinlock,
    file: [NFILE]File,
};

pub export var devsw: [NDEV]Devsw = [_]Devsw{.{ .read = null, .write = null }} ** NDEV;
var ftable: FileTable = std.mem.zeroes(FileTable);

extern fn initlock(lk: *Spinlock, name: [*c]u8) void;
extern fn acquire(lk: *Spinlock) void;
extern fn release(lk: *Spinlock) void;
extern fn panic(s: [*c]const u8) noreturn;
extern fn pipeclose(pi: ?*anyopaque, writable: i32) void;
extern fn begin_op() void;
extern fn iput(ip: ?*anyopaque) void;
extern fn end_op() void;
extern fn myproc() *Proc;
extern fn ilock(ip: ?*anyopaque) void;
extern fn stati(ip: ?*anyopaque, st: *Stat) void;
extern fn iunlock(ip: ?*anyopaque) void;
extern fn copyout(pagetable: ?*anyopaque, dstva: u64, src: [*c]u8, len: u64) i32;
extern fn piperead(pi: ?*anyopaque, addr: u64, n: i32) i32;
extern fn readi(ip: ?*anyopaque, user_dst: i32, dst: u64, off: u32, n: u32) i32;
extern fn pipewrite(pi: ?*anyopaque, addr: u64, n: i32) i32;
extern fn writei(ip: ?*anyopaque, user_src: i32, src: u64, off: u32, n: u32) i32;

pub export fn fileinit() void {
    initlock(&ftable.lock, @constCast("ftable"));
}

pub export fn filealloc() ?*File {
    acquire(&ftable.lock);
    var i: u64 = 0;
    while (i < NFILE) : (i += 1) {
        if (ftable.file[i].ref == 0) {
            ftable.file[i].ref = 1;
            release(&ftable.lock);
            return &ftable.file[i];
        }
    }
    release(&ftable.lock);
    return null;
}

pub export fn filedup(f: *File) *File {
    acquire(&ftable.lock);
    if (f.ref < 1) {
        panic("filedup");
    }
    f.ref += 1;
    release(&ftable.lock);
    return f;
}

pub export fn fileclose(f: *File) void {
    var ff: File = undefined;

    acquire(&ftable.lock);
    if (f.ref < 1) {
        panic("fileclose");
    }
    f.ref -= 1;
    if (f.ref > 0) {
        release(&ftable.lock);
        return;
    }
    ff = f.*;
    f.ref = 0;
    f.type = FD_NONE;
    release(&ftable.lock);

    if (ff.type == FD_PIPE) {
        pipeclose(ff.pipe, @intCast(ff.writable));
    } else if (ff.type == FD_INODE or ff.type == FD_DEVICE) {
        begin_op();
        iput(ff.ip);
        end_op();
    }
}

pub export fn filestat(f: *File, addr: u64) i32 {
    const p = myproc();
    var st: Stat = undefined;

    if (f.type == FD_INODE or f.type == FD_DEVICE) {
        ilock(f.ip);
        stati(f.ip, &st);
        iunlock(f.ip);
        if (copyout(p.pagetable, addr, @ptrCast(&st), @sizeOf(Stat)) < 0) {
            return -1;
        }
        return 0;
    }
    return -1;
}

pub export fn fileread(f: *File, addr: u64, n: i32) i32 {
    var r: i32 = 0;

    if (f.readable == 0) {
        return -1;
    }

    if (f.type == FD_PIPE) {
        r = piperead(f.pipe, addr, n);
    } else if (f.type == FD_DEVICE) {
        if (f.major < 0 or f.major >= NDEV or devsw[@intCast(f.major)].read == null) {
            return -1;
        }
        r = devsw[@intCast(f.major)].read.?(1, addr, n);
    } else if (f.type == FD_INODE) {
        ilock(f.ip);
        r = readi(f.ip, 1, addr, f.off, @intCast(@as(u32, @intCast(n))));
        if (r > 0) {
            f.off += @intCast(@as(u32, @intCast(r)));
        }
        iunlock(f.ip);
    } else {
        panic("fileread");
    }

    return r;
}

pub export fn filewrite(f: *File, addr: u64, n: i32) i32 {
    var r: i32 = 0;
    var ret: i32 = 0;

    if (f.writable == 0) {
        return -1;
    }

    if (f.type == FD_PIPE) {
        ret = pipewrite(f.pipe, addr, n);
    } else if (f.type == FD_DEVICE) {
        if (f.major < 0 or f.major >= NDEV or devsw[@intCast(f.major)].write == null) {
            return -1;
        }
        ret = devsw[@intCast(f.major)].write.?(1, addr, n);
    } else if (f.type == FD_INODE) {
        const max: i32 = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
        var i: i32 = 0;
        while (i < n) {
            var n1 = n - i;
            if (n1 > max) {
                n1 = max;
            }

            begin_op();
            ilock(f.ip);
            r = writei(f.ip, 1, addr + @as(u64, @intCast(@as(u32, @intCast(i)))), f.off, @intCast(@as(u32, @intCast(n1))));
            if (r > 0) {
                f.off += @intCast(@as(u32, @intCast(r)));
            }
            iunlock(f.ip);
            end_op();

            if (r != n1) {
                break;
            }
            i += r;
        }
        ret = if (i == n) n else -1;
    } else {
        panic("filewrite");
    }

    return ret;
}
