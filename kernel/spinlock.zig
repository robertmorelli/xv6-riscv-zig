
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
    proc: ?*anyopaque,
    context: Context,
    noff: i32,
    intena: i32,
};

const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*Cpu,
};

extern fn panic(s: [*c]const u8) noreturn;
extern fn mycpu() *Cpu;

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

pub export fn initlock(lk: *Spinlock, name: [*c]u8) void {
    lk.name = name;
    lk.locked = 0;
    lk.cpu = null;
}

pub export fn acquire(lk: *Spinlock) void {
    push_off();
    if (holding(lk) != 0) {
        panic("acquire");
    }

    while (@atomicRmw(u32, &lk.locked, .Xchg, 1, .seq_cst) != 0) {}
    lk.cpu = mycpu();
}

pub export fn release(lk: *Spinlock) void {
    if (holding(lk) == 0) {
        panic("release");
    }

    lk.cpu = null;
    @atomicStore(u32, &lk.locked, 0, .seq_cst);
    pop_off();
}

pub export fn holding(lk: *Spinlock) i32 {
    const held = lk.locked != 0 and lk.cpu == mycpu();
    return if (held) 1 else 0;
}

pub export fn push_off() void {
    const old = intr_get();
    intr_off();

    const c = mycpu();
    if (c.noff == 0) {
        c.intena = old;
    }
    c.noff += 1;
}

pub export fn pop_off() void {
    const c = mycpu();
    if (intr_get() != 0) {
        panic("pop_off - interruptible");
    }
    if (c.noff < 1) {
        panic("pop_off");
    }

    c.noff -= 1;
    if (c.noff == 0 and c.intena != 0) {
        intr_on();
    }
}
