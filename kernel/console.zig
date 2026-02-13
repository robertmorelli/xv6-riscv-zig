const std = @import("std");

const cint = i32;
const cuint = u32;

const NDEV: usize = 10;
const CONSOLE: usize = 1;
const INPUT_BUF_SIZE: cuint = 128;
const BACKSPACE: cint = 0x100;

const Spinlock = extern struct {
    locked: cuint,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Devsw = extern struct {
    read: ?*const fn (cint, u64, cint) callconv(.c) cint,
    write: ?*const fn (cint, u64, cint) callconv(.c) cint,
};

const ConsState = extern struct {
    lock: Spinlock,
    buf: [INPUT_BUF_SIZE]u8,
    r: cuint,
    w: cuint,
    e: cuint,
};

var cons: ConsState = std.mem.zeroes(ConsState);

extern var devsw: [NDEV]Devsw;

extern fn uartputc_sync(c: cint) callconv(.c) void;
extern fn uartwrite(buf: [*c]u8, n: cint) callconv(.c) void;
extern fn uartinit() callconv(.c) void;
extern fn initlock(lk: *Spinlock, name: [*c]u8) callconv(.c) void;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;
extern fn either_copyin(dst: ?*anyopaque, user_src: cint, src: u64, len: u64) callconv(.c) cint;
extern fn either_copyout(user_dst: cint, dst: u64, src: ?*anyopaque, len: u64) callconv(.c) cint;
extern fn myproc() callconv(.c) ?*anyopaque;
extern fn killed(p: ?*anyopaque) callconv(.c) cint;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) callconv(.c) void;
extern fn wakeup(chan: ?*anyopaque) callconv(.c) void;
extern fn procdump() callconv(.c) void;

inline fn ctrl(x: u8) cint {
    return @as(cint, x) - @as(cint, '@');
}

pub export fn consputc(c: cint) callconv(.c) void {
    if (c == BACKSPACE) {
        uartputc_sync('\x08');
        uartputc_sync(' ');
        uartputc_sync('\x08');
    } else {
        uartputc_sync(c);
    }
}

pub export fn consolewrite(user_src: cint, src: u64, n: cint) callconv(.c) cint {
    var buf: [32]u8 = undefined;
    var i: cint = 0;

    while (i < n) {
        var nn: cint = @intCast(buf.len);
        if (nn > n - i) {
            nn = n - i;
        }
        if (either_copyin(@ptrCast(&buf), user_src, src + @as(u64, @intCast(@as(cuint, @intCast(i)))), @as(u64, @intCast(@as(cuint, @intCast(nn))))) == -1) {
            break;
        }
        uartwrite(@ptrCast(&buf), nn);
        i += nn;
    }

    return i;
}

pub export fn consoleread(user_dst: cint, dst: u64, n: cint) callconv(.c) cint {
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

        const idx: usize = @intCast(cons.r % INPUT_BUF_SIZE);
        const c: cint = cons.buf[idx];
        cons.r +%= 1;

        if (c == ctrl('D')) {
            if (nleft < target) {
                cons.r -%= 1;
            }
            break;
        }

        var cbuf: u8 = @truncate(@as(cuint, @intCast(c)));
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

pub export fn consoleintr(c_in: cint) callconv(.c) void {
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
                cons.buf[@intCast(cons.e % INPUT_BUF_SIZE)] = @truncate(@as(cuint, @intCast(c)));
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

pub export fn consoleinit() callconv(.c) void {
    initlock(&cons.lock, @constCast("cons"));
    uartinit();
    devsw[CONSOLE].read = &consoleread;
    devsw[CONSOLE].write = &consolewrite;
}
