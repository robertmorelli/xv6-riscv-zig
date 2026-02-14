
const NOFILE: u64 = 16;
const PGSIZE: u64 = 4096;
const MAXVA: u64 = (@as(u64, 1) << 38);
const TRAMPOLINE: u64 = MAXVA - PGSIZE;
const SATP_SV39: u64 = (@as(u64, 8) << 60);
const SSTATUS_SPP: u64 = (@as(u64, 1) << 8);
const SSTATUS_SPIE: u64 = (@as(u64, 1) << 5);
const SSTATUS_SIE: u64 = (@as(u64, 1) << 1);
const UART0_IRQ: i32 = 10;
const VIRTIO0_IRQ: i32 = 1;

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
    trapframe: ?*Trapframe,
    context: Context,
    ofile: [NOFILE]?*anyopaque,
    cwd: ?*anyopaque,
    name: [16]u8,
};

pub export var tickslock: Spinlock = .{
    .locked = 0,
    .name = null,
    .cpu = null,
};
pub export var ticks: u32 = 0;

extern var trampoline: u8;
extern var uservec: u8;

extern fn kernelvec() void;
extern fn initlock(lk: *Spinlock, name: [*c]u8) void;
extern fn panic(s: [*c]const u8) noreturn;
extern fn myproc() ?*Proc;
extern fn killed(p: *Proc) i32;
extern fn setkilled(p: *Proc) void;
extern fn kexit(status: i32) void;
extern fn yield() void;
extern fn syscall() void;
extern fn vmfault(pagetable: ?*anyopaque, va: u64, store: i32) u64;
extern fn printf(fmt: [*c]const u8, ...) i32;
extern fn cpuid() i32;
extern fn acquire(lk: *Spinlock) void;
extern fn wakeup(chan: ?*anyopaque) void;
extern fn release(lk: *Spinlock) void;
extern fn plic_claim() i32;
extern fn uartintr() void;
extern fn virtio_disk_intr() void;
extern fn plic_complete(irq: i32) void;

inline fn makeSatp(pagetable: *anyopaque) u64 {
    return SATP_SV39 | (@as(u64, @intCast(@intFromPtr(pagetable))) >> 12);
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
    w_sstatus(r_sstatus() | SSTATUS_SIE);
}

inline fn intr_off() void {
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
}

inline fn intr_get() i32 {
    return if ((r_sstatus() & SSTATUS_SIE) != 0) 1 else 0;
}

inline fn r_sepc() u64 {
    return asm volatile ("csrr %[result], sepc"
        : [result] "=r" (-> u64),
    );
}

inline fn w_sepc(x: u64) void {
    asm volatile ("csrw sepc, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn r_scause() u64 {
    return asm volatile ("csrr %[result], scause"
        : [result] "=r" (-> u64),
    );
}

inline fn r_stval() u64 {
    return asm volatile ("csrr %[result], stval"
        : [result] "=r" (-> u64),
    );
}

inline fn w_stvec(x: u64) void {
    asm volatile ("csrw stvec, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn r_satp() u64 {
    return asm volatile ("csrr %[result], satp"
        : [result] "=r" (-> u64),
    );
}

inline fn r_tp() u64 {
    return asm volatile ("mv %[result], tp"
        : [result] "=r" (-> u64),
    );
}

inline fn r_time() u64 {
    return asm volatile ("csrr %[result], time"
        : [result] "=r" (-> u64),
    );
}

inline fn w_stimecmp(x: u64) void {
    asm volatile ("csrw 0x14d, %[value]"
        :
        : [value] "r" (x),
    );
}

pub export fn trapinit() void {
    initlock(&tickslock, @constCast("time"));
}

pub export fn trapinithart() void {
    w_stvec(@intFromPtr(&kernelvec));
}

pub export fn usertrap() u64 {
    var which_dev: i32 = 0;

    if ((r_sstatus() & SSTATUS_SPP) != 0) {
        panic("usertrap: not from user mode");
    }

    w_stvec(@intFromPtr(&kernelvec));

    const p = myproc().?;
    const tf = p.trapframe.?;
    tf.epc = r_sepc();

    const scause = r_scause();
    if (scause == 8) {
        if (killed(p) != 0) {
            kexit(-1);
        }

        tf.epc += 4;
        intr_on();
        syscall();
    } else {
        which_dev = devintr();
        if (which_dev != 0) {
            // handled device interrupt
        } else if ((scause == 15 or scause == 13) and vmfault(p.pagetable, r_stval(), if (scause == 13) 1 else 0) != 0) {
            // lazy allocation page fault handled
        } else {
            _ = printf("usertrap(): unexpected scause 0x%lx pid=%d\n", scause, p.pid);
            _ = printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
            setkilled(p);
        }
    }

    if (killed(p) != 0) {
        kexit(-1);
    }

    if (which_dev == 2) {
        yield();
    }

    prepare_return();
    return makeSatp(p.pagetable.?);
}

pub export fn prepare_return() void {
    const p = myproc().?;

    intr_off();

    const trampoline_uservec = TRAMPOLINE + @as(u64, @intCast(@intFromPtr(&uservec) - @intFromPtr(&trampoline)));
    w_stvec(trampoline_uservec);

    const tf = p.trapframe.?;
    tf.kernel_satp = r_satp();
    tf.kernel_sp = p.kstack + PGSIZE;
    tf.kernel_trap = @intFromPtr(&usertrap);
    tf.kernel_hartid = r_tp();

    var x = r_sstatus();
    x &= ~SSTATUS_SPP;
    x |= SSTATUS_SPIE;
    w_sstatus(x);

    w_sepc(tf.epc);
}

pub export fn kerneltrap() void {
    var which_dev: i32 = 0;
    const sepc = r_sepc();
    const sstatus = r_sstatus();
    const scause = r_scause();

    if ((sstatus & SSTATUS_SPP) == 0) {
        panic("kerneltrap: not from supervisor mode");
    }
    if (intr_get() != 0) {
        panic("kerneltrap: interrupts enabled");
    }

    which_dev = devintr();
    if (which_dev == 0) {
        _ = printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
        panic("kerneltrap");
    }

    if (which_dev == 2 and myproc() != null) {
        yield();
    }

    w_sepc(sepc);
    w_sstatus(sstatus);
}

pub export fn clockintr() void {
    if (cpuid() == 0) {
        acquire(&tickslock);
        ticks +%= 1;
        wakeup(@ptrCast(&ticks));
        release(&tickslock);
    }

    w_stimecmp(r_time() + 1000000);
}

pub export fn devintr() i32 {
    const scause = r_scause();

    if (scause == 0x8000000000000009) {
        const irq = plic_claim();

        if (irq == UART0_IRQ) {
            uartintr();
        } else if (irq == VIRTIO0_IRQ) {
            virtio_disk_intr();
        } else if (irq != 0) {
            _ = printf("unexpected interrupt irq=%d\n", irq);
        }

        if (irq != 0) {
            plic_complete(irq);
        }
        return 1;
    } else if (scause == 0x8000000000000005) {
        clockintr();
        return 2;
    } else {
        return 0;
    }
}
