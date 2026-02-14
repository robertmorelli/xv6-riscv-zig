const xv6 = @import("xv6.zig");

const O_RDONLY: i32 = 0x000;
var buf: [512]u8 = undefined;

fn cat(fd: i32) void {
    var n: i32 = 0;
    while (true) {
        n = xv6.read(fd, &buf, @intCast(buf.len));
        if (n <= 0) {
            break;
        }
        if (xv6.write(1, &buf, n) != n) {
            xv6.fprintf(2, "cat: write error\n");
            xv6.exit(1);
        }
    }
    if (n < 0) {
        xv6.fprintf(2, "cat: read error\n");
        xv6.exit(1);
    }
}

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    var i: u64 = 1;
    const n: u64 = @intCast(argc);

    if (argc <= 1) {
        cat(0);
        xv6.exit(0);
    }

    while (i < n) : (i += 1) {
        const fd = xv6.open(argv[i], O_RDONLY);
        if (fd < 0) {
            xv6.fprintf(2, "cat: cannot open %s\n", argv[i]);
            xv6.exit(1);
        }
        cat(fd);
        _ = xv6.close(fd);
    }

    xv6.exit(0);
}
