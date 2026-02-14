
const PIPESIZE: u32 = 512;
const FD_PIPE: i32 = 1;

const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Pipe = extern struct {
    lock: Spinlock,
    data: [PIPESIZE]u8,
    nread: u32,
    nwrite: u32,
    readopen: i32,
    writeopen: i32,
};

const File = extern struct {
    type: i32,
    ref: i32,
    readable: u8,
    writable: u8,
    pipe: ?*Pipe,
    ip: ?*anyopaque,
    off: u32,
    major: i16,
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

extern fn filealloc() ?*File;
extern fn fileclose(f: *File) void;
extern fn kalloc() ?*anyopaque;
extern fn kfree(pa: ?*anyopaque) void;
extern fn initlock(lk: *Spinlock, name: [*c]u8) void;
extern fn acquire(lk: *Spinlock) void;
extern fn release(lk: *Spinlock) void;
extern fn wakeup(chan: ?*anyopaque) void;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) void;
extern fn myproc() *Proc;
extern fn killed(p: *Proc) i32;
extern fn copyin(pagetable: ?*anyopaque, dst: [*c]u8, srcva: u64, len: u64) i32;
extern fn copyout(pagetable: ?*anyopaque, dstva: u64, src: [*c]u8, len: u64) i32;

pub export fn pipealloc(f0: *?*File, f1: *?*File) i32 {
    var pi: ?*Pipe = null;
    f0.* = null;
    f1.* = null;

    f0.* = filealloc();
    if (f0.* == null) {
        gotoBad(&pi, f0, f1);
        return -1;
    }

    f1.* = filealloc();
    if (f1.* == null) {
        gotoBad(&pi, f0, f1);
        return -1;
    }

    const raw = kalloc();
    if (raw == null) {
        gotoBad(&pi, f0, f1);
        return -1;
    }
    pi = @alignCast(@ptrCast(raw.?));

    pi.?.readopen = 1;
    pi.?.writeopen = 1;
    pi.?.nwrite = 0;
    pi.?.nread = 0;
    initlock(&pi.?.lock, @constCast("pipe"));

    f0.*.?.type = FD_PIPE;
    f0.*.?.readable = 1;
    f0.*.?.writable = 0;
    f0.*.?.pipe = pi;

    f1.*.?.type = FD_PIPE;
    f1.*.?.readable = 0;
    f1.*.?.writable = 1;
    f1.*.?.pipe = pi;

    return 0;
}

fn gotoBad(pi: *?*Pipe, f0: *?*File, f1: *?*File) void {
    if (pi.* != null) {
        kfree(@ptrCast(pi.*.?));
    }
    if (f0.* != null) {
        fileclose(f0.*.?);
    }
    if (f1.* != null) {
        fileclose(f1.*.?);
    }
}

pub export fn pipeclose(pi: *Pipe, writable: i32) void {
    acquire(&pi.lock);
    if (writable != 0) {
        pi.writeopen = 0;
        wakeup(@ptrCast(&pi.nread));
    } else {
        pi.readopen = 0;
        wakeup(@ptrCast(&pi.nwrite));
    }

    if (pi.readopen == 0 and pi.writeopen == 0) {
        release(&pi.lock);
        kfree(@ptrCast(pi));
    } else {
        release(&pi.lock);
    }
}

pub export fn pipewrite(pi: *Pipe, addr: u64, n: i32) i32 {
    var i: i32 = 0;
    const pr = myproc();

    acquire(&pi.lock);
    while (i < n) {
        if (pi.readopen == 0 or killed(pr) != 0) {
            release(&pi.lock);
            return -1;
        }

        if (pi.nwrite == pi.nread + PIPESIZE) {
            wakeup(@ptrCast(&pi.nread));
            sleep(@ptrCast(&pi.nwrite), &pi.lock);
        } else {
            var ch: u8 = 0;
            const i_u64: u64 = @intCast(@as(u32, @intCast(i)));
            if (copyin(pr.pagetable, @ptrCast(&ch), addr + i_u64, 1) == -1) {
                break;
            }
            const idx: u64 = @intCast(pi.nwrite % PIPESIZE);
            pi.data[idx] = ch;
            pi.nwrite +%= 1;
            i += 1;
        }
    }
    wakeup(@ptrCast(&pi.nread));
    release(&pi.lock);
    return i;
}

pub export fn piperead(pi: *Pipe, addr: u64, n: i32) i32 {
    var i: i32 = 0;
    const pr = myproc();
    var ch: u8 = 0;

    acquire(&pi.lock);
    while (pi.nread == pi.nwrite and pi.writeopen != 0) {
        if (killed(pr) != 0) {
            release(&pi.lock);
            return -1;
        }
        sleep(@ptrCast(&pi.nread), &pi.lock);
    }

    while (i < n) {
        if (pi.nread == pi.nwrite) {
            break;
        }
        ch = pi.data[@intCast(pi.nread % PIPESIZE)];
        const i_u64: u64 = @intCast(@as(u32, @intCast(i)));
        if (copyout(pr.pagetable, addr + i_u64, @ptrCast(&ch), 1) == -1) {
            if (i == 0) {
                i = -1;
            }
            break;
        }
        pi.nread +%= 1;
        i += 1;
    }

    wakeup(@ptrCast(&pi.nwrite));
    release(&pi.lock);
    return i;
}
