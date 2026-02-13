const NCPU: usize = 8;

pub export var stack0: [4096 * NCPU]u8 align(16) = undefined;

extern fn main() callconv(.c) noreturn;

inline fn r_mhartid() u64 {
    return asm volatile ("csrr %[result], mhartid"
        : [result] "=r" (-> u64),
    );
}

inline fn r_mstatus() u64 {
    return asm volatile ("csrr %[result], mstatus"
        : [result] "=r" (-> u64),
    );
}

inline fn w_mstatus(x: u64) void {
    asm volatile ("csrw mstatus, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn w_mepc(x: u64) void {
    asm volatile ("csrw mepc, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn w_satp(x: u64) void {
    asm volatile ("csrw satp, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn w_medeleg(x: u64) void {
    asm volatile ("csrw medeleg, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn w_mideleg(x: u64) void {
    asm volatile ("csrw mideleg, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn r_sie() u64 {
    return asm volatile ("csrr %[result], sie"
        : [result] "=r" (-> u64),
    );
}

inline fn w_sie(x: u64) void {
    asm volatile ("csrw sie, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn w_pmpaddr0(x: u64) void {
    asm volatile ("csrw pmpaddr0, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn w_pmpcfg0(x: u64) void {
    asm volatile ("csrw pmpcfg0, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn w_tp(x: u64) void {
    asm volatile ("mv tp, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn r_mie() u64 {
    return asm volatile ("csrr %[result], mie"
        : [result] "=r" (-> u64),
    );
}

inline fn w_mie(x: u64) void {
    asm volatile ("csrw mie, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn r_menvcfg() u64 {
    return asm volatile ("csrr %[result], menvcfg"
        : [result] "=r" (-> u64),
    );
}

inline fn w_menvcfg(x: u64) void {
    asm volatile ("csrw menvcfg, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn r_mcounteren() u64 {
    return asm volatile ("csrr %[result], mcounteren"
        : [result] "=r" (-> u64),
    );
}

inline fn w_mcounteren(x: u64) void {
    asm volatile ("csrw mcounteren, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn r_time() u64 {
    return asm volatile ("csrr %[result], time"
        : [result] "=r" (-> u64),
    );
}

inline fn w_stimecmp(x: u64) void {
    asm volatile ("csrw stimecmp, %[value]"
        :
        : [value] "r" (x),
    );
}

fn timerinit() void {
    w_mie(r_mie() | (@as(u64, 1) << 5));
    w_menvcfg(r_menvcfg() | (@as(u64, 1) << 63));
    w_mcounteren(r_mcounteren() | 2);
    w_stimecmp(r_time() + 1_000_000);
}

pub export fn start() callconv(.c) noreturn {
    var x = r_mstatus();
    x &= ~(@as(u64, 3) << 11);
    x |= (@as(u64, 1) << 11);
    w_mstatus(x);

    w_mepc(@intFromPtr(&main));
    w_satp(0);
    w_medeleg(0xffff);
    w_mideleg(0xffff);
    w_sie(r_sie() | (@as(u64, 1) << 9) | (@as(u64, 1) << 5));
    w_pmpaddr0(0x3fffffffffffff);
    w_pmpcfg0(0x0f);
    timerinit();
    w_tp(r_mhartid());

    asm volatile ("mret");
    unreachable;
}
