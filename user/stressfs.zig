const xv6 = @import("xv6.zig");

pub export fn main(_: i32, _: [*][*:0]u8) i32 {
    var path = [_:0]u8{ 's', 't', 'r', 'e', 's', 's', 'f', 's', '0', 0 };
    var data: [512]u8 = undefined;
    var fd: i32 = 0;
    var i: i32 = 0;

    xv6.printf("stressfs starting\n");
    _ = xv6.memset(&data, 'a', @intCast(data.len));

    i = 0;
    while (i < 4) : (i += 1) {
        if (xv6.fork() > 0) {
            break;
        }
    }

    xv6.printf("write %d\n", i);
    path[8] = @as(u8, @intCast(@as(i32, path[8]) + i));

    fd = xv6.open(&path, xv6.O_CREATE | xv6.O_RDWR);
    i = 0;
    while (i < 20) : (i += 1) {
        _ = xv6.write(fd, &data, @intCast(data.len));
    }
    _ = xv6.close(fd);

    xv6.printf("read\n");

    fd = xv6.open(&path, xv6.O_RDONLY);
    i = 0;
    while (i < 20) : (i += 1) {
        _ = xv6.read(fd, &data, @intCast(data.len));
    }
    _ = xv6.close(fd);

    _ = xv6.wait(null);
    xv6.exit(0);
}
