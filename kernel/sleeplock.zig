
const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Sleeplock = extern struct {
    locked: u32,
    lk: Spinlock,
    name: [*c]u8,
    pid: i32,
};

const Proc = extern struct {
    lock: Spinlock,
    state: i32,
    chan: ?*anyopaque,
    killed: i32,
    xstate: i32,
    pid: i32,
};

extern fn initlock(lk: *Spinlock, name: [*c]u8) void;
extern fn acquire(lk: *Spinlock) void;
extern fn release(lk: *Spinlock) void;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) void;
extern fn wakeup(chan: ?*anyopaque) void;
extern fn myproc() *Proc;

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

pub export fn holdingsleep(lk: *Sleeplock) i32 {
    acquire(&lk.lk);
    const held = lk.locked != 0 and lk.pid == myproc().pid;
    release(&lk.lk);
    return if (held) 1 else 0;
}
