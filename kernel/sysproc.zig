const cint = i32;
const cuint = u32;

const NOFILE: usize = 16;
const PGSIZE: u64 = 4096;
const MAXVA: u64 = (@as(u64, 1) << 38);
const TRAPFRAME: u64 = MAXVA - PGSIZE * 2;
const SBRK_EAGER: cint = 1;

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
    locked: cuint,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Proc = extern struct {
    lock: Spinlock,
    state: cint,
    chan: ?*anyopaque,
    killed: cint,
    xstate: cint,
    pid: cint,
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

extern fn argint(n: cint, ip: *cint) callconv(.c) void;
extern fn argaddr(n: cint, ip: *u64) callconv(.c) void;
extern fn kexit(status: cint) callconv(.c) void;
extern fn myproc() callconv(.c) *Proc;
extern fn kfork() callconv(.c) cint;
extern fn kwait(status_addr: u64) callconv(.c) cint;
extern fn growproc(n: cint) callconv(.c) cint;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;
extern fn killed(p: *Proc) callconv(.c) cint;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) callconv(.c) void;
extern fn kkill(pid: cint) callconv(.c) cint;

extern var ticks: cuint;
extern var tickslock: Spinlock;

pub export fn sys_exit() u64 {
    var n: cint = 0;
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
    var n: cint = 0;
    var t: cint = 0;
    argint(0, &n);
    argint(1, &t);

    const p = myproc();
    const addr = p.sz;

    if (t == SBRK_EAGER or n < 0) {
        if (growproc(n) < 0) {
            return ~@as(u64, 0);
        }
    } else {
        const n_u64: u64 = @intCast(@as(cuint, @intCast(n)));
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
    var n: cint = 0;
    argint(0, &n);
    if (n < 0) {
        n = 0;
    }

    acquire(&tickslock);
    const ticks0 = ticks;
    while (ticks - ticks0 < @as(cuint, @intCast(n))) {
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
    var pid: cint = 0;
    argint(0, &pid);
    return @intCast(kkill(pid));
}

pub export fn sys_uptime() u64 {
    acquire(&tickslock);
    const xticks = ticks;
    release(&tickslock);
    return xticks;
}
