const std = @import("std");

const cint = i32;
const cuint = u32;

const NBUF: usize = 30;
const BSIZE: usize = 1024;

const Spinlock = extern struct {
    locked: cuint,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Sleeplock = extern struct {
    locked: cuint,
    lk: Spinlock,
    name: [*c]u8,
    pid: cint,
};

const Buf = extern struct {
    valid: cint,
    disk: cint,
    dev: cuint,
    blockno: cuint,
    lock: Sleeplock,
    refcnt: cuint,
    prev: ?*Buf,
    next: ?*Buf,
    data: [BSIZE]u8,
};

const Bcache = extern struct {
    lock: Spinlock,
    buf: [NBUF]Buf,
    head: Buf,
};

var bcache: Bcache = std.mem.zeroes(Bcache);

extern fn initlock(lk: *Spinlock, name: [*c]u8) callconv(.c) void;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;
extern fn initsleeplock(lk: *Sleeplock, name: [*c]u8) callconv(.c) void;
extern fn acquiresleep(lk: *Sleeplock) callconv(.c) void;
extern fn releasesleep(lk: *Sleeplock) callconv(.c) void;
extern fn holdingsleep(lk: *Sleeplock) callconv(.c) cint;
extern fn panic(s: [*c]const u8) callconv(.c) noreturn;
extern fn virtio_disk_rw(b: *Buf, write: cint) callconv(.c) void;

pub export fn binit() void {
    initlock(&bcache.lock, @constCast("bcache"));

    bcache.head.prev = &bcache.head;
    bcache.head.next = &bcache.head;

    var i: usize = 0;
    while (i < NBUF) : (i += 1) {
        const b = &bcache.buf[i];
        b.next = bcache.head.next;
        b.prev = &bcache.head;
        initsleeplock(&b.lock, @constCast("buffer"));
        bcache.head.next.?.prev = b;
        bcache.head.next = b;
    }
}

fn bget(dev: cuint, blockno: cuint) *Buf {
    acquire(&bcache.lock);

    var b = bcache.head.next.?;
    while (b != &bcache.head) : (b = b.next.?) {
        if (b.dev == dev and b.blockno == blockno) {
            b.refcnt += 1;
            release(&bcache.lock);
            acquiresleep(&b.lock);
            return b;
        }
    }

    b = bcache.head.prev.?;
    while (b != &bcache.head) : (b = b.prev.?) {
        if (b.refcnt == 0) {
            b.dev = dev;
            b.blockno = blockno;
            b.valid = 0;
            b.refcnt = 1;
            release(&bcache.lock);
            acquiresleep(&b.lock);
            return b;
        }
    }

    panic("bget: no buffers");
}

pub export fn bread(dev: cuint, blockno: cuint) *Buf {
    const b = bget(dev, blockno);
    if (b.valid == 0) {
        virtio_disk_rw(b, 0);
        b.valid = 1;
    }
    return b;
}

pub export fn bwrite(b: *Buf) void {
    if (holdingsleep(&b.lock) == 0) {
        panic("bwrite");
    }
    virtio_disk_rw(b, 1);
}

pub export fn brelse(b: *Buf) void {
    if (holdingsleep(&b.lock) == 0) {
        panic("brelse");
    }

    releasesleep(&b.lock);

    acquire(&bcache.lock);
    b.refcnt -= 1;
    if (b.refcnt == 0) {
        b.next.?.prev = b.prev;
        b.prev.?.next = b.next;
        b.next = bcache.head.next;
        b.prev = &bcache.head;
        bcache.head.next.?.prev = b;
        bcache.head.next = b;
    }
    release(&bcache.lock);
}

pub export fn bpin(b: *Buf) void {
    acquire(&bcache.lock);
    b.refcnt += 1;
    release(&bcache.lock);
}

pub export fn bunpin(b: *Buf) void {
    acquire(&bcache.lock);
    b.refcnt -= 1;
    release(&bcache.lock);
}
