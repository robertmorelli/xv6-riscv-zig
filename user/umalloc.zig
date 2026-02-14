const xv6 = @import("xv6.zig");

const Header = extern struct {
    ptr: ?*Header,
    size: u32,
};

const SBRK_ERROR: u64 = ~@as(u64, 0);

var base: Header = .{ .ptr = null, .size = 0 };
var freep: ?*Header = null;

fn ptrAddr(p: *Header) u64 {
    return @intFromPtr(p);
}

pub export fn free(ap: ?*anyopaque) void {
    if (ap == null) return;

    var bp_many: [*]Header = @ptrCast(@alignCast(ap.?));
    bp_many -= 1;
    const bp: *Header = @ptrCast(bp_many);

    var p = freep.?;
    while (!(ptrAddr(bp) > ptrAddr(p) and ptrAddr(bp) < ptrAddr(p.ptr.?))) : (p = p.ptr.?) {
        if (ptrAddr(p) >= ptrAddr(p.ptr.?) and (ptrAddr(bp) > ptrAddr(p) or ptrAddr(bp) < ptrAddr(p.ptr.?))) {
            break;
        }
    }

    if (@intFromPtr(bp_many + bp.size) == @intFromPtr(p.ptr.?)) {
        bp.size += p.ptr.?.size;
        bp.ptr = p.ptr.?.ptr;
    } else {
        bp.ptr = p.ptr;
    }

    const p_many: [*]Header = @ptrCast(p);
    if (@intFromPtr(p_many + p.size) == @intFromPtr(bp)) {
        p.size += bp.size;
        p.ptr = bp.ptr;
    } else {
        p.ptr = bp;
    }

    freep = p;
}

fn morecore(nu0: u32) ?*Header {
    var nu = nu0;
    if (nu < 4096) nu = 4096;

    const p = xv6.sbrk(@intCast(@as(u64, nu) * @sizeOf(Header)));
    if (@intFromPtr(p) == SBRK_ERROR) return null;

    const hp: *Header = @ptrCast(@alignCast(p));
    hp.size = nu;
    free(@ptrCast(@as([*]Header, @ptrCast(hp)) + 1));
    return freep;
}

pub export fn malloc(nbytes: u32) ?*anyopaque {
    const nunits: u32 = @intCast((@as(u64, nbytes) + @sizeOf(Header) - 1) / @sizeOf(Header) + 1);

    if (freep == null) {
        base.ptr = &base;
        base.size = 0;
        freep = &base;
    }

    var prevp = freep.?;
    var p = prevp.ptr.?;

    while (true) {
        if (p.size >= nunits) {
            if (p.size == nunits) {
                prevp.ptr = p.ptr;
            } else {
                p.size -= nunits;
                var pm: [*]Header = @ptrCast(p);
                pm += p.size;
                p = @ptrCast(pm);
                p.size = nunits;
            }
            freep = prevp;
            return @ptrCast(@as([*]Header, @ptrCast(p)) + 1);
        }

        if (@intFromPtr(p) == @intFromPtr(freep.?)) {
            p = morecore(nunits) orelse return null;
        }

        prevp = p;
        p = p.ptr.?;
    }
}
