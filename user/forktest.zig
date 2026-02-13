const xv6 = @import("xv6.zig");

const N: i32 = 1000;

fn print(s: [*:0]const u8) void {
    _ = xv6.write(1, s, xv6.strlen_i32(s));
}

fn forktest() void {
    var n: i32 = 0;
    var pid: i32 = 0;

    print("fork test\n");

    n = 0;
    while (n < N) : (n += 1) {
        pid = xv6.fork();
        if (pid < 0) {
            break;
        }
        if (pid == 0) {
            xv6.exit(0);
        }
    }

    if (n == N) {
        print("fork claimed to work N times!\n");
        xv6.exit(1);
    }

    while (n > 0) : (n -= 1) {
        if (xv6.wait(null) < 0) {
            print("wait stopped early\n");
            xv6.exit(1);
        }
    }

    if (xv6.wait(null) != -1) {
        print("wait got too many\n");
        xv6.exit(1);
    }

    print("fork test OK\n");
}

pub export fn main() i32 {
    forktest();
    xv6.exit(0);
}
