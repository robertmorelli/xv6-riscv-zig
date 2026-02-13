const std = @import("std");

const cint = i32;
const cuint = u32;

const NINODE: usize = 50;
const ROOTDEV: cuint = 1;
const ROOTINO: cuint = 1;
const BSIZE: usize = 1024;
const BSIZE_U32: cuint = 1024;
const FSMAGIC: cuint = 0x10203040;
const NDIRECT: usize = 12;
const NINDIRECT: usize = BSIZE / @sizeOf(cuint);
const MAXFILE: usize = NDIRECT + NINDIRECT;
const IPB: usize = BSIZE / @sizeOf(Dinode);
const BPB: cuint = BSIZE * 8;
const DIRSIZ: usize = 14;
const T_DIR: i16 = 1;

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

const Dinode = extern struct {
    type: i16,
    major: i16,
    minor: i16,
    nlink: i16,
    size: cuint,
    addrs: [NDIRECT + 1]cuint,
};

const Inode = extern struct {
    dev: cuint,
    inum: cuint,
    ref: cint,
    lock: Sleeplock,
    valid: cint,
    type: i16,
    major: i16,
    minor: i16,
    nlink: i16,
    size: cuint,
    addrs: [NDIRECT + 1]cuint,
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

const Dirent = extern struct {
    inum: u16,
    name: [DIRSIZ]u8,
};

const Stat = extern struct {
    dev: cint,
    ino: cuint,
    type: i16,
    nlink: i16,
    size: u64,
};

const Context = extern struct {
    ra: u64,
    sp: u64,
    s0: u64,
    s1: u64,
    s2: u64,
    s3: u64,
    s4: u64,
    s5: u64,
    s6: u64,
    s7: u64,
    s8: u64,
    s9: u64,
    s10: u64,
    s11: u64,
};

const Proc = extern struct {
    lock: Spinlock,
    state: cint,
    chan: ?*anyopaque,
    killed: cint,
    xstate: cint,
    pid: cint,
    parent: ?*Proc,
    kstack: u64,
    sz: u64,
    pagetable: ?*anyopaque,
    trapframe: ?*anyopaque,
    context: Context,
    ofile: [16]?*anyopaque,
    cwd: ?*Inode,
    name: [16]u8,
};

const ITable = extern struct {
    lock: Spinlock,
    inode: [NINODE]Inode,
};

pub export var sb: Superblock = std.mem.zeroes(Superblock);
var itable: ITable = std.mem.zeroes(ITable);

extern fn bread(dev: cuint, blockno: cuint) callconv(.c) *Buf;
extern fn brelse(b: *Buf) callconv(.c) void;
extern fn log_write(b: *Buf) callconv(.c) void;
extern fn initlog(dev: cint, sb_in: *Superblock) callconv(.c) void;
extern fn panic(s: [*c]const u8) callconv(.c) noreturn;
extern fn printf(fmt: [*c]const u8, ...) callconv(.c) cint;
extern fn initlock(lk: *Spinlock, name: [*c]u8) callconv(.c) void;
extern fn acquire(lk: *Spinlock) callconv(.c) void;
extern fn release(lk: *Spinlock) callconv(.c) void;
extern fn initsleeplock(lk: *Sleeplock, name: [*c]u8) callconv(.c) void;
extern fn acquiresleep(lk: *Sleeplock) callconv(.c) void;
extern fn releasesleep(lk: *Sleeplock) callconv(.c) void;
extern fn holdingsleep(lk: *Sleeplock) callconv(.c) cint;
extern fn begin_op() callconv(.c) void;
extern fn end_op() callconv(.c) void;
extern fn either_copyout(user_dst: cint, dst: u64, src: ?*anyopaque, len: u64) callconv(.c) cint;
extern fn either_copyin(dst: ?*anyopaque, user_src: cint, src: u64, len: u64) callconv(.c) cint;
extern fn memmove(dst: ?*anyopaque, src: ?*const anyopaque, n: cuint) callconv(.c) ?*anyopaque;
extern fn memset(dst: ?*anyopaque, c: cint, n: cuint) callconv(.c) ?*anyopaque;
extern fn strncmp(p: [*c]const u8, q: [*c]const u8, n: cuint) callconv(.c) cint;
extern fn strncpy(s: [*c]u8, t: [*c]const u8, n: cuint) callconv(.c) [*c]u8;
extern fn myproc() callconv(.c) ?*Proc;

inline fn iblock(i: cuint) cuint {
    return @intCast(i / IPB + sb.inodestart);
}

inline fn bblock(b: cuint) cuint {
    return @intCast(b / BPB + sb.bmapstart);
}

inline fn min_u32(a: cuint, b: cuint) cuint {
    return if (a < b) a else b;
}

fn readsb(dev: cint, sb_out: *Superblock) void {
    const bp = bread(@intCast(@as(cuint, @intCast(dev))), 1);
    _ = memmove(sb_out, @ptrCast(&bp.data), @intCast(@sizeOf(Superblock)));
    brelse(bp);
}

pub export fn fsinit(dev: cint) void {
    readsb(dev, &sb);
    if (sb.magic != FSMAGIC) {
        panic("invalid file system");
    }
    initlog(dev, &sb);
    ireclaim(dev);
}

fn bzero(dev: cint, bno: cint) void {
    const bp = bread(@intCast(@as(cuint, @intCast(dev))), @intCast(@as(cuint, @intCast(bno))));
    _ = memset(@ptrCast(&bp.data), 0, BSIZE_U32);
    log_write(bp);
    brelse(bp);
}

fn balloc(dev: cuint) cuint {
    var b: cuint = 0;
    while (b < sb.size) : (b += BPB) {
        const bp = bread(dev, bblock(b));

        var bi: cuint = 0;
        while (bi < BPB and (b + bi) < sb.size) : (bi += 1) {
            const m: u8 = @intCast(@as(cuint, 1) << @intCast(bi % 8));
            const idx: usize = @intCast(bi / 8);
            if ((bp.data[idx] & m) == 0) {
                bp.data[idx] |= m;
                log_write(bp);
                brelse(bp);
                bzero(@intCast(@as(cuint, dev)), @intCast(@as(cuint, b + bi)));
                return b + bi;
            }
        }
        brelse(bp);
    }
    _ = printf("balloc: out of blocks %d\n", @as(cint, 0));
    return 0;
}

fn bfree(dev: cint, b: cuint) void {
    const bp = bread(@intCast(@as(cuint, @intCast(dev))), bblock(b));
    const bi = b % BPB;
    const m: u8 = @intCast(@as(cuint, 1) << @intCast(bi % 8));
    const idx: usize = @intCast(bi / 8);
    if ((bp.data[idx] & m) == 0) {
        panic("freeing free block");
    }
    bp.data[idx] &= ~m;
    log_write(bp);
    brelse(bp);
}

pub export fn iinit() void {
    initlock(&itable.lock, @constCast("itable"));
    var i: usize = 0;
    while (i < NINODE) : (i += 1) {
        initsleeplock(&itable.inode[i].lock, @constCast("inode"));
    }
}

fn iget(dev: cuint, inum: cuint) *Inode {
    acquire(&itable.lock);

    var empty: ?*Inode = null;
    var i: usize = 0;
    while (i < NINODE) : (i += 1) {
        const ip = &itable.inode[i];
        if (ip.ref > 0 and ip.dev == dev and ip.inum == inum) {
            ip.ref += 1;
            release(&itable.lock);
            return ip;
        }
        if (empty == null and ip.ref == 0) {
            empty = ip;
        }
    }

    if (empty == null) {
        panic("iget: no inodes");
    }

    const ip = empty.?;
    ip.dev = dev;
    ip.inum = inum;
    ip.ref = 1;
    ip.valid = 0;
    release(&itable.lock);

    return ip;
}

pub export fn ialloc(dev: cuint, type_: i16) ?*Inode {
    var inum: cuint = 1;
    while (inum < sb.ninodes) : (inum += 1) {
        const bp = bread(dev, iblock(inum));
        const dip_base: [*]Dinode = @alignCast(@ptrCast(&bp.data));
        const dip = &dip_base[@intCast(inum % IPB)];
        if (dip.type == 0) {
            _ = memset(dip, 0, @intCast(@sizeOf(Dinode)));
            dip.type = type_;
            log_write(bp);
            brelse(bp);
            return iget(dev, inum);
        }
        brelse(bp);
    }

    _ = printf("ialloc: no inodes %d\n", @as(cint, 0));
    return null;
}

pub export fn iupdate(ip: *Inode) void {
    const bp = bread(ip.dev, iblock(ip.inum));
    const dip_base: [*]Dinode = @alignCast(@ptrCast(&bp.data));
    const dip = &dip_base[@intCast(ip.inum % IPB)];
    dip.type = ip.type;
    dip.major = ip.major;
    dip.minor = ip.minor;
    dip.nlink = ip.nlink;
    dip.size = ip.size;
    _ = memmove(&dip.addrs, &ip.addrs, @sizeOf([NDIRECT + 1]cuint));
    log_write(bp);
    brelse(bp);
}

pub export fn idup(ip: *Inode) *Inode {
    acquire(&itable.lock);
    ip.ref += 1;
    release(&itable.lock);
    return ip;
}

pub export fn ilock(ip: *Inode) void {
    if (ip.ref < 1) {
        panic("ilock");
    }

    acquiresleep(&ip.lock);

    if (ip.valid == 0) {
        const bp = bread(ip.dev, iblock(ip.inum));
        const dip_base: [*]Dinode = @alignCast(@ptrCast(&bp.data));
        const dip = &dip_base[@intCast(ip.inum % IPB)];
        ip.type = dip.type;
        ip.major = dip.major;
        ip.minor = dip.minor;
        ip.nlink = dip.nlink;
        ip.size = dip.size;
        _ = memmove(&ip.addrs, &dip.addrs, @sizeOf([NDIRECT + 1]cuint));
        brelse(bp);
        ip.valid = 1;
        if (ip.type == 0) {
            panic("ilock: no type");
        }
    }
}

pub export fn iunlock(ip: *Inode) void {
    if (holdingsleep(&ip.lock) == 0 or ip.ref < 1) {
        panic("iunlock");
    }
    releasesleep(&ip.lock);
}

pub export fn iput(ip: *Inode) void {
    acquire(&itable.lock);

    if (ip.ref == 1 and ip.valid != 0 and ip.nlink == 0) {
        acquiresleep(&ip.lock);
        release(&itable.lock);

        itrunc(ip);
        ip.type = 0;
        iupdate(ip);
        ip.valid = 0;

        releasesleep(&ip.lock);
        acquire(&itable.lock);
    }

    ip.ref -= 1;
    release(&itable.lock);
}

pub export fn iunlockput(ip: *Inode) void {
    iunlock(ip);
    iput(ip);
}

pub export fn ireclaim(dev: cint) void {
    var inum: cuint = 1;
    while (inum < sb.ninodes) : (inum += 1) {
        var ip: ?*Inode = null;
        const bp = bread(@intCast(@as(cuint, @intCast(dev))), iblock(inum));
        const dip_base: [*]Dinode = @alignCast(@ptrCast(&bp.data));
        const dip = &dip_base[@intCast(inum % IPB)];
        if (dip.type != 0 and dip.nlink == 0) {
            _ = printf("ireclaim: orphaned inode %d\n", @as(cint, @intCast(inum)));
            ip = iget(@intCast(@as(cuint, @intCast(dev))), inum);
        }
        brelse(bp);
        if (ip != null) {
            begin_op();
            ilock(ip.?);
            iunlock(ip.?);
            iput(ip.?);
            end_op();
        }
    }
}

fn bmap(ip: *Inode, bn_in: cuint) cuint {
    var bn = bn_in;

    if (bn < NDIRECT) {
        if (ip.addrs[bn] == 0) {
            const addr = balloc(ip.dev);
            if (addr == 0) {
                return 0;
            }
            ip.addrs[bn] = addr;
        }
        return ip.addrs[bn];
    }

    bn -= NDIRECT;
    if (bn < NINDIRECT) {
        if (ip.addrs[NDIRECT] == 0) {
            const addr = balloc(ip.dev);
            if (addr == 0) {
                return 0;
            }
            ip.addrs[NDIRECT] = addr;
        }

        const bp = bread(ip.dev, ip.addrs[NDIRECT]);
        const a: [*]cuint = @alignCast(@ptrCast(&bp.data));
        var addr = a[bn];
        if (addr == 0) {
            addr = balloc(ip.dev);
            if (addr != 0) {
                a[bn] = addr;
                log_write(bp);
            }
        }
        brelse(bp);
        return addr;
    }

    panic("bmap: out of range");
}

pub export fn itrunc(ip: *Inode) void {
    var i: usize = 0;
    while (i < NDIRECT) : (i += 1) {
        if (ip.addrs[i] != 0) {
            bfree(@intCast(@as(cuint, ip.dev)), ip.addrs[i]);
            ip.addrs[i] = 0;
        }
    }

    if (ip.addrs[NDIRECT] != 0) {
        const bp = bread(ip.dev, ip.addrs[NDIRECT]);
        const a: [*]cuint = @alignCast(@ptrCast(&bp.data));
        var j: usize = 0;
        while (j < NINDIRECT) : (j += 1) {
            if (a[j] != 0) {
                bfree(@intCast(@as(cuint, ip.dev)), a[j]);
            }
        }
        brelse(bp);
        bfree(@intCast(@as(cuint, ip.dev)), ip.addrs[NDIRECT]);
        ip.addrs[NDIRECT] = 0;
    }

    ip.size = 0;
    iupdate(ip);
}

pub export fn stati(ip: *Inode, st: *Stat) void {
    st.dev = @intCast(ip.dev);
    st.ino = ip.inum;
    st.type = ip.type;
    st.nlink = ip.nlink;
    st.size = ip.size;
}

pub export fn readi(ip: *Inode, user_dst: cint, dst_in: u64, off_in: cuint, n_in: cuint) cint {
    var dst = dst_in;
    var off = off_in;
    var n = n_in;
    var tot: cuint = 0;

    if (off > ip.size or off + n < off) {
        return 0;
    }
    if (off + n > ip.size) {
        n = ip.size - off;
    }

    while (tot < n) {
        const addr = bmap(ip, off / BSIZE_U32);
        if (addr == 0) {
            break;
        }
        const bp = bread(ip.dev, addr);
        const m = min_u32(n - tot, BSIZE_U32 - (off % BSIZE_U32));
        if (either_copyout(user_dst, dst, @ptrCast(&bp.data[@intCast(off % BSIZE)]), m) == -1) {
            brelse(bp);
            return -1;
        }
        brelse(bp);
        tot += m;
        off += m;
        dst += m;
    }

    return @intCast(tot);
}

pub export fn writei(ip: *Inode, user_src: cint, src_in: u64, off_in: cuint, n: cuint) cint {
    var src = src_in;
    var off = off_in;
    var tot: cuint = 0;

    if (off > ip.size or off + n < off) {
        return -1;
    }
    if (off + n > MAXFILE * BSIZE_U32) {
        return -1;
    }

    while (tot < n) {
        const addr = bmap(ip, off / BSIZE_U32);
        if (addr == 0) {
            break;
        }
        const bp = bread(ip.dev, addr);
        const m = min_u32(n - tot, BSIZE_U32 - (off % BSIZE_U32));
        if (either_copyin(@ptrCast(&bp.data[@intCast(off % BSIZE)]), user_src, src, m) == -1) {
            brelse(bp);
            break;
        }
        log_write(bp);
        brelse(bp);

        tot += m;
        off += m;
        src += m;
    }

    if (off > ip.size) {
        ip.size = off;
    }
    iupdate(ip);

    return @intCast(tot);
}

pub export fn namecmp(s: [*c]const u8, t: [*c]const u8) cint {
    return strncmp(s, t, DIRSIZ);
}

pub export fn dirlookup(dp: *Inode, name: [*c]u8, poff: ?*cuint) ?*Inode {
    if (dp.type != T_DIR) {
        panic("dirlookup not DIR");
    }

    var off: cuint = 0;
    var de: Dirent = undefined;
    while (off < dp.size) : (off += @intCast(@sizeOf(Dirent))) {
        if (readi(dp, 0, @intFromPtr(&de), off, @intCast(@sizeOf(Dirent))) != @as(cint, @intCast(@sizeOf(Dirent)))) {
            panic("dirlookup read");
        }
        if (de.inum == 0) {
            continue;
        }
        if (namecmp(name, @ptrCast(&de.name)) == 0) {
            if (poff) |out| {
                out.* = off;
            }
            return iget(dp.dev, de.inum);
        }
    }

    return null;
}

pub export fn dirlink(dp: *Inode, name: [*c]u8, inum: cuint) cint {
    const existing = dirlookup(dp, name, null);
    if (existing != null) {
        iput(existing.?);
        return -1;
    }

    var off: cint = 0;
    var de: Dirent = undefined;
    while (off < @as(cint, @intCast(dp.size))) : (off += @as(cint, @intCast(@sizeOf(Dirent)))) {
        if (readi(dp, 0, @intFromPtr(&de), @intCast(@as(cuint, @intCast(off))), @intCast(@sizeOf(Dirent))) != @as(cint, @intCast(@sizeOf(Dirent)))) {
            panic("dirlink read");
        }
        if (de.inum == 0) {
            break;
        }
    }

    _ = strncpy(@ptrCast(&de.name), name, DIRSIZ);
    de.inum = @intCast(inum);
    if (writei(dp, 0, @intFromPtr(&de), @intCast(@as(cuint, @intCast(off))), @intCast(@sizeOf(Dirent))) != @as(cint, @intCast(@sizeOf(Dirent)))) {
        return -1;
    }
    return 0;
}

fn skipelem(path_in: [*c]u8, name: [*c]u8) [*c]u8 {
    var path = path_in;
    while (path[0] == '/') {
        path += 1;
    }
    if (path[0] == 0) {
        return @ptrFromInt(0);
    }

    const s = path;
    while (path[0] != '/' and path[0] != 0) {
        path += 1;
    }

    const len: cuint = @intCast(@intFromPtr(path) - @intFromPtr(s));
    if (len >= DIRSIZ) {
        _ = memmove(name, s, DIRSIZ);
    } else {
        _ = memmove(name, s, len);
        name[@intCast(len)] = 0;
    }

    while (path[0] == '/') {
        path += 1;
    }
    return path;
}

fn namex(path_in: [*c]u8, want_parent: cint, name: [*c]u8) ?*Inode {
    var ip: ?*Inode = null;
    var path = path_in;

    if (path[0] == '/') {
        ip = iget(ROOTDEV, ROOTINO);
    } else {
        ip = idup(myproc().?.cwd.?);
    }

    while (true) {
        path = skipelem(path, name);
        if (path == @as([*c]u8, @ptrFromInt(0))) {
            break;
        }

        ilock(ip.?);
        if (ip.?.type != T_DIR) {
            iunlockput(ip.?);
            return null;
        }

        if (want_parent != 0 and path[0] == 0) {
            iunlock(ip.?);
            return ip;
        }

        const next = dirlookup(ip.?, name, null);
        if (next == null) {
            iunlockput(ip.?);
            return null;
        }
        iunlockput(ip.?);
        ip = next;
    }

    if (want_parent != 0) {
        iput(ip.?);
        return null;
    }
    return ip;
}

pub export fn namei(path: [*c]u8) ?*Inode {
    var name: [DIRSIZ]u8 = undefined;
    return namex(path, 0, @ptrCast(&name));
}

pub export fn nameiparent(path: [*c]u8, name: [*c]u8) ?*Inode {
    return namex(path, 1, name);
}
