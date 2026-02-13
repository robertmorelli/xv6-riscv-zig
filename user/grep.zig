const xv6 = @import("xv6.zig");

var buf: [1024]u8 = undefined;

fn match(re: [*:0]const u8, text: [*:0]const u8) i32 {
    if (re[0] == '^') {
        return matchhere(re + 1, text);
    }
    var t = text;
    while (true) {
        if (matchhere(re, t) != 0) {
            return 1;
        }
        if (t[0] == 0) {
            break;
        }
        t += 1;
    }
    return 0;
}

fn matchhere(re: [*:0]const u8, text: [*:0]const u8) i32 {
    if (re[0] == 0) {
        return 1;
    }
    if (re[1] == '*') {
        return matchstar(re[0], re + 2, text);
    }
    if (re[0] == '$' and re[1] == 0) {
        return if (text[0] == 0) 1 else 0;
    }
    if (text[0] != 0 and (re[0] == '.' or re[0] == text[0])) {
        return matchhere(re + 1, text + 1);
    }
    return 0;
}

fn matchstar(c: u8, re: [*:0]const u8, text: [*:0]const u8) i32 {
    var t = text;
    while (true) {
        if (matchhere(re, t) != 0) {
            return 1;
        }
        if (t[0] == 0 or (t[0] != c and c != '.')) {
            break;
        }
        t += 1;
    }
    return 0;
}

fn grep(pattern: [*:0]const u8, fd: i32) void {
    var m: usize = 0;

    while (true) {
        const n = xv6.read(fd, @ptrCast(&buf[m]), @intCast(buf.len - m - 1));
        if (n <= 0) {
            break;
        }
        m += @intCast(n);
        buf[m] = 0;

        var p: usize = 0;
        while (true) {
            var q: usize = p;
            while (q < m and buf[q] != '\n') : (q += 1) {}
            if (q >= m) {
                break;
            }

            buf[q] = 0;
            const line: [*:0]u8 = @ptrCast(&buf[p]);
            if (match(pattern, line) != 0) {
                buf[q] = '\n';
                _ = xv6.write(1, line, @intCast(q + 1 - p));
            }
            p = q + 1;
        }

        if (p > 0) {
            m -= p;
            _ = xv6.memmove(&buf, @ptrCast(&buf[p]), @intCast(m));
        }
    }
}

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    if (argc <= 1) {
        xv6.fprintf(2, "usage: grep pattern [file ...]\n");
        xv6.exit(1);
    }
    const pattern = argv[1];

    if (argc <= 2) {
        grep(pattern, 0);
        xv6.exit(0);
    }

    var i: i32 = 2;
    while (i < argc) : (i += 1) {
        const fd = xv6.open(argv[@intCast(i)], xv6.O_RDONLY);
        if (fd < 0) {
            xv6.printf("grep: cannot open %s\n", argv[@intCast(i)]);
            xv6.exit(1);
        }
        grep(pattern, fd);
        _ = xv6.close(fd);
    }
    xv6.exit(0);
}
