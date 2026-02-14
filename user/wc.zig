const xv6 = @import("xv6.zig");

const O_RDONLY: i32 = 0x000;
var buf: [512]u8 = undefined;

fn isSep(ch: u8) bool {
    return ch == ' ' or ch == '\r' or ch == '\t' or ch == '\n' or ch == 0x0b;
}

fn wc(fd: i32, name: [*:0]const u8) void {
    var l: i32 = 0;
    var w: i32 = 0;
    var c: i32 = 0;
    var inword: i32 = 0;

    while (true) {
        const n = xv6.read(fd, &buf, @intCast(buf.len));
        if (n <= 0) {
            if (n < 0) {
                xv6.printf("wc: read error\n");
                xv6.exit(1);
            }
            break;
        }

        var i: u64 = 0;
        const n_usize: u64 = @intCast(n);
        while (i < n_usize) : (i += 1) {
            const ch = buf[i];
            c += 1;
            if (ch == '\n') {
                l += 1;
            }
            if (isSep(ch)) {
                inword = 0;
            } else if (inword == 0) {
                w += 1;
                inword = 1;
            }
        }
    }

    xv6.printf("%d %d %d %s\n", l, w, c, name);
}

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    var i: u64 = 1;
    const n: u64 = @intCast(argc);

    if (argc <= 1) {
        wc(0, "");
        xv6.exit(0);
    }

    while (i < n) : (i += 1) {
        const fd = xv6.open(argv[i], O_RDONLY);
        if (fd < 0) {
            xv6.printf("wc: cannot open %s\n", argv[i]);
            xv6.exit(1);
        }
        wc(fd, argv[i]);
        _ = xv6.close(fd);
    }

    xv6.exit(0);
}
