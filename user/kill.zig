const xv6 = @import("xv6.zig");

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    var i: u64 = 1;
    const n: u64 = @intCast(argc);

    if (argc < 2) {
        xv6.fprintf(2, "usage: kill pid...\n");
        xv6.exit(1);
    }

    while (i < n) : (i += 1) {
        _ = xv6.kill(xv6.atoi(argv[i]));
    }

    xv6.exit(0);
}
