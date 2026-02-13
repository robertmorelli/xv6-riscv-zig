const std = @import("std");

const cint = i32;
const cuint = u32;

const NDEV: usize = 10;
const NFILE: usize = 100;
const MAXOPBLOCKS: cint = 10;
const BSIZE: cint = 1024;

const FD_NONE: cint = 0;
const FD_PIPE: cint = 1;
const FD_INODE: cint = 2;
const FD_DEVICE: cint = 3;

const Spinlock = extern struct {
    locked: cuint,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const File = extern struct {
    type: cint,
    ref: cint,
    readable: u8,
    writable: u8,
    pipe: ?*anyopaque,
    ip: ?*anyopaque,
    off: cuint,
    major: i16,
};

const Devsw = extern struct {
    read: ?*const fn (cint, u64, cint) callconv(.c) cint,
    write: ?*const fn (cint, u64, cint) callconv(.c) cint,
};

const Stat = extern struct {
    dev: cint,
    ino: cuint,
    type: i16,
    nlink: i16,
    size: u64,
};

const Proc = extern struct {
    lock: Spinlock,
    state: cint,
    chan: ?*anyopaque,
    killed: cint,
    xstate: cint,
    pid: cint,
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

extern fn initlock(lk: *Spinlock, name: [*c]u8) callconv(.c) void;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;
extern fn panic(s: [*c]const u8) callconv(.c) noreturn;
extern fn pipeclose(pi: ?*anyopaque, writable: cint) callconv(.c) void;
extern fn begin_op() callconv(.c) void;
extern fn iput(ip: ?*anyopaque) callconv(.c) void;
extern fn end_op() callconv(.c) void;
extern fn myproc() callconv(.c) *Proc;
extern fn ilock(ip: ?*anyopaque) callconv(.c) void;
extern fn stati(ip: ?*anyopaque, st: *Stat) callconv(.c) void;
extern fn iunlock(ip: ?*anyopaque) callconv(.c) void;
extern fn copyout(pagetable: ?*anyopaque, dstva: u64, src: [*c]u8, len: u64) callconv(.c) cint;
extern fn piperead(pi: ?*anyopaque, addr: u64, n: cint) callconv(.c) cint;
extern fn readi(ip: ?*anyopaque, user_dst: cint, dst: u64, off: cuint, n: cuint) callconv(.c) cint;
extern fn pipewrite(pi: ?*anyopaque, addr: u64, n: cint) callconv(.c) cint;
extern fn writei(ip: ?*anyopaque, user_src: cint, src: u64, off: cuint, n: cuint) callconv(.c) cint;

pub export fn fileinit() void {
    initlock(&ftable.lock, @constCast("ftable"));
}

pub export fn filealloc() ?*File {
    acquire(&ftable.lock);
    var i: usize = 0;
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

pub export fn filestat(f: *File, addr: u64) cint {
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

pub export fn fileread(f: *File, addr: u64, n: cint) cint {
    var r: cint = 0;

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
        r = readi(f.ip, 1, addr, f.off, @intCast(@as(cuint, @intCast(n))));
        if (r > 0) {
            f.off += @intCast(@as(cuint, @intCast(r)));
        }
        iunlock(f.ip);
    } else {
        panic("fileread");
    }

    return r;
}

pub export fn filewrite(f: *File, addr: u64, n: cint) cint {
    var r: cint = 0;
    var ret: cint = 0;

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
        const max: cint = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
        var i: cint = 0;
        while (i < n) {
            var n1 = n - i;
            if (n1 > max) {
                n1 = max;
            }

            begin_op();
            ilock(f.ip);
            r = writei(f.ip, 1, addr + @as(u64, @intCast(@as(cuint, @intCast(i)))), f.off, @intCast(@as(cuint, @intCast(n1))));
            if (r > 0) {
                f.off += @intCast(@as(cuint, @intCast(r)));
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
