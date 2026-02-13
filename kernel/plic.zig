const PLIC: usize = 0x0c000000;
const UART0_IRQ: u32 = 10;
const VIRTIO0_IRQ: u32 = 1;

extern fn cpuid() callconv(.c) i32;

inline fn plicSenable(hart: i32) usize {
    return PLIC + 0x2080 + @as(usize, @intCast(hart)) * 0x100;
}

inline fn plicSpriority(hart: i32) usize {
    return PLIC + 0x201000 + @as(usize, @intCast(hart)) * 0x2000;
}

inline fn plicSclaim(hart: i32) usize {
    return PLIC + 0x201004 + @as(usize, @intCast(hart)) * 0x2000;
}

pub export fn plicinit() void {
    @as(*volatile u32, @ptrFromInt(PLIC + UART0_IRQ * 4)).* = 1;
    @as(*volatile u32, @ptrFromInt(PLIC + VIRTIO0_IRQ * 4)).* = 1;
}

pub export fn plicinithart() void {
    const hart = cpuid();
    @as(*volatile u32, @ptrFromInt(plicSenable(hart))).* =
        (@as(u32, 1) << UART0_IRQ) | (@as(u32, 1) << VIRTIO0_IRQ);
    @as(*volatile u32, @ptrFromInt(plicSpriority(hart))).* = 0;
}

pub export fn plic_claim() i32 {
    const hart = cpuid();
    const irq = @as(*volatile u32, @ptrFromInt(plicSclaim(hart))).*;
    return @intCast(irq);
}

pub export fn plic_complete(irq: i32) void {
    const hart = cpuid();
    @as(*volatile u32, @ptrFromInt(plicSclaim(hart))).* = @intCast(irq);
}
