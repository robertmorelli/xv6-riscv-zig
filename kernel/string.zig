
pub export fn memset(dst: ?*anyopaque, c: i32, n: u32) ?*anyopaque {
    const d: [*]u8 = @ptrCast(dst.?);
    const len: u64 = @intCast(n);
    const byte: u8 = @truncate(@as(u32, @bitCast(c)));

    var i: u64 = 0;
    while (i < len) : (i += 1) {
        d[i] = byte;
    }
    return dst;
}

pub export fn memcmp(v1: ?*const anyopaque, v2: ?*const anyopaque, n: u32) i32 {
    const s1: [*]const u8 = @ptrCast(v1.?);
    const s2: [*]const u8 = @ptrCast(v2.?);
    const len: u64 = @intCast(n);

    var i: u64 = 0;
    while (i < len) : (i += 1) {
        if (s1[i] != s2[i]) {
            return @as(i32, s1[i]) - @as(i32, s2[i]);
        }
    }
    return 0;
}

pub export fn memmove(dst: ?*anyopaque, src: ?*const anyopaque, n: u32) ?*anyopaque {
    if (n == 0) {
        return dst;
    }

    const len: u64 = @intCast(n);
    const s: [*]const u8 = @ptrCast(src.?);
    const d: [*]u8 = @ptrCast(dst.?);

    if (@intFromPtr(s) < @intFromPtr(d) and @intFromPtr(s) + len > @intFromPtr(d)) {
        var i: u64 = len;
        while (i > 0) {
            i -= 1;
            d[i] = s[i];
        }
    } else {
        var i: u64 = 0;
        while (i < len) : (i += 1) {
            d[i] = s[i];
        }
    }

    return dst;
}

// memcpy exists for compiler-generated calls. It aliases memmove behavior.
pub export fn memcpy(dst: ?*anyopaque, src: ?*const anyopaque, n: u32) ?*anyopaque {
    return memmove(dst, src, n);
}

pub export fn strncmp(p: [*c]const u8, q: [*c]const u8, n: u32) i32 {
    const len: u64 = @intCast(n);
    var i: u64 = 0;
    while (i < len and p[i] != 0 and p[i] == q[i]) : (i += 1) {}

    if (i == len) {
        return 0;
    }
    return @as(i32, p[i]) - @as(i32, q[i]);
}

pub export fn strncpy(s: [*c]u8, t: [*c]const u8, n: i32) [*c]u8 {
    if (n <= 0) {
        return s;
    }

    const len: u64 = @intCast(n);
    var i: u64 = 0;
    while (i < len and t[i] != 0) : (i += 1) {
        s[i] = t[i];
    }
    while (i < len) : (i += 1) {
        s[i] = 0;
    }

    return s;
}

pub export fn safestrcpy(s: [*c]u8, t: [*c]const u8, n: i32) [*c]u8 {
    if (n <= 0) {
        return s;
    }

    const len: u64 = @intCast(n);
    var i: u64 = 0;
    while (i + 1 < len and t[i] != 0) : (i += 1) {
        s[i] = t[i];
    }
    s[i] = 0;

    return s;
}

pub export fn strlen(s: [*c]const u8) i32 {
    var n: u64 = 0;
    while (s[n] != 0) : (n += 1) {}
    return @intCast(n);
}
