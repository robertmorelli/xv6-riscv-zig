const cint = i32;
const cuint = u32;

const UART0: usize = 0x10000000;

const RHR: usize = 0;
const THR: usize = 0;
const IER: usize = 1;
const IER_RX_ENABLE: u8 = 1 << 0;
const IER_TX_ENABLE: u8 = 1 << 1;
const FCR: usize = 2;
const FCR_FIFO_ENABLE: u8 = 1 << 0;
const FCR_FIFO_CLEAR: u8 = 3 << 1;
const ISR: usize = 2;
const LCR: usize = 3;
const LCR_EIGHT_BITS: u8 = 3 << 0;
const LCR_BAUD_LATCH: u8 = 1 << 7;
const LSR: usize = 5;
const LSR_RX_READY: u8 = 1 << 0;
const LSR_TX_IDLE: u8 = 1 << 5;

const Spinlock = extern struct {
    locked: cuint,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

var tx_lock: Spinlock = undefined;
var tx_busy: cint = 0;
var tx_chan: cint = 0;

extern var panicking: cint;
extern var panicked: cint;

extern fn initlock(lk: *Spinlock, name: [*c]u8) callconv(.c) void;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) callconv(.c) void;
extern fn wakeup(chan: ?*anyopaque) callconv(.c) void;
extern fn push_off() callconv(.c) void;
extern fn pop_off() callconv(.c) void;
extern fn consoleintr(c: cint) callconv(.c) void;

inline fn regPtr(reg: usize) *volatile u8 {
    return @ptrFromInt(UART0 + reg);
}

inline fn readReg(reg: usize) u8 {
    return regPtr(reg).*;
}

inline fn writeReg(reg: usize, value: u8) void {
    regPtr(reg).* = value;
}

pub export fn uartinit() void {
    writeReg(IER, 0x00);
    writeReg(LCR, LCR_BAUD_LATCH);
    writeReg(0, 0x03);
    writeReg(1, 0x00);
    writeReg(LCR, LCR_EIGHT_BITS);
    writeReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    writeReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    initlock(&tx_lock, @constCast("uart"));
}

pub export fn uartwrite(buf: [*c]u8, n: cint) void {
    acquire(&tx_lock);

    var i: cint = 0;
    while (i < n) {
        while (tx_busy != 0) {
            sleep(@ptrCast(&tx_chan), &tx_lock);
        }

        writeReg(THR, buf[@intCast(i)]);
        i += 1;
        tx_busy = 1;
    }

    release(&tx_lock);
}

pub export fn uartputc_sync(c: cint) void {
    if (panicking == 0) {
        push_off();
    }

    if (panicked != 0) {
        while (true) {}
    }

    while ((readReg(LSR) & LSR_TX_IDLE) == 0) {}
    writeReg(THR, @truncate(@as(cuint, @bitCast(c))));

    if (panicking == 0) {
        pop_off();
    }
}

pub export fn uartgetc() cint {
    if ((readReg(LSR) & LSR_RX_READY) != 0) {
        return @intCast(readReg(RHR));
    }
    return -1;
}

pub export fn uartintr() void {
    _ = readReg(ISR);

    acquire(&tx_lock);
    if ((readReg(LSR) & LSR_TX_IDLE) != 0) {
        tx_busy = 0;
        wakeup(@ptrCast(&tx_chan));
    }
    release(&tx_lock);

    while (true) {
        const c = uartgetc();
        if (c == -1) {
            break;
        }
        consoleintr(c);
    }
}
