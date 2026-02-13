const cint = i32;
const cuint = u32;

const Spinlock = extern struct {
    locked: cuint,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Sleeplock = extern struct {
    locked: cuint,
    lk: Spinlock,
    name: [*c]u8,
    pid: cint,
};

const Proc = extern struct {
    lock: Spinlock,
    state: cint,
    chan: ?*anyopaque,
    killed: cint,
    xstate: cint,
    pid: cint,
};

extern fn initlock(lk: *Spinlock, name: [*c]u8) callconv(.c) void;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) callconv(.c) void;
extern fn wakeup(chan: ?*anyopaque) callconv(.c) void;
extern fn myproc() callconv(.c) *Proc;

pub export fn initsleeplock(lk: *Sleeplock, name: [*c]u8) void {
    initlock(&lk.lk, @constCast("sleep lock"));
    lk.name = name;
    lk.locked = 0;
    lk.pid = 0;
}

pub export fn acquiresleep(lk: *Sleeplock) void {
    acquire(&lk.lk);
    while (lk.locked != 0) {
        sleep(@ptrCast(lk), &lk.lk);
    }
    lk.locked = 1;
    lk.pid = myproc().pid;
    release(&lk.lk);
}

pub export fn releasesleep(lk: *Sleeplock) void {
    acquire(&lk.lk);
    lk.locked = 0;
    lk.pid = 0;
    wakeup(@ptrCast(lk));
    release(&lk.lk);
}

pub export fn holdingsleep(lk: *Sleeplock) cint {
    acquire(&lk.lk);
    const held = lk.locked != 0 and lk.pid == myproc().pid;
    release(&lk.lk);
    return if (held) 1 else 0;
}
