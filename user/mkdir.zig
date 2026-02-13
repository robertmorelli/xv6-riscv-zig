const xv6 = @import("xv6.zig");

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    var i: usize = 1;
    const n: usize = @intCast(argc);

    if (argc < 2) {
        xv6.fprintf(2, "Usage: mkdir files...\n");
        xv6.exit(1);
    }

    while (i < n) : (i += 1) {
        if (xv6.mkdir(argv[i]) < 0) {
            xv6.fprintf(2, "mkdir: %s failed to create\n", argv[i]);
            break;
        }
    }

    xv6.exit(0);
}
