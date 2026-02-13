const cint = i32;
const cuint = u32;

const Spinlock = extern struct {
    locked: cuint,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

pub export var panicking: cint = 0;
pub export var panicked: cint = 0;

var pr_lock: Spinlock = undefined;

const digits = "0123456789abcdef";

extern fn consputc(c: cint) callconv(.c) void;
extern fn initlock(lk: *Spinlock, name: [*c]u8) callconv(.c) void;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;

fn printint(xx: i64, base: u32, sign: bool) void {
    var buf: [20]u8 = undefined;
    var i: usize = 0;
    var x: u64 = 0;
    var neg = false;

    if (sign and xx < 0) {
        neg = true;
        x = @intCast(-xx);
    } else {
        x = @intCast(xx);
    }

    while (true) {
        buf[i] = digits[@intCast(x % base)];
        i += 1;
        x /= base;
        if (x == 0) {
            break;
        }
    }

    if (neg) {
        buf[i] = '-';
        i += 1;
    }

    while (i > 0) {
        i -= 1;
        consputc(buf[i]);
    }
}

fn printptr(x0: u64) void {
    var x = x0;
    consputc('0');
    consputc('x');
    var i: usize = 0;
    while (i < (@sizeOf(u64) * 2)) : (i += 1) {
        const d: usize = @intCast((x >> (@sizeOf(u64) * 8 - 4)) & 0xf);
        consputc(digits[d]);
        x <<= 4;
    }
}

fn vprintf(fmt: [*:0]const u8, ap: anytype) void {
    var i: usize = 0;
    while (true) : (i += 1) {
        const cx = fmt[i];
        if (cx == 0) {
            break;
        }
        if (cx != '%') {
            consputc(cx);
            continue;
        }

        i += 1;
        const c0 = fmt[i];
        const c1 = if (c0 != 0) fmt[i + 1] else 0;
        const c2 = if (c1 != 0) fmt[i + 2] else 0;

        if (c0 == 'd') {
            printint(@cVaArg(ap, i32), 10, true);
        } else if (c0 == 'l' and c1 == 'd') {
            printint(@cVaArg(ap, i64), 10, true);
            i += 1;
        } else if (c0 == 'l' and c1 == 'l' and c2 == 'd') {
            printint(@cVaArg(ap, i64), 10, true);
            i += 2;
        } else if (c0 == 'u') {
            printint(@as(i64, @intCast(@cVaArg(ap, u32))), 10, false);
        } else if (c0 == 'l' and c1 == 'u') {
            printint(@cVaArg(ap, i64), 10, false);
            i += 1;
        } else if (c0 == 'l' and c1 == 'l' and c2 == 'u') {
            printint(@cVaArg(ap, i64), 10, false);
            i += 2;
        } else if (c0 == 'x') {
            printint(@as(i64, @intCast(@cVaArg(ap, u32))), 16, false);
        } else if (c0 == 'l' and c1 == 'x') {
            printint(@cVaArg(ap, i64), 16, false);
            i += 1;
        } else if (c0 == 'l' and c1 == 'l' and c2 == 'x') {
            printint(@cVaArg(ap, i64), 16, false);
            i += 2;
        } else if (c0 == 'p') {
            printptr(@cVaArg(ap, u64));
        } else if (c0 == 'c') {
            consputc(@intCast(@cVaArg(ap, cuint)));
        } else if (c0 == 's') {
            var s = @cVaArg(ap, ?[*:0]u8);
            if (s == null) {
                const nulls: [*:0]const u8 = "(null)";
                s = @constCast(nulls);
            }
            var p = s.?;
            while (p[0] != 0) : (p += 1) {
                consputc(p[0]);
            }
        } else if (c0 == '%') {
            consputc('%');
        } else if (c0 == 0) {
            break;
        } else {
            consputc('%');
            consputc(c0);
        }
    }
}

fn printstr(s: [*:0]const u8) void {
    var p = s;
    while (p[0] != 0) : (p += 1) {
        consputc(p[0]);
    }
}

pub export fn printf(fmt: [*:0]const u8, ...) callconv(.c) cint {
    if (panicking == 0) {
        acquire(&pr_lock);
    }

    var ap = @cVaStart();
    defer @cVaEnd(&ap);
    vprintf(fmt, &ap);

    if (panicking == 0) {
        release(&pr_lock);
    }

    return 0;
}

pub export fn panic(s: [*:0]const u8) callconv(.c) noreturn {
    panicking = 1;
    printstr("panic: ");
    printstr(s);
    consputc('\n');
    panicked = 1;
    while (true) {}
}

pub export fn printfinit() callconv(.c) void {
    initlock(&pr_lock, @constCast("pr"));
}
