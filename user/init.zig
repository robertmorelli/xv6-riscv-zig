const xv6 = @import("xv6.zig");

var argv = [_]?[*:0]const u8{ "sh", null };

pub export fn main() i32 {
    var pid: i32 = 0;
    var wpid: i32 = 0;

    if (xv6.open("console", xv6.O_RDWR) < 0) {
        _ = xv6.mknod("console", xv6.CONSOLE, 0);
        _ = xv6.open("console", xv6.O_RDWR);
    }
    _ = xv6.dup(0);
    _ = xv6.dup(0);

    while (true) {
        xv6.printf("init: starting sh\n");
        pid = xv6.fork();
        if (pid < 0) {
            xv6.printf("init: fork failed\n");
            xv6.exit(1);
        }
        if (pid == 0) {
            _ = xv6.exec("sh", &argv);
            xv6.printf("init: exec sh failed\n");
            xv6.exit(1);
        }

        while (true) {
            wpid = xv6.wait(null);
            if (wpid == pid) {
                break;
            } else if (wpid < 0) {
                xv6.printf("init: wait returned an error\n");
                xv6.exit(1);
            }
        }
    }
}
