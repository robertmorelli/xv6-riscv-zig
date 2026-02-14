const xv6 = @import("xv6.zig");

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    var i: u64 = 1;
    const n: u64 = @intCast(argc);

    if (argc < 2) {
        xv6.fprintf(2, "Usage: rm files...\n");
        xv6.exit(1);
    }

    while (i < n) : (i += 1) {
        if (xv6.unlink(argv[i]) < 0) {
            xv6.fprintf(2, "rm: %s failed to delete\n", argv[i]);
            break;
        }
    }

    xv6.exit(0);
}
