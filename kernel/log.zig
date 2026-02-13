const cint = i32;
const cuint = u32;

const MAXOPBLOCKS: cint = 10;
const LOGBLOCKS: usize = MAXOPBLOCKS * 3;
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

const Superblock = extern struct {
    magic: cuint,
    size: cuint,
    nblocks: cuint,
    ninodes: cuint,
    nlog: cuint,
    logstart: cuint,
    inodestart: cuint,
    bmapstart: cuint,
};

const Logheader = extern struct {
    n: cint,
    block: [LOGBLOCKS]cint,
};

const Log = extern struct {
    lock: Spinlock,
    start: cint,
    outstanding: cint,
    committing: cint,
    dev: cint,
    lh: Logheader,
};

var log: Log = undefined;

extern fn panic(s: [*c]const u8) callconv(.c) noreturn;
extern fn initlock(lk: *Spinlock, name: [*c]u8) callconv(.c) void;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) callconv(.c) void;
extern fn wakeup(chan: ?*anyopaque) callconv(.c) void;
extern fn printf(fmt: [*:0]const u8, ...) callconv(.c) cint;
extern fn bread(dev: cuint, blockno: cuint) callconv(.c) *Buf;
extern fn bwrite(b: *Buf) callconv(.c) void;
extern fn brelse(b: *Buf) callconv(.c) void;
extern fn bpin(b: *Buf) callconv(.c) void;
extern fn bunpin(b: *Buf) callconv(.c) void;
extern fn memmove(dst: ?*anyopaque, src: ?*const anyopaque, n: cuint) callconv(.c) ?*anyopaque;

fn install_trans(recovering: cint) void {
    var tail: cint = 0;
    while (tail < log.lh.n) : (tail += 1) {
        if (recovering != 0) {
            _ = printf("recovering tail %d dst %d\n", tail, log.lh.block[@intCast(@as(cuint, @intCast(tail)))]);
        }
        const lbuf = bread(@intCast(@as(cuint, @intCast(log.dev))), @intCast(@as(cuint, @intCast(log.start + tail + 1))));
        const dbuf = bread(@intCast(@as(cuint, @intCast(log.dev))), @intCast(@as(cuint, @intCast(log.lh.block[@intCast(@as(cuint, @intCast(tail)))]))));
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
    const buf = bread(@intCast(@as(cuint, @intCast(log.dev))), @intCast(@as(cuint, @intCast(log.start))));
    const lh: *Logheader = @alignCast(@ptrCast(&buf.data));
    log.lh.n = lh.n;
    var i: cint = 0;
    while (i < log.lh.n) : (i += 1) {
        log.lh.block[@intCast(@as(cuint, @intCast(i)))] = lh.block[@intCast(@as(cuint, @intCast(i)))];
    }
    brelse(buf);
}

fn write_head() void {
    const buf = bread(@intCast(@as(cuint, @intCast(log.dev))), @intCast(@as(cuint, @intCast(log.start))));
    const hb: *Logheader = @alignCast(@ptrCast(&buf.data));
    hb.n = log.lh.n;
    var i: cint = 0;
    while (i < log.lh.n) : (i += 1) {
        hb.block[@intCast(@as(cuint, @intCast(i)))] = log.lh.block[@intCast(@as(cuint, @intCast(i)))];
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
    var tail: cint = 0;
    while (tail < log.lh.n) : (tail += 1) {
        const to = bread(@intCast(@as(cuint, @intCast(log.dev))), @intCast(@as(cuint, @intCast(log.start + tail + 1))));
        const from = bread(@intCast(@as(cuint, @intCast(log.dev))), @intCast(@as(cuint, @intCast(log.lh.block[@intCast(@as(cuint, @intCast(tail)))]))));
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

pub export fn initlog(dev: cint, sb: *Superblock) void {
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
    var do_commit: cint = 0;

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

    var i: cint = 0;
    while (i < log.lh.n) : (i += 1) {
        if (log.lh.block[@intCast(@as(cuint, @intCast(i)))] == @as(cint, @intCast(b.blockno))) {
            break;
        }
    }
    log.lh.block[@intCast(@as(cuint, @intCast(i)))] = @intCast(b.blockno);
    if (i == log.lh.n) {
        bpin(b);
        log.lh.n += 1;
    }
    release(&log.lock);
}
