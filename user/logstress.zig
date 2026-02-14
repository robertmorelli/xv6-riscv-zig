const xv6 = @import("xv6.zig");

const N: i32 = 250;
const SZ: i32 = 2000;
const SZU: u64 = 2000;
var buf: [SZU]u8 = undefined;

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    var argi: i32 = 1;
    while (argi < argc) : (argi += 1) {
        const pid1 = xv6.fork();
        if (pid1 < 0) {
            xv6.printf("%s: fork failed\n", argv[0]);
            xv6.exit(1);
        }
        if (pid1 == 0) {
            const fd = xv6.open(argv[@intCast(argi)], xv6.O_CREATE | xv6.O_RDWR);
            if (fd < 0) {
                xv6.printf("%s: create %s failed\n", argv[0], argv[@intCast(argi)]);
                xv6.exit(1);
            }

            _ = xv6.memset(&buf, @as(i32, '0') + argi, @intCast(SZ));

            var i: i32 = 0;
            while (i < N) : (i += 1) {
                const n = xv6.write(fd, &buf, SZ);
                if (n != SZ) {
                    xv6.printf("write failed %d\n", n);
                    xv6.exit(1);
                }
            }
            xv6.exit(0);
        }
    }

    var xstatus: i32 = 0;
    var i: i32 = 1;
    while (i < argc) : (i += 1) {
        _ = xv6.wait(&xstatus);
        if (xstatus != 0) {
            xv6.exit(xstatus);
        }
    }

    return 0;
}
