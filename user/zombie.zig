const xv6 = @import("xv6.zig");

pub export fn main() i32 {
    if (xv6.fork() > 0) {
        _ = xv6.pause(5);
    }
    xv6.exit(0);
}
