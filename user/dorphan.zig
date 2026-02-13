const xv6 = @import("xv6.zig");

pub export fn main(_: i32, argv: [*][*:0]u8) i32 {
    const self = argv[0];

    if (xv6.mkdir("dd") != 0) {
        xv6.printf("%s: mkdir dd failed\n", self);
        xv6.exit(1);
    }
    if (xv6.chdir("dd") != 0) {
        xv6.printf("%s: chdir dd failed\n", self);
        xv6.exit(1);
    }
    if (xv6.unlink("../dd") < 0) {
        xv6.printf("%s: unlink failed\n", self);
        xv6.exit(1);
    }

    xv6.printf("wait for kill and reclaim\n");
    while (true) {
        _ = xv6.pause(1000);
    }
}
