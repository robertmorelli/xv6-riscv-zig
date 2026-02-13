const xv6 = @import("xv6.zig");

pub export fn main(_: i32, argv: [*][*:0]u8) i32 {
    const self = argv[0];
    const ff: [*:0]const u8 = "file0";
    var st: xv6.Stat = undefined;

    const fd = xv6.open(ff, xv6.O_CREATE | xv6.O_WRONLY);
    if (fd < 0) {
        xv6.printf("%s: open failed\n", self);
        xv6.exit(1);
    }
    if (xv6.fstat(fd, &st) < 0) {
        xv6.fprintf(2, "%s: cannot stat %s\n", self, "ff");
        xv6.exit(1);
    }
    if (xv6.unlink(ff) < 0) {
        xv6.printf("%s: unlink failed\n", self);
        xv6.exit(1);
    }
    if (xv6.open(ff, xv6.O_RDONLY) != -1) {
        xv6.printf("%s: open successed\n", self);
        xv6.exit(1);
    }

    xv6.printf("wait for kill and reclaim %d\n", @as(i32, @intCast(st.ino)));
    while (true) {
        _ = xv6.pause(1000);
    }
}
