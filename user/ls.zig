const xv6 = @import("xv6.zig");

var fmtbuf: [xv6.DIRSIZ + 1]u8 = undefined;

fn fmtname(path: [*:0]const u8) [*:0]u8 {
    const len: usize = @intCast(xv6.strlen(path));
    var start: usize = len;
    while (start > 0 and path[start - 1] != '/') {
        start -= 1;
    }

    const n = len - start;
    if (n >= xv6.DIRSIZ) {
        return @constCast(path + start);
    }

    var i: usize = 0;
    while (i < n) : (i += 1) {
        fmtbuf[i] = path[start + i];
    }
    while (i < xv6.DIRSIZ) : (i += 1) {
        fmtbuf[i] = ' ';
    }
    fmtbuf[xv6.DIRSIZ] = 0;
    return @ptrCast(&fmtbuf);
}

fn ls(path: [*:0]const u8) void {
    var buf: [512:0]u8 = undefined;
    var st: xv6.Stat = undefined;
    var de: xv6.Dirent = undefined;

    const fd = xv6.open(path, xv6.O_RDONLY);
    if (fd < 0) {
        xv6.fprintf(2, "ls: cannot open %s\n", path);
        return;
    }
    if (xv6.fstat(fd, &st) < 0) {
        xv6.fprintf(2, "ls: cannot stat %s\n", path);
        _ = xv6.close(fd);
        return;
    }

    switch (st.type) {
        xv6.T_DEVICE, xv6.T_FILE => {
            xv6.printf("%s %d %d %d\n", fmtname(path), @as(i32, st.type), @as(i32, @intCast(st.ino)), @as(i32, @intCast(st.size)));
        },
        xv6.T_DIR => {
            if (xv6.strlen(path) + 1 + xv6.DIRSIZ + 1 > buf.len) {
                xv6.printf("ls: path too long\n");
                _ = xv6.close(fd);
                return;
            }

            _ = xv6.strcpy(&buf, path);
            var p: usize = @intCast(xv6.strlen(@ptrCast(&buf)));
            buf[p] = '/';
            p += 1;

            while (xv6.read(fd, @ptrCast(&de), @sizeOf(xv6.Dirent)) == @as(i32, @intCast(@sizeOf(xv6.Dirent)))) {
                if (de.inum == 0) {
                    continue;
                }

                var i: usize = 0;
                while (i < xv6.DIRSIZ) : (i += 1) {
                    buf[p + i] = de.name[i];
                }
                buf[p + xv6.DIRSIZ] = 0;

                if (xv6.stat(@ptrCast(&buf), &st) < 0) {
                    xv6.printf("ls: cannot stat %s\n", @as([*:0]u8, @ptrCast(&buf)));
                    continue;
                }
                xv6.printf(
                    "%s %d %d %d\n",
                    fmtname(@ptrCast(&buf)),
                    @as(i32, st.type),
                    @as(i32, @intCast(st.ino)),
                    @as(i32, @intCast(st.size)),
                );
            }
        },
        else => {},
    }

    _ = xv6.close(fd);
}

pub export fn main(argc: i32, argv: [*][*:0]u8) i32 {
    if (argc < 2) {
        ls(".");
        xv6.exit(0);
    }

    var i: i32 = 1;
    while (i < argc) : (i += 1) {
        ls(argv[@intCast(i)]);
    }
    xv6.exit(0);
}
