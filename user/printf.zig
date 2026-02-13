const xv6 = @import("xv6.zig");

const digits = "0123456789ABCDEF";

fn putc(fd: i32, c: u8) void {
    var ch: [1]u8 = .{c};
    _ = xv6.write(fd, &ch, 1);
}

fn printint(fd: i32, xx: i64, base: u32, sgn: bool) void {
    var buf: [20]u8 = undefined;
    var i: usize = 0;
    var x: u64 = 0;
    var neg = false;

    if (sgn and xx < 0) {
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
        putc(fd, buf[i]);
    }
}

fn printptr(fd: i32, x0: u64) void {
    var x = x0;
    putc(fd, '0');
    putc(fd, 'x');
    var i: usize = 0;
    while (i < (@sizeOf(u64) * 2)) : (i += 1) {
        const d: usize = @intCast((x >> (@sizeOf(u64) * 8 - 4)) & 0xf);
        putc(fd, digits[d]);
        x <<= 4;
    }
}

fn vprintf(fd: i32, fmt: [*:0]const u8, ap: anytype) void {
    var i: usize = 0;
    var state: u8 = 0;

    while (fmt[i] != 0) : (i += 1) {
        const c0 = fmt[i];
        if (state == 0) {
            if (c0 == '%') {
                state = '%';
            } else {
                putc(fd, c0);
            }
            continue;
        }

        var c1: u8 = 0;
        var c2: u8 = 0;
        if (fmt[i + 0] != 0) c1 = fmt[i + 1];
        if (c1 != 0) c2 = fmt[i + 2];

        if (c0 == 'd') {
            printint(fd, @cVaArg(ap, i32), 10, true);
        } else if (c0 == 'l' and c1 == 'd') {
            printint(fd, @cVaArg(ap, i64), 10, true);
            i += 1;
        } else if (c0 == 'l' and c1 == 'l' and c2 == 'd') {
            printint(fd, @cVaArg(ap, i64), 10, true);
            i += 2;
        } else if (c0 == 'u') {
            printint(fd, @cVaArg(ap, u32), 10, false);
        } else if (c0 == 'l' and c1 == 'u') {
            printint(fd, @cVaArg(ap, i64), 10, false);
            i += 1;
        } else if (c0 == 'l' and c1 == 'l' and c2 == 'u') {
            printint(fd, @cVaArg(ap, i64), 10, false);
            i += 2;
        } else if (c0 == 'x') {
            printint(fd, @cVaArg(ap, u32), 16, false);
        } else if (c0 == 'l' and c1 == 'x') {
            printint(fd, @cVaArg(ap, i64), 16, false);
            i += 1;
        } else if (c0 == 'l' and c1 == 'l' and c2 == 'x') {
            printint(fd, @cVaArg(ap, i64), 16, false);
            i += 2;
        } else if (c0 == 'p') {
            printptr(fd, @cVaArg(ap, u64));
        } else if (c0 == 'c') {
            putc(fd, @truncate(@cVaArg(ap, u32)));
        } else if (c0 == 's') {
            var s = @cVaArg(ap, ?[*:0]u8);
            if (s == null) {
                const nulls: [*:0]const u8 = "(null)";
                s = @constCast(nulls);
            }
            var p = s.?;
            while (p[0] != 0) : (p += 1) {
                putc(fd, p[0]);
            }
        } else if (c0 == '%') {
            putc(fd, '%');
        } else {
            putc(fd, '%');
            putc(fd, c0);
        }
        state = 0;
    }
}

pub export fn fprintf(fd: i32, fmt: [*:0]const u8, ...) void {
    var ap = @cVaStart();
    defer @cVaEnd(&ap);
    vprintf(fd, fmt, &ap);
}

pub export fn printf(fmt: [*:0]const u8, ...) void {
    var ap = @cVaStart();
    defer @cVaEnd(&ap);
    vprintf(1, fmt, &ap);
}
