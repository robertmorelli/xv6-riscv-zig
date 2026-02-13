const xv6 = @import("xv6.zig");

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    if (argc != 3) {
        xv6.fprintf(2, "Usage: ln old new\n");
        xv6.exit(1);
    }

    if (xv6.link(argv[1], argv[2]) < 0) {
        xv6.fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
    }

    xv6.exit(0);
}
