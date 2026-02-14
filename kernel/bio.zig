const std = @import("std");


const NBUF: u64 = 30;
const BSIZE: u64 = 1024;

const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Sleeplock = extern struct {
    locked: u32,
    lk: Spinlock,
    name: [*c]u8,
    pid: i32,
};

const Buf = extern struct {
    valid: i32,
    disk: i32,
    dev: u32,
    blockno: u32,
    lock: Sleeplock,
    refcnt: u32,
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

extern fn initlock(lk: *Spinlock, name: [*c]u8) void;
extern fn acquire(lk: *Spinlock) void;
extern fn release(lk: *Spinlock) void;
extern fn initsleeplock(lk: *Sleeplock, name: [*c]u8) void;
extern fn acquiresleep(lk: *Sleeplock) void;
extern fn releasesleep(lk: *Sleeplock) void;
extern fn holdingsleep(lk: *Sleeplock) i32;
extern fn panic(s: [*c]const u8) noreturn;
extern fn virtio_disk_rw(b: *Buf, write: i32) void;

pub export fn binit() void {
    initlock(&bcache.lock, @constCast("bcache"));

    bcache.head.prev = &bcache.head;
    bcache.head.next = &bcache.head;

    var i: u64 = 0;
    while (i < NBUF) : (i += 1) {
        const b = &bcache.buf[i];
        b.next = bcache.head.next;
        b.prev = &bcache.head;
        initsleeplock(&b.lock, @constCast("buffer"));
        bcache.head.next.?.prev = b;
        bcache.head.next = b;
    }
}

fn bget(dev: u32, blockno: u32) *Buf {
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

pub export fn bread(dev: u32, blockno: u32) *Buf {
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
