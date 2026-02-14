const std = @import("std");


const PGSIZE: u32 = 4096;
const BSIZE: u32 = 1024;
const VIRTIO0: u64 = 0x10001000;

const VIRTIO_MMIO_MAGIC_VALUE: u64 = 0x000;
const VIRTIO_MMIO_VERSION: u64 = 0x004;
const VIRTIO_MMIO_DEVICE_ID: u64 = 0x008;
const VIRTIO_MMIO_VENDOR_ID: u64 = 0x00c;
const VIRTIO_MMIO_DEVICE_FEATURES: u64 = 0x010;
const VIRTIO_MMIO_DRIVER_FEATURES: u64 = 0x020;
const VIRTIO_MMIO_QUEUE_SEL: u64 = 0x030;
const VIRTIO_MMIO_QUEUE_NUM_MAX: u64 = 0x034;
const VIRTIO_MMIO_QUEUE_NUM: u64 = 0x038;
const VIRTIO_MMIO_QUEUE_READY: u64 = 0x044;
const VIRTIO_MMIO_QUEUE_NOTIFY: u64 = 0x050;
const VIRTIO_MMIO_INTERRUPT_STATUS: u64 = 0x060;
const VIRTIO_MMIO_INTERRUPT_ACK: u64 = 0x064;
const VIRTIO_MMIO_STATUS: u64 = 0x070;
const VIRTIO_MMIO_QUEUE_DESC_LOW: u64 = 0x080;
const VIRTIO_MMIO_QUEUE_DESC_HIGH: u64 = 0x084;
const VIRTIO_MMIO_DRIVER_DESC_LOW: u64 = 0x090;
const VIRTIO_MMIO_DRIVER_DESC_HIGH: u64 = 0x094;
const VIRTIO_MMIO_DEVICE_DESC_LOW: u64 = 0x0a0;
const VIRTIO_MMIO_DEVICE_DESC_HIGH: u64 = 0x0a4;

const VIRTIO_CONFIG_S_ACKNOWLEDGE: u32 = 1;
const VIRTIO_CONFIG_S_DRIVER: u32 = 2;
const VIRTIO_CONFIG_S_DRIVER_OK: u32 = 4;
const VIRTIO_CONFIG_S_FEATURES_OK: u32 = 8;

const VIRTIO_BLK_F_RO: u6 = 5;
const VIRTIO_BLK_F_SCSI: u6 = 7;
const VIRTIO_BLK_F_CONFIG_WCE: u6 = 11;
const VIRTIO_BLK_F_MQ: u6 = 12;
const VIRTIO_F_ANY_LAYOUT: u6 = 27;
const VIRTIO_RING_F_INDIRECT_DESC: u6 = 28;
const VIRTIO_RING_F_EVENT_IDX: u6 = 29;

const NUM: u64 = 8;
const VRING_DESC_F_NEXT: u16 = 1;
const VRING_DESC_F_WRITE: u16 = 2;

const VIRTIO_BLK_T_IN: u32 = 0;
const VIRTIO_BLK_T_OUT: u32 = 1;

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

const VirtqDesc = extern struct {
    addr: u64,
    len: u32,
    flags: u16,
    next: u16,
};

const VirtqAvail = extern struct {
    flags: u16,
    idx: u16,
    ring: [NUM]u16,
    unused: u16,
};

const VirtqUsedElem = extern struct {
    id: u32,
    len: u32,
};

const VirtqUsed = extern struct {
    flags: u16,
    idx: u16,
    ring: [NUM]VirtqUsedElem,
};

const VirtioBlkReq = extern struct {
    type: u32,
    reserved: u32,
    sector: u64,
};

const DiskInfo = extern struct {
    b: ?*Buf,
    status: u8,
};

const Disk = extern struct {
    desc: ?[*]VirtqDesc,
    avail: ?*VirtqAvail,
    used: ?*VirtqUsed,
    free: [NUM]u8,
    used_idx: u16,
    info: [NUM]DiskInfo,
    ops: [NUM]VirtioBlkReq,
    vdisk_lock: Spinlock,
};

var disk: Disk = std.mem.zeroes(Disk);

extern fn initlock(lk: *Spinlock, name: [*c]u8) void;
extern fn panic(s: [*c]const u8) noreturn;
extern fn kalloc() ?*anyopaque;
extern fn memset(dst: ?*anyopaque, c: i32, n: u32) ?*anyopaque;
extern fn acquire(lk: *Spinlock) void;
extern fn release(lk: *Spinlock) void;
extern fn wakeup(chan: ?*anyopaque) void;
extern fn sleep(chan: ?*anyopaque, lk: *Spinlock) void;

inline fn regPtr(offset: u64) *volatile u32 {
    return @as(*volatile u32, @ptrFromInt(VIRTIO0 + offset));
}

inline fn regRead(offset: u64) u32 {
    return regPtr(offset).*;
}

inline fn regWrite(offset: u64, value: u32) void {
    regPtr(offset).* = value;
}

inline fn sync_synchronize() void {
    asm volatile ("fence rw, rw");
}

pub export fn virtio_disk_init() void {
    var status: u32 = 0;

    initlock(&disk.vdisk_lock, @constCast("virtio_disk"));

    if (regRead(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 or
        regRead(VIRTIO_MMIO_VERSION) != 2 or
        regRead(VIRTIO_MMIO_DEVICE_ID) != 2 or
        regRead(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551)
    {
        panic("could not find virtio disk");
    }

    regWrite(VIRTIO_MMIO_STATUS, status);

    status |= VIRTIO_CONFIG_S_ACKNOWLEDGE;
    regWrite(VIRTIO_MMIO_STATUS, status);

    status |= VIRTIO_CONFIG_S_DRIVER;
    regWrite(VIRTIO_MMIO_STATUS, status);

    var features: u64 = regRead(VIRTIO_MMIO_DEVICE_FEATURES);
    features &= ~(@as(u64, 1) << VIRTIO_BLK_F_RO);
    features &= ~(@as(u64, 1) << VIRTIO_BLK_F_SCSI);
    features &= ~(@as(u64, 1) << VIRTIO_BLK_F_CONFIG_WCE);
    features &= ~(@as(u64, 1) << VIRTIO_BLK_F_MQ);
    features &= ~(@as(u64, 1) << VIRTIO_F_ANY_LAYOUT);
    features &= ~(@as(u64, 1) << VIRTIO_RING_F_EVENT_IDX);
    features &= ~(@as(u64, 1) << VIRTIO_RING_F_INDIRECT_DESC);
    regWrite(VIRTIO_MMIO_DRIVER_FEATURES, @truncate(features));

    status |= VIRTIO_CONFIG_S_FEATURES_OK;
    regWrite(VIRTIO_MMIO_STATUS, status);

    status = regRead(VIRTIO_MMIO_STATUS);
    if ((status & VIRTIO_CONFIG_S_FEATURES_OK) == 0) {
        panic("virtio disk FEATURES_OK unset");
    }

    regWrite(VIRTIO_MMIO_QUEUE_SEL, 0);
    if (regRead(VIRTIO_MMIO_QUEUE_READY) != 0) {
        panic("virtio disk should not be ready");
    }

    const max = regRead(VIRTIO_MMIO_QUEUE_NUM_MAX);
    if (max == 0) {
        panic("virtio disk has no queue 0");
    }
    if (max < NUM) {
        panic("virtio disk max queue too short");
    }

    const desc_mem = kalloc();
    const avail_mem = kalloc();
    const used_mem = kalloc();
    if (desc_mem == null or avail_mem == null or used_mem == null) {
        panic("virtio disk kalloc");
    }

    disk.desc = @ptrCast(@alignCast(desc_mem.?));
    disk.avail = @ptrCast(@alignCast(avail_mem.?));
    disk.used = @ptrCast(@alignCast(used_mem.?));
    _ = memset(disk.desc, 0, PGSIZE);
    _ = memset(disk.avail, 0, PGSIZE);
    _ = memset(disk.used, 0, PGSIZE);

    regWrite(VIRTIO_MMIO_QUEUE_NUM, NUM);

    const desc_pa = @as(u64, @intCast(@intFromPtr(disk.desc)));
    const avail_pa = @as(u64, @intCast(@intFromPtr(disk.avail)));
    const used_pa = @as(u64, @intCast(@intFromPtr(disk.used)));
    regWrite(VIRTIO_MMIO_QUEUE_DESC_LOW, @truncate(desc_pa));
    regWrite(VIRTIO_MMIO_QUEUE_DESC_HIGH, @truncate(desc_pa >> 32));
    regWrite(VIRTIO_MMIO_DRIVER_DESC_LOW, @truncate(avail_pa));
    regWrite(VIRTIO_MMIO_DRIVER_DESC_HIGH, @truncate(avail_pa >> 32));
    regWrite(VIRTIO_MMIO_DEVICE_DESC_LOW, @truncate(used_pa));
    regWrite(VIRTIO_MMIO_DEVICE_DESC_HIGH, @truncate(used_pa >> 32));

    regWrite(VIRTIO_MMIO_QUEUE_READY, 1);

    var i: u64 = 0;
    while (i < NUM) : (i += 1) {
        disk.free[i] = 1;
    }

    status |= VIRTIO_CONFIG_S_DRIVER_OK;
    regWrite(VIRTIO_MMIO_STATUS, status);
}

fn alloc_desc() i32 {
    var i: u64 = 0;
    while (i < NUM) : (i += 1) {
        if (disk.free[i] != 0) {
            disk.free[i] = 0;
            return @intCast(i);
        }
    }
    return -1;
}

fn free_desc(i: i32) void {
    if (i >= NUM) {
        panic("free_desc 1");
    }
    const idx: u64 = @intCast(i);
    if (disk.free[idx] != 0) {
        panic("free_desc 2");
    }
    disk.desc.?[idx].addr = 0;
    disk.desc.?[idx].len = 0;
    disk.desc.?[idx].flags = 0;
    disk.desc.?[idx].next = 0;
    disk.free[idx] = 1;
    wakeup(@ptrCast(&disk.free[0]));
}

fn free_chain(head_idx: i32) void {
    var i = head_idx;
    while (true) {
        const idx: u64 = @intCast(i);
        const flag = disk.desc.?[idx].flags;
        const nxt: i32 = @intCast(disk.desc.?[idx].next);
        free_desc(i);
        if ((flag & VRING_DESC_F_NEXT) != 0) {
            i = nxt;
        } else {
            break;
        }
    }
}

fn alloc3_desc(idx: *[3]i32) i32 {
    var i: u64 = 0;
    while (i < 3) : (i += 1) {
        idx[i] = alloc_desc();
        if (idx[i] < 0) {
            var j: u64 = 0;
            while (j < i) : (j += 1) {
                free_desc(idx[j]);
            }
            return -1;
        }
    }
    return 0;
}

pub export fn virtio_disk_rw(b: *Buf, write: i32) void {
    const sector = @as(u64, @intCast(b.blockno)) * (BSIZE / 512);

    acquire(&disk.vdisk_lock);

    var idx: [3]i32 = undefined;
    while (alloc3_desc(&idx) != 0) {
        sleep(@ptrCast(&disk.free[0]), &disk.vdisk_lock);
    }

    const head: u64 = @intCast(idx[0]);
    const buf0 = &disk.ops[head];
    if (write != 0) {
        buf0.type = VIRTIO_BLK_T_OUT;
    } else {
        buf0.type = VIRTIO_BLK_T_IN;
    }
    buf0.reserved = 0;
    buf0.sector = sector;

    disk.desc.?[head].addr = @intFromPtr(buf0);
    disk.desc.?[head].len = @sizeOf(VirtioBlkReq);
    disk.desc.?[head].flags = VRING_DESC_F_NEXT;
    disk.desc.?[head].next = @intCast(idx[1]);

    const mid: u64 = @intCast(idx[1]);
    disk.desc.?[mid].addr = @intFromPtr(&b.data);
    disk.desc.?[mid].len = BSIZE;
    if (write != 0) {
        disk.desc.?[mid].flags = 0;
    } else {
        disk.desc.?[mid].flags = VRING_DESC_F_WRITE;
    }
    disk.desc.?[mid].flags |= VRING_DESC_F_NEXT;
    disk.desc.?[mid].next = @intCast(idx[2]);

    disk.info[head].status = 0xff;
    const tail: u64 = @intCast(idx[2]);
    disk.desc.?[tail].addr = @intFromPtr(&disk.info[head].status);
    disk.desc.?[tail].len = 1;
    disk.desc.?[tail].flags = VRING_DESC_F_WRITE;
    disk.desc.?[tail].next = 0;

    b.disk = 1;
    disk.info[head].b = b;

    const avail_slot: u64 = @intCast(disk.avail.?.idx % NUM);
    disk.avail.?.ring[avail_slot] = @intCast(idx[0]);

    sync_synchronize();

    disk.avail.?.idx +%= 1;

    sync_synchronize();

    regWrite(VIRTIO_MMIO_QUEUE_NOTIFY, 0);

    while (b.disk == 1) {
        sleep(b, &disk.vdisk_lock);
    }

    disk.info[head].b = null;
    free_chain(idx[0]);

    release(&disk.vdisk_lock);
}

pub export fn virtio_disk_intr() void {
    acquire(&disk.vdisk_lock);

    regWrite(VIRTIO_MMIO_INTERRUPT_ACK, regRead(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3);

    sync_synchronize();

    while (disk.used_idx != disk.used.?.idx) {
        sync_synchronize();
        const id: u64 = @intCast(disk.used.?.ring[disk.used_idx % NUM].id);

        if (disk.info[id].status != 0) {
            panic("virtio_disk_intr status");
        }

        const b = disk.info[id].b.?;
        b.disk = 0;
        wakeup(b);

        disk.used_idx +%= 1;
    }

    release(&disk.vdisk_lock);
}
