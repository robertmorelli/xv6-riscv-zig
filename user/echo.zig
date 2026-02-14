const xv6 = @import("xv6.zig");

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    var i: u64 = 1;
    const n: u64 = @intCast(argc);

    while (i < n) : (i += 1) {
        const arg = argv[i];
        _ = xv6.write(1, arg, xv6.strlen_i32(arg));
        if (i + 1 < n) {
            _ = xv6.write(1, " ", 1);
        } else {
            _ = xv6.write(1, "\n", 1);
        }
    }

    xv6.exit(0);
}
