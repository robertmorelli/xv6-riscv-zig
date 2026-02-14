
const NOFILE: u64 = 16;
const PGSIZE: u64 = 4096;
const MAXVA: u64 = (@as(u64, 1) << 38);
const TRAPFRAME: u64 = MAXVA - PGSIZE * 2;
const SBRK_EAGER: i32 = 1;

const Context = extern struct {
    ra: u64,
    sp: u64,
    s0: u64,
    s1: u64,
    s2: u64,
    s3: u64,
    s4: u64,
    s5: u64,
    s6: u64,
    s7: u64,
    s8: u64,
    s9: u64,
    s10: u64,
    s11: u64,
};

const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Proc = extern struct {
    lock: Spinlock,
    state: i32,
    chan: ?*anyopaque,
    killed: i32,
    xstate: i32,
    pid: i32,
    parent: ?*Proc,
    kstack: u64,
    sz: u64,
    pagetable: ?*anyopaque,
    trapframe: ?*anyopaque,
    context: Context,
    ofile: [NOFILE]?*anyopaque,
    cwd: ?*anyopaque,
    name: [16]u8,
};

extern fn argint(n: i32, ip: *i32) void;
extern fn argaddr(n: i32, ip: *u64) void;
extern fn kexit(status: i32) void;
extern fn myproc() *Proc;
extern fn kfork() i32;
extern fn kwait(status_addr: u64) i32;
extern fn growproc(n: i32) i32;
extern fn acquire(lk: *Spinlock) void;
extern fn release(lk: *Spinlock) void;
extern fn killed(p: *Proc) i32;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) void;
extern fn kkill(pid: i32) i32;

extern var ticks: u32;
extern var tickslock: Spinlock;

pub export fn sys_exit() u64 {
    var n: i32 = 0;
    argint(0, &n);
    kexit(n);
    return 0;
}

pub export fn sys_getpid() u64 {
    return @intCast(myproc().pid);
}

pub export fn sys_fork() u64 {
    return @intCast(kfork());
}

pub export fn sys_wait() u64 {
    var p: u64 = 0;
    argaddr(0, &p);
    return @intCast(kwait(p));
}

pub export fn sys_sbrk() u64 {
    var n: i32 = 0;
    var t: i32 = 0;
    argint(0, &n);
    argint(1, &t);

    const p = myproc();
    const addr = p.sz;

    if (t == SBRK_EAGER or n < 0) {
        if (growproc(n) < 0) {
            return ~@as(u64, 0);
        }
    } else {
        const n_u64: u64 = @intCast(@as(u32, @intCast(n)));
        if (addr + n_u64 < addr) {
            return ~@as(u64, 0);
        }
        if (addr + n_u64 > TRAPFRAME) {
            return ~@as(u64, 0);
        }
        p.sz += n_u64;
    }

    return addr;
}

pub export fn sys_pause() u64 {
    var n: i32 = 0;
    argint(0, &n);
    if (n < 0) {
        n = 0;
    }

    acquire(&tickslock);
    const ticks0 = ticks;
    while (ticks - ticks0 < @as(u32, @intCast(n))) {
        if (killed(myproc()) != 0) {
            release(&tickslock);
            return ~@as(u64, 0);
        }
        sleep(@ptrCast(&ticks), &tickslock);
    }
    release(&tickslock);
    return 0;
}

pub export fn sys_kill() u64 {
    var pid: i32 = 0;
    argint(0, &pid);
    return @intCast(kkill(pid));
}

pub export fn sys_uptime() u64 {
    acquire(&tickslock);
    const xticks = ticks;
    release(&tickslock);
    return xticks;
}
