const std = @import("std");


const NDEV: u64 = 10;
const CONSOLE: u64 = 1;
const INPUT_BUF_SIZE: u32 = 128;
const BACKSPACE: i32 = 0x100;

const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Devsw = extern struct {
    read: ?*const fn (i32, u64, i32) callconv(.c) i32,
    write: ?*const fn (i32, u64, i32) callconv(.c) i32,
};

const ConsState = extern struct {
    lock: Spinlock,
    buf: [INPUT_BUF_SIZE]u8,
    r: u32,
    w: u32,
    e: u32,
};

var cons: ConsState = std.mem.zeroes(ConsState);

extern var devsw: [NDEV]Devsw;

extern fn uartputc_sync(c: i32) void;
extern fn uartwrite(buf: [*c]u8, n: i32) void;
extern fn uartinit() void;
extern fn initlock(lk: *Spinlock, name: [*c]u8) void;
extern fn acquire(lk: *Spinlock) void;
extern fn release(lk: *Spinlock) void;
extern fn either_copyin(dst: ?*anyopaque, user_src: i32, src: u64, len: u64) i32;
extern fn either_copyout(user_dst: i32, dst: u64, src: ?*anyopaque, len: u64) i32;
extern fn myproc() ?*anyopaque;
extern fn killed(p: ?*anyopaque) i32;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) void;
extern fn wakeup(chan: ?*anyopaque) void;
extern fn procdump() void;

inline fn ctrl(x: u8) i32 {
    return @as(i32, x) - @as(i32, '@');
}

pub export fn consputc(c: i32) void {
    if (c == BACKSPACE) {
        uartputc_sync('\x08');
        uartputc_sync(' ');
        uartputc_sync('\x08');
    } else {
        uartputc_sync(c);
    }
}

pub export fn consolewrite(user_src: i32, src: u64, n: i32) i32 {
    var buf: [32]u8 = undefined;
    var i: i32 = 0;

    while (i < n) {
        var nn: i32 = @intCast(buf.len);
        if (nn > n - i) {
            nn = n - i;
        }
        if (either_copyin(@ptrCast(&buf), user_src, src + @as(u64, @intCast(@as(u32, @intCast(i)))), @as(u64, @intCast(@as(u32, @intCast(nn))))) == -1) {
            break;
        }
        uartwrite(@ptrCast(&buf), nn);
        i += nn;
    }

    return i;
}

pub export fn consoleread(user_dst: i32, dst: u64, n: i32) i32 {
    const target = n;
    var nleft = n;
    var out = dst;

    acquire(&cons.lock);
    while (nleft > 0) {
        while (cons.r == cons.w) {
            if (killed(myproc()) != 0) {
                release(&cons.lock);
                return -1;
            }
            sleep(@ptrCast(&cons.r), &cons.lock);
        }

        const idx: u64 = @intCast(cons.r % INPUT_BUF_SIZE);
        const c: i32 = cons.buf[idx];
        cons.r +%= 1;

        if (c == ctrl('D')) {
            if (nleft < target) {
                cons.r -%= 1;
            }
            break;
        }

        var cbuf: u8 = @truncate(@as(u32, @intCast(c)));
        if (either_copyout(user_dst, out, @ptrCast(&cbuf), 1) == -1) {
            break;
        }

        out += 1;
        nleft -= 1;

        if (c == '\n') {
            break;
        }
    }
    release(&cons.lock);

    return target - nleft;
}

pub export fn consoleintr(c_in: i32) void {
    var c = c_in;
    acquire(&cons.lock);

    switch (c) {
        ctrl('P') => {
            procdump();
        },
        ctrl('U') => {
            while (cons.e != cons.w and cons.buf[@intCast((cons.e -% 1) % INPUT_BUF_SIZE)] != '\n') {
                cons.e -%= 1;
                consputc(BACKSPACE);
            }
        },
        ctrl('H'), 0x7f => {
            if (cons.e != cons.w) {
                cons.e -%= 1;
                consputc(BACKSPACE);
            }
        },
        else => {
            if (c != 0 and (cons.e -% cons.r) < INPUT_BUF_SIZE) {
                c = if (c == '\r') '\n' else c;
                consputc(c);
                cons.buf[@intCast(cons.e % INPUT_BUF_SIZE)] = @truncate(@as(u32, @intCast(c)));
                cons.e +%= 1;

                if (c == '\n' or c == ctrl('D') or (cons.e -% cons.r) == INPUT_BUF_SIZE) {
                    cons.w = cons.e;
                    wakeup(@ptrCast(&cons.r));
                }
            }
        },
    }

    release(&cons.lock);
}

pub export fn consoleinit() void {
    initlock(&cons.lock, @constCast("cons"));
    uartinit();
    devsw[CONSOLE].read = &consoleread;
    devsw[CONSOLE].write = &consolewrite;
}
