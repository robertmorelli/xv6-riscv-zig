const cint = i32;
const cuint = u32;

pub export fn memset(dst: ?*anyopaque, c: cint, n: cuint) ?*anyopaque {
    const d: [*]u8 = @ptrCast(dst.?);
    const len: usize = @intCast(n);
    const byte: u8 = @truncate(@as(cuint, @bitCast(c)));

    var i: usize = 0;
    while (i < len) : (i += 1) {
        d[i] = byte;
    }
    return dst;
}

pub export fn memcmp(v1: ?*const anyopaque, v2: ?*const anyopaque, n: cuint) cint {
    const s1: [*]const u8 = @ptrCast(v1.?);
    const s2: [*]const u8 = @ptrCast(v2.?);
    const len: usize = @intCast(n);

    var i: usize = 0;
    while (i < len) : (i += 1) {
        if (s1[i] != s2[i]) {
            return @as(cint, s1[i]) - @as(cint, s2[i]);
        }
    }
    return 0;
}

pub export fn memmove(dst: ?*anyopaque, src: ?*const anyopaque, n: cuint) ?*anyopaque {
    if (n == 0) {
        return dst;
    }

    const len: usize = @intCast(n);
    const s: [*]const u8 = @ptrCast(src.?);
    const d: [*]u8 = @ptrCast(dst.?);

    if (@intFromPtr(s) < @intFromPtr(d) and @intFromPtr(s) + len > @intFromPtr(d)) {
        var i: usize = len;
        while (i > 0) {
            i -= 1;
            d[i] = s[i];
        }
    } else {
        var i: usize = 0;
        while (i < len) : (i += 1) {
            d[i] = s[i];
        }
    }

    return dst;
}

// memcpy exists for compiler-generated calls. It aliases memmove behavior.
pub export fn memcpy(dst: ?*anyopaque, src: ?*const anyopaque, n: cuint) ?*anyopaque {
    return memmove(dst, src, n);
}

pub export fn strncmp(p: [*c]const u8, q: [*c]const u8, n: cuint) cint {
    const len: usize = @intCast(n);
    var i: usize = 0;
    while (i < len and p[i] != 0 and p[i] == q[i]) : (i += 1) {}

    if (i == len) {
        return 0;
    }
    return @as(cint, p[i]) - @as(cint, q[i]);
}

pub export fn strncpy(s: [*c]u8, t: [*c]const u8, n: cint) [*c]u8 {
    if (n <= 0) {
        return s;
    }

    const len: usize = @intCast(n);
    var i: usize = 0;
    while (i < len and t[i] != 0) : (i += 1) {
        s[i] = t[i];
    }
    while (i < len) : (i += 1) {
        s[i] = 0;
    }

    return s;
}

pub export fn safestrcpy(s: [*c]u8, t: [*c]const u8, n: cint) [*c]u8 {
    if (n <= 0) {
        return s;
    }

    const len: usize = @intCast(n);
    var i: usize = 0;
    while (i + 1 < len and t[i] != 0) : (i += 1) {
        s[i] = t[i];
    }
    s[i] = 0;

    return s;
}

pub export fn strlen(s: [*c]const u8) cint {
    var n: usize = 0;
    while (s[n] != 0) : (n += 1) {}
    return @intCast(n);
}
