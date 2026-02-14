const std = @import("std");


const NCPU: u64 = 8;
const NPROC: u64 = 64;
const NOFILE: u64 = 16;
const PGSIZE: u64 = 4096;
const PTE_R: u32 = 0x002;
const PTE_W: u32 = 0x004;
const PTE_X: u32 = 0x008;
const PTE_U: u32 = 0x010;
const MAXVA: u64 = (@as(u64, 1) << 38);
const TRAMPOLINE: u64 = MAXVA - PGSIZE;
const TRAPFRAME: u64 = TRAMPOLINE - PGSIZE;
const ROOTDEV: i32 = 1;

const UNUSED: i32 = 0;
const USED: i32 = 1;
const SLEEPING: i32 = 2;
const RUNNABLE: i32 = 3;
const RUNNING: i32 = 4;
const ZOMBIE: i32 = 5;

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

const Cpu = extern struct {
    proc: ?*Proc,
    context: Context,
    noff: i32,
    intena: i32,
};

const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*Cpu,
};

const Trapframe = extern struct {
    kernel_satp: u64,
    kernel_sp: u64,
    kernel_trap: u64,
    epc: u64,
    kernel_hartid: u64,
    ra: u64,
    sp: u64,
    gp: u64,
    tp: u64,
    t0: u64,
    t1: u64,
    t2: u64,
    s0: u64,
    s1: u64,
    a0: u64,
    a1: u64,
    a2: u64,
    a3: u64,
    a4: u64,
    a5: u64,
    a6: u64,
    a7: u64,
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
    t3: u64,
    t4: u64,
    t5: u64,
    t6: u64,
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
    pagetable: [*c]u64,
    trapframe: ?*Trapframe,
    context: Context,
    ofile: [NOFILE]?*anyopaque,
    cwd: ?*anyopaque,
    name: [16]u8,
};

pub export var cpus: [NCPU]Cpu = std.mem.zeroes([NCPU]Cpu);
pub export var proc: [NPROC]Proc = std.mem.zeroes([NPROC]Proc);
pub export var initproc: ?*Proc = null;

var nextpid: i32 = 1;
var pid_lock: Spinlock = std.mem.zeroes(Spinlock);
var wait_lock: Spinlock = std.mem.zeroes(Spinlock);
var forkret_first: i32 = 1;

extern var trampoline: u8;
extern var userret: u8;

extern fn kalloc() ?*anyopaque;
extern fn kfree(pa: ?*anyopaque) void;
extern fn panic(s: [*c]const u8) noreturn;
extern fn kvmmap(kpgtbl: [*c]u64, va: u64, pa: u64, sz: u64, perm: i32) void;
extern fn initlock(lk: *Spinlock, name: [*c]u8) void;
extern fn acquire(lk: *Spinlock) void;
extern fn release(lk: *Spinlock) void;
extern fn push_off() void;
extern fn pop_off() void;
extern fn memset(dst: ?*anyopaque, c: i32, n: u32) ?*anyopaque;
extern fn memmove(dst: ?*anyopaque, src: ?*const anyopaque, n: u32) ?*anyopaque;
extern fn uvmcreate() [*c]u64;
extern fn mappages(pagetable: [*c]u64, va: u64, size: u64, pa: u64, perm: i32) i32;
extern fn uvmfree(pagetable: [*c]u64, sz: u64) void;
extern fn uvmunmap(pagetable: [*c]u64, va: u64, npages: u64, do_free: i32) void;
extern fn uvmalloc(pagetable: [*c]u64, oldsz: u64, newsz: u64, xperm: i32) u64;
extern fn uvmdealloc(pagetable: [*c]u64, oldsz: u64, newsz: u64) u64;
extern fn uvmcopy(old: [*c]u64, new: [*c]u64, sz: u64) i32;
extern fn namei(path: [*c]u8) ?*anyopaque;
extern fn filedup(f: ?*anyopaque) ?*anyopaque;
extern fn idup(ip: ?*anyopaque) ?*anyopaque;
extern fn safestrcpy(dst: [*c]u8, src: [*c]const u8, n: i32) [*c]u8;
extern fn fileclose(f: ?*anyopaque) void;
extern fn begin_op() void;
extern fn iput(ip: ?*anyopaque) void;
extern fn end_op() void;
extern fn copyout(pagetable: [*c]u64, dstva: u64, src: [*c]u8, len: u64) i32;
extern fn swtch(old: *Context, new: *Context) void;
extern fn holding(lk: *Spinlock) i32;
extern fn fsinit(dev: i32) void;
extern fn kexec(path: [*c]u8, argv: [*c][*c]u8) i32;
extern fn prepare_return() void;
extern fn copyin(pagetable: [*c]u64, dst: [*c]u8, srcva: u64, len: u64) i32;
extern fn printf(fmt: [*c]const u8, ...) i32;
extern fn consputc(c: i32) void;

inline fn kstack(idx: u64) u64 {
    return TRAMPOLINE - (@as(u64, @intCast(idx)) + 1) * 2 * PGSIZE;
}

inline fn r_tp() u64 {
    return asm volatile ("mv %[result], tp"
        : [result] "=r" (-> u64),
    );
}

inline fn r_sstatus() u64 {
    return asm volatile ("csrr %[result], sstatus"
        : [result] "=r" (-> u64),
    );
}

inline fn w_sstatus(x: u64) void {
    asm volatile ("csrw sstatus, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn intr_on() void {
    w_sstatus(r_sstatus() | (@as(u64, 1) << 1));
}

inline fn intr_off() void {
    w_sstatus(r_sstatus() & ~(@as(u64, 1) << 1));
}

inline fn intr_get() i32 {
    return if ((r_sstatus() & (@as(u64, 1) << 1)) != 0) 1 else 0;
}

inline fn sync_synchronize() void {
    asm volatile ("fence rw, rw");
}

fn freeproc(p: *Proc) void {
    if (p.trapframe != null) {
        kfree(p.trapframe);
    }
    p.trapframe = null;
    if (p.pagetable != @as([*c]u64, @ptrFromInt(0))) {
        proc_freepagetable(p.pagetable, p.sz);
    }
    p.pagetable = @ptrFromInt(0);
    p.sz = 0;
    p.pid = 0;
    p.parent = null;
    p.name[0] = 0;
    p.chan = null;
    p.killed = 0;
    p.xstate = 0;
    p.state = UNUSED;
}

fn allocproc() ?*Proc {
    var i: u64 = 0;
    while (i < NPROC) : (i += 1) {
        const p = &proc[i];
        acquire(&p.lock);
        if (p.state == UNUSED) {
            p.pid = allocpid();
            p.state = USED;

            const tf = kalloc();
            if (tf == null) {
                freeproc(p);
                release(&p.lock);
                return null;
            }
            p.trapframe = @ptrCast(@alignCast(tf.?));

            p.pagetable = proc_pagetable(p);
            if (p.pagetable == @as([*c]u64, @ptrFromInt(0))) {
                freeproc(p);
                release(&p.lock);
                return null;
            }

            _ = memset(&p.context, 0, @sizeOf(Context));
            p.context.ra = @intFromPtr(&forkret);
            p.context.sp = p.kstack + PGSIZE;
            return p;
        }
        release(&p.lock);
    }
    return null;
}

pub export fn proc_mapstacks(kpgtbl: [*c]u64) void {
    var i: u64 = 0;
    while (i < NPROC) : (i += 1) {
        const pa = kalloc();
        if (pa == null) {
            panic("kalloc");
        }
        const va = kstack(i);
        kvmmap(kpgtbl, va, @intFromPtr(pa.?), PGSIZE, @intCast(PTE_R | PTE_W));
    }
}

pub export fn procinit() void {
    initlock(&pid_lock, @constCast("nextpid"));
    initlock(&wait_lock, @constCast("wait_lock"));

    var i: u64 = 0;
    while (i < NPROC) : (i += 1) {
        const p = &proc[i];
        initlock(&p.lock, @constCast("proc"));
        p.state = UNUSED;
        p.kstack = kstack(i);
    }
}

pub export fn cpuid() i32 {
    return @intCast(r_tp());
}

pub export fn mycpu() *Cpu {
    const id: u64 = @intCast(@as(u32, @intCast(cpuid())));
    return &cpus[id];
}

pub export fn myproc() ?*Proc {
    push_off();
    const p = mycpu().proc;
    pop_off();
    return p;
}

pub export fn allocpid() i32 {
    acquire(&pid_lock);
    const pid = nextpid;
    nextpid += 1;
    release(&pid_lock);
    return pid;
}

pub export fn proc_pagetable(p: *Proc) [*c]u64 {
    const pagetable = uvmcreate();
    if (pagetable == @as([*c]u64, @ptrFromInt(0))) {
        return @ptrFromInt(0);
    }

    if (mappages(pagetable, TRAMPOLINE, PGSIZE, @intFromPtr(&trampoline), @intCast(PTE_R | PTE_X)) < 0) {
        uvmfree(pagetable, 0);
        return @ptrFromInt(0);
    }

    if (mappages(pagetable, TRAPFRAME, PGSIZE, @intFromPtr(p.trapframe), @intCast(PTE_R | PTE_W)) < 0) {
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
        uvmfree(pagetable, 0);
        return @ptrFromInt(0);
    }

    return pagetable;
}

pub export fn proc_freepagetable(pagetable: [*c]u64, sz: u64) void {
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    uvmfree(pagetable, sz);
}

pub export fn userinit() void {
    const p = allocproc().?;
    initproc = p;
    p.cwd = namei(@constCast("/"));
    p.state = RUNNABLE;
    release(&p.lock);
}

pub export fn growproc(n: i32) i32 {
    const p = myproc().?;
    var sz = p.sz;

    if (n > 0) {
        const n_u64: u64 = @intCast(@as(u32, @intCast(n)));
        if (sz + n_u64 > TRAPFRAME) {
            return -1;
        }
        sz = uvmalloc(p.pagetable, sz, sz + n_u64, @intCast(PTE_W));
        if (sz == 0) {
            return -1;
        }
    } else if (n < 0) {
        sz = uvmdealloc(p.pagetable, sz, sz +% @as(u64, @bitCast(@as(i64, n))));
    }

    p.sz = sz;
    return 0;
}

pub export fn kfork() i32 {
    const p = myproc().?;
    const np = allocproc() orelse return -1;

    if (uvmcopy(p.pagetable, np.pagetable, p.sz) < 0) {
        freeproc(np);
        release(&np.lock);
        return -1;
    }
    np.sz = p.sz;
    np.trapframe.?.* = p.trapframe.?.*;
    np.trapframe.?.a0 = 0;

    var i: u64 = 0;
    while (i < NOFILE) : (i += 1) {
        if (p.ofile[i] != null) {
            np.ofile[i] = filedup(p.ofile[i]);
        }
    }
    np.cwd = idup(p.cwd);
    _ = safestrcpy(@ptrCast(&np.name), @ptrCast(&p.name), np.name.len);

    const pid = np.pid;

    release(&np.lock);
    acquire(&wait_lock);
    np.parent = p;
    release(&wait_lock);

    acquire(&np.lock);
    np.state = RUNNABLE;
    release(&np.lock);

    return pid;
}

fn reparent(p: *Proc) void {
    var i: u64 = 0;
    while (i < NPROC) : (i += 1) {
        const pp = &proc[i];
        if (pp.parent == p) {
            pp.parent = initproc;
            wakeup(initproc);
        }
    }
}

pub export fn kexit(status: i32) void {
    const p = myproc().?;

    if (p == initproc) {
        panic("init exiting");
    }

    var fd: u64 = 0;
    while (fd < NOFILE) : (fd += 1) {
        if (p.ofile[fd] != null) {
            const f = p.ofile[fd];
            fileclose(f);
            p.ofile[fd] = null;
        }
    }

    begin_op();
    iput(p.cwd);
    end_op();
    p.cwd = null;

    acquire(&wait_lock);
    reparent(p);
    wakeup(p.parent);

    acquire(&p.lock);
    p.xstate = status;
    p.state = ZOMBIE;
    release(&wait_lock);

    sched();
    panic("zombie exit");
}

pub export fn kwait(addr: u64) i32 {
    const p = myproc().?;

    acquire(&wait_lock);
    while (true) {
        var havekids: i32 = 0;
        var i: u64 = 0;
        while (i < NPROC) : (i += 1) {
            const pp = &proc[i];
            if (pp.parent == p) {
                acquire(&pp.lock);
                havekids = 1;
                if (pp.state == ZOMBIE) {
                    const pid = pp.pid;
                    if (addr != 0 and copyout(p.pagetable, addr, @ptrCast(&pp.xstate), @sizeOf(i32)) < 0) {
                        release(&pp.lock);
                        release(&wait_lock);
                        return -1;
                    }
                    freeproc(pp);
                    release(&pp.lock);
                    release(&wait_lock);
                    return pid;
                }
                release(&pp.lock);
            }
        }

        if (havekids == 0 or killed(p) != 0) {
            release(&wait_lock);
            return -1;
        }

        sleep(p, &wait_lock);
    }
}

pub export fn scheduler() noreturn {
    const c = mycpu();
    c.proc = null;

    while (true) {
        intr_on();
        intr_off();

        var found: i32 = 0;
        var i: u64 = 0;
        while (i < NPROC) : (i += 1) {
            const p = &proc[i];
            acquire(&p.lock);
            if (p.state == RUNNABLE) {
                p.state = RUNNING;
                c.proc = p;
                swtch(&c.context, &p.context);
                c.proc = null;
                found = 1;
            }
            release(&p.lock);
        }

        if (found == 0) {
            asm volatile ("wfi");
        }
    }
}

pub export fn sched() void {
    const p = myproc().?;
    if (holding(&p.lock) == 0) {
        panic("sched p->lock");
    }
    if (mycpu().noff != 1) {
        panic("sched locks");
    }
    if (p.state == RUNNING) {
        panic("sched RUNNING");
    }
    if (intr_get() != 0) {
        panic("sched interruptible");
    }

    const c = mycpu();
    const intena = c.intena;
    swtch(&p.context, &c.context);
    c.intena = intena;
}

pub export fn yield() void {
    const p = myproc().?;
    acquire(&p.lock);
    p.state = RUNNABLE;
    sched();
    release(&p.lock);
}

pub export fn forkret() void {
    const p = myproc().?;

    release(&p.lock);

    if (forkret_first != 0) {
        fsinit(ROOTDEV);
        forkret_first = 0;
        sync_synchronize();

        var argv = [_][*c]u8{ @constCast("/init"), null };
        const ret = kexec(@constCast("/init"), @ptrCast(&argv));
        p.trapframe.?.a0 = @bitCast(@as(i64, ret));
        if (p.trapframe.?.a0 == ~@as(u64, 0)) {
            panic("exec");
        }
    }

    prepare_return();
    const satp = (@as(u64, 8) << 60) | (@as(u64, @intCast(@intFromPtr(p.pagetable))) >> 12);
    const trampoline_userret = TRAMPOLINE + @as(u64, @intCast(@intFromPtr(&userret) - @intFromPtr(&trampoline)));
    const fn_userret: *const fn (u64) callconv(.c) void = @ptrFromInt(trampoline_userret);
    fn_userret(satp);
}

pub export fn sleep(chan: ?*anyopaque, lk: *Spinlock) void {
    const p = myproc().?;

    acquire(&p.lock);
    release(lk);

    p.chan = chan;
    p.state = SLEEPING;
    sched();

    p.chan = null;
    release(&p.lock);
    acquire(lk);
}

pub export fn wakeup(chan: ?*anyopaque) void {
    const self = myproc();
    var i: u64 = 0;
    while (i < NPROC) : (i += 1) {
        const p = &proc[i];
        if (self == null or p != self.?) {
            acquire(&p.lock);
            if (p.state == SLEEPING and p.chan == chan) {
                p.state = RUNNABLE;
            }
            release(&p.lock);
        }
    }
}

pub export fn kkill(pid: i32) i32 {
    var i: u64 = 0;
    while (i < NPROC) : (i += 1) {
        const p = &proc[i];
        acquire(&p.lock);
        if (p.pid == pid) {
            p.killed = 1;
            if (p.state == SLEEPING) {
                p.state = RUNNABLE;
            }
            release(&p.lock);
            return 0;
        }
        release(&p.lock);
    }
    return -1;
}

pub export fn setkilled(p: *Proc) void {
    acquire(&p.lock);
    p.killed = 1;
    release(&p.lock);
}

pub export fn killed(p: *Proc) i32 {
    acquire(&p.lock);
    const k = p.killed;
    release(&p.lock);
    return k;
}

pub export fn either_copyout(user_dst: i32, dst: u64, src: ?*anyopaque, len: u64) i32 {
    const p = myproc().?;
    if (user_dst != 0) {
        return copyout(p.pagetable, dst, @ptrCast(src), len);
    } else {
        _ = memmove(@ptrFromInt(dst), src, @intCast(len));
        return 0;
    }
}

pub export fn either_copyin(dst: ?*anyopaque, user_src: i32, src: u64, len: u64) i32 {
    const p = myproc().?;
    if (user_src != 0) {
        return copyin(p.pagetable, @ptrCast(dst), src, len);
    } else {
        _ = memmove(dst, @ptrFromInt(src), @intCast(len));
        return 0;
    }
}

pub export fn procdump() void {
    const states = [_]?[*c]const u8{
        "unused",
        "used",
        "sleep ",
        "runble",
        "run   ",
        "zombie",
    };

    consputc('\n');
    var i: u64 = 0;
    while (i < NPROC) : (i += 1) {
        const p = &proc[i];
        if (p.state == UNUSED) {
            continue;
        }

        const idx: u64 = if (p.state >= 0) @intCast(@as(u32, @intCast(p.state))) else states.len;
        const state: [*c]const u8 = if (idx < states.len and states[idx] != null) states[idx].? else "???";
        _ = printf("%d %s %s", p.pid, state, @as([*c]u8, @ptrCast(&p.name)));
        consputc('\n');
    }
}
