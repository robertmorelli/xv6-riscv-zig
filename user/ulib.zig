const xv6 = @import("xv6.zig");

extern fn main(argc: i32, argv: [*][*:0]u8) i32;

pub export fn start(argc: i32, argv: [*][*:0]u8) void {
    const r = main(argc, argv);
    xv6.exit(r);
}

pub export fn strcpy(dst: [*]u8, src: [*:0]const u8) [*:0]u8 {
    var i: usize = 0;
    while (true) : (i += 1) {
        dst[i] = src[i];
        if (src[i] == 0) {
            break;
        }
    }
    return @ptrCast(dst);
}

pub export fn strcmp(p: [*:0]const u8, q: [*:0]const u8) i32 {
    var i: usize = 0;
    while (p[i] != 0 and p[i] == q[i]) : (i += 1) {}
    return @as(i32, p[i]) - @as(i32, q[i]);
}

pub export fn strlen(s: [*:0]const u8) u32 {
    var n: usize = 0;
    while (s[n] != 0) : (n += 1) {}
    return @intCast(n);
}

pub export fn memset(dst: [*]u8, c: i32, n: u32) ?*anyopaque {
    var i: usize = 0;
    const ch: u8 = @intCast(c & 0xff);
    const nn: usize = @intCast(n);
    while (i < nn) : (i += 1) {
        dst[i] = ch;
    }
    return @ptrCast(dst);
}

pub export fn strchr(s: [*:0]const u8, c: u8) ?[*:0]u8 {
    var i: usize = 0;
    while (s[i] != 0) : (i += 1) {
        if (s[i] == c) {
            return @constCast(s + i);
        }
    }
    return null;
}

pub export fn gets(buf: [*]u8, max: i32) [*:0]u8 {
    var i: i32 = 0;
    var ch: [1]u8 = undefined;
    while (i + 1 < max) {
        const cc = xv6.read(0, &ch, 1);
        if (cc < 1) {
            break;
        }
        buf[@intCast(i)] = ch[0];
        i += 1;
        if (ch[0] == '\n' or ch[0] == '\r') {
            break;
        }
    }
    buf[@intCast(i)] = 0;
    return @ptrCast(buf);
}

pub export fn stat(n: [*:0]const u8, st: *xv6.Stat) i32 {
    const fd = xv6.open(n, xv6.O_RDONLY);
    if (fd < 0) {
        return -1;
    }
    const r = xv6.fstat(fd, st);
    _ = xv6.close(fd);
    return r;
}

pub export fn atoi(s: [*:0]const u8) i32 {
    var i: usize = 0;
    var n: i32 = 0;
    while (s[i] >= '0' and s[i] <= '9') : (i += 1) {
        n = n * 10 + (@as(i32, s[i]) - '0');
    }
    return n;
}

pub export fn memmove(vdst: [*]u8, vsrc: [*]const u8, n: i32) ?*anyopaque {
    if (@intFromPtr(vsrc) > @intFromPtr(vdst)) {
        var i: i32 = 0;
        while (i < n) : (i += 1) {
            const k: usize = @intCast(i);
            vdst[k] = vsrc[k];
        }
    } else {
        var i: i32 = n;
        while (i > 0) {
            i -= 1;
            const k: usize = @intCast(i);
            vdst[k] = vsrc[k];
        }
    }
    return @ptrCast(vdst);
}

pub export fn memcmp(s1: ?*const anyopaque, s2: ?*const anyopaque, n: u32) i32 {
    const p1: [*]const u8 = @ptrCast(s1.?);
    const p2: [*]const u8 = @ptrCast(s2.?);
    var i: usize = 0;
    const nn: usize = @intCast(n);
    while (i < nn) : (i += 1) {
        if (p1[i] != p2[i]) {
            return @as(i32, p1[i]) - @as(i32, p2[i]);
        }
    }
    return 0;
}

pub export fn memcpy(dst: ?*anyopaque, src: ?*const anyopaque, n: u32) ?*anyopaque {
    return memmove(@ptrCast(dst.?), @ptrCast(src.?), @intCast(n));
}

pub export fn sbrk(n: i32) [*]u8 {
    return xv6.sys_sbrk(n, xv6.SBRK_EAGER);
}

pub export fn sbrklazy(n: i32) [*]u8 {
    return xv6.sys_sbrk(n, xv6.SBRK_LAZY);
}
