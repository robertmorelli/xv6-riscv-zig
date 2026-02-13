const cint = i32;
const cuint = u32;

const PGSIZE: usize = 4096;
const KERNBASE: usize = 0x80000000;
const PHYSTOP: usize = KERNBASE + 128 * 1024 * 1024;

const Spinlock = extern struct {
    locked: cuint,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Run = extern struct {
    next: ?*Run,
};

const Kmem = extern struct {
    lock: Spinlock,
    freelist: ?*Run,
};

var kmem: Kmem = undefined;

extern var end: u8;

extern fn initlock(lk: *Spinlock, name: [*c]u8) callconv(.c) void;
extern fn panic(s: [*c]const u8) callconv(.c) noreturn;
extern fn memset(dst: ?*anyopaque, c: cint, n: cuint) callconv(.c) ?*anyopaque;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;

inline fn pgroundup(sz: usize) usize {
    return (sz + PGSIZE - 1) & ~(PGSIZE - 1);
}

fn freerange(pa_start: ?*anyopaque, pa_end: ?*anyopaque) void {
    var p = pgroundup(@intFromPtr(pa_start));
    const end_pa = @intFromPtr(pa_end);
    while (p + PGSIZE <= end_pa) : (p += PGSIZE) {
        kfree(@ptrFromInt(p));
    }
}

pub export fn kinit() void {
    initlock(&kmem.lock, @constCast("kmem"));
    kmem.freelist = null;
    freerange(@ptrCast(&end), @ptrFromInt(PHYSTOP));
}

pub export fn kfree(pa: ?*anyopaque) void {
    const pa_addr = @intFromPtr(pa);
    if ((pa_addr % PGSIZE) != 0 or pa_addr < @intFromPtr(&end) or pa_addr >= PHYSTOP) {
        panic("kfree");
    }

    _ = memset(pa, 1, PGSIZE);
    const r: *Run = @alignCast(@ptrCast(pa.?));

    acquire(&kmem.lock);
    r.next = kmem.freelist;
    kmem.freelist = r;
    release(&kmem.lock);
}

pub export fn kalloc() ?*anyopaque {
    acquire(&kmem.lock);
    const r = kmem.freelist;
    if (r) |rr| {
        kmem.freelist = rr.next;
    }
    release(&kmem.lock);

    if (r) |rr| {
        _ = memset(@ptrCast(rr), 5, PGSIZE);
    }

    return @ptrCast(r);
}
