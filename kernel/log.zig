
const MAXOPBLOCKS: i32 = 10;
const LOGBLOCKS: u64 = MAXOPBLOCKS * 3;
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

const Superblock = extern struct {
    magic: u32,
    size: u32,
    nblocks: u32,
    ninodes: u32,
    nlog: u32,
    logstart: u32,
    inodestart: u32,
    bmapstart: u32,
};

const Logheader = extern struct {
    n: i32,
    block: [LOGBLOCKS]i32,
};

const Log = extern struct {
    lock: Spinlock,
    start: i32,
    outstanding: i32,
    committing: i32,
    dev: i32,
    lh: Logheader,
};

var log: Log = undefined;

extern fn panic(s: [*c]const u8) noreturn;
extern fn initlock(lk: *Spinlock, name: [*c]u8) void;
extern fn acquire(lk: *Spinlock) void;
extern fn release(lk: *Spinlock) void;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) void;
extern fn wakeup(chan: ?*anyopaque) void;
extern fn printf(fmt: [*:0]const u8, ...) i32;
extern fn bread(dev: u32, blockno: u32) *Buf;
extern fn bwrite(b: *Buf) void;
extern fn brelse(b: *Buf) void;
extern fn bpin(b: *Buf) void;
extern fn bunpin(b: *Buf) void;
extern fn memmove(dst: ?*anyopaque, src: ?*const anyopaque, n: u32) ?*anyopaque;

fn install_trans(recovering: i32) void {
    var tail: i32 = 0;
    while (tail < log.lh.n) : (tail += 1) {
        if (recovering != 0) {
            _ = printf("recovering tail %d dst %d\n", tail, log.lh.block[@intCast(@as(u32, @intCast(tail)))]);
        }
        const lbuf = bread(@intCast(@as(u32, @intCast(log.dev))), @intCast(@as(u32, @intCast(log.start + tail + 1))));
        const dbuf = bread(@intCast(@as(u32, @intCast(log.dev))), @intCast(@as(u32, @intCast(log.lh.block[@intCast(@as(u32, @intCast(tail)))]))));
        _ = memmove(@ptrCast(&dbuf.data), @ptrCast(&lbuf.data), BSIZE);
        bwrite(dbuf);
        if (recovering == 0) {
            bunpin(dbuf);
        }
        brelse(lbuf);
        brelse(dbuf);
    }
}

fn read_head() void {
    const buf = bread(@intCast(@as(u32, @intCast(log.dev))), @intCast(@as(u32, @intCast(log.start))));
    const lh: *Logheader = @alignCast(@ptrCast(&buf.data));
    log.lh.n = lh.n;
    var i: i32 = 0;
    while (i < log.lh.n) : (i += 1) {
        log.lh.block[@intCast(@as(u32, @intCast(i)))] = lh.block[@intCast(@as(u32, @intCast(i)))];
    }
    brelse(buf);
}

fn write_head() void {
    const buf = bread(@intCast(@as(u32, @intCast(log.dev))), @intCast(@as(u32, @intCast(log.start))));
    const hb: *Logheader = @alignCast(@ptrCast(&buf.data));
    hb.n = log.lh.n;
    var i: i32 = 0;
    while (i < log.lh.n) : (i += 1) {
        hb.block[@intCast(@as(u32, @intCast(i)))] = log.lh.block[@intCast(@as(u32, @intCast(i)))];
    }
    bwrite(buf);
    brelse(buf);
}

fn recover_from_log() void {
    read_head();
    install_trans(1);
    log.lh.n = 0;
    write_head();
}

fn write_log() void {
    var tail: i32 = 0;
    while (tail < log.lh.n) : (tail += 1) {
        const to = bread(@intCast(@as(u32, @intCast(log.dev))), @intCast(@as(u32, @intCast(log.start + tail + 1))));
        const from = bread(@intCast(@as(u32, @intCast(log.dev))), @intCast(@as(u32, @intCast(log.lh.block[@intCast(@as(u32, @intCast(tail)))]))));
        _ = memmove(@ptrCast(&to.data), @ptrCast(&from.data), BSIZE);
        bwrite(to);
        brelse(from);
        brelse(to);
    }
}

fn commit() void {
    if (log.lh.n > 0) {
        write_log();
        write_head();
        install_trans(0);
        log.lh.n = 0;
        write_head();
    }
}

pub export fn initlog(dev: i32, sb: *Superblock) void {
    if (@sizeOf(Logheader) >= BSIZE) {
        panic("initlog: too big logheader");
    }
    initlock(&log.lock, @constCast("log"));
    log.start = @intCast(sb.logstart);
    log.dev = dev;
    recover_from_log();
}

pub export fn begin_op() void {
    acquire(&log.lock);
    while (true) {
        if (log.committing != 0) {
            sleep(@ptrCast(&log), &log.lock);
        } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
            sleep(@ptrCast(&log), &log.lock);
        } else {
            log.outstanding += 1;
            release(&log.lock);
            break;
        }
    }
}

pub export fn end_op() void {
    var do_commit: i32 = 0;

    acquire(&log.lock);
    log.outstanding -= 1;
    if (log.committing != 0) {
        panic("log.committing");
    }
    if (log.outstanding == 0) {
        do_commit = 1;
        log.committing = 1;
    } else {
        wakeup(@ptrCast(&log));
    }
    release(&log.lock);

    if (do_commit != 0) {
        commit();
        acquire(&log.lock);
        log.committing = 0;
        wakeup(@ptrCast(&log));
        release(&log.lock);
    }
}

pub export fn log_write(b: *Buf) void {
    acquire(&log.lock);
    if (log.lh.n >= LOGBLOCKS) {
        panic("too big a transaction");
    }
    if (log.outstanding < 1) {
        panic("log_write outside of trans");
    }

    var i: i32 = 0;
    while (i < log.lh.n) : (i += 1) {
        if (log.lh.block[@intCast(@as(u32, @intCast(i)))] == @as(i32, @intCast(b.blockno))) {
            break;
        }
    }
    log.lh.block[@intCast(@as(u32, @intCast(i)))] = @intCast(b.blockno);
    if (i == log.lh.n) {
        bpin(b);
        log.lh.n += 1;
    }
    release(&log.lock);
}
