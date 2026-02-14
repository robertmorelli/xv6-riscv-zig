pub const uint = u32;
pub const ushort = u16;
pub const uchar = u8;
pub const uint8 = u8;
pub const uint16 = u16;
pub const uint32 = u32;
pub const uint64 = u64;
pub const pde_t = uint64;
pub const struct_stat = extern struct {
    dev: i32 = @import("std").mem.zeroes(i32),
    ino: uint = @import("std").mem.zeroes(uint),
    type: i16 = @import("std").mem.zeroes(i16),
    nlink: i16 = @import("std").mem.zeroes(i16),
    size: uint64 = @import("std").mem.zeroes(uint64),
};
pub extern fn fork() i32;
pub extern fn exit(i32) noreturn;
pub extern fn wait([*c]i32) i32;
pub extern fn pipe([*c]i32) i32;
pub extern fn write(i32, ?*const anyopaque, i32) i32;
pub extern fn read(i32, ?*anyopaque, i32) i32;
pub extern fn close(i32) i32;
pub extern fn kill(i32) i32;
pub extern fn exec([*c]const u8, [*c][*c]u8) i32;
pub extern fn open([*c]const u8, i32) i32;
pub extern fn mknod([*c]const u8, i16, i16) i32;
pub extern fn unlink([*c]const u8) i32;
pub extern fn fstat(fd: i32, [*c]struct_stat) i32;
pub extern fn link([*c]const u8, [*c]const u8) i32;
pub extern fn mkdir([*c]const u8) i32;
pub extern fn chdir([*c]const u8) i32;
pub extern fn dup(i32) i32;
pub extern fn getpid() i32;
pub extern fn sys_sbrk(i32, i32) [*c]u8;
pub extern fn pause(i32) i32;
pub extern fn uptime() i32;
pub extern fn stat([*c]const u8, [*c]struct_stat) i32;
pub extern fn strcpy([*c]u8, [*c]const u8) [*c]u8;
pub extern fn memmove(?*anyopaque, ?*const anyopaque, i32) ?*anyopaque;
pub extern fn strchr([*c]const u8, c: u8) [*c]u8;
pub extern fn strcmp([*c]const u8, [*c]const u8) i32;
pub extern fn gets([*c]u8, max: i32) [*c]u8;
pub extern fn strlen([*c]const u8) uint;
pub extern fn memset(?*anyopaque, i32, uint) ?*anyopaque;
pub extern fn atoi([*c]const u8) i32;
pub extern fn memcmp(?*const anyopaque, ?*const anyopaque, uint) i32;
pub extern fn memcpy(?*anyopaque, ?*const anyopaque, uint) ?*anyopaque;
pub extern fn sbrk(i32) [*c]u8;
pub extern fn sbrklazy(i32) [*c]u8;
pub extern fn fprintf(i32, [*c]const u8, ...) void;
pub extern fn printf([*c]const u8, ...) void;
pub extern fn malloc(uint) ?*anyopaque;
pub extern fn free(?*anyopaque) void;
pub const struct_superblock = extern struct {
    magic: uint = @import("std").mem.zeroes(uint),
    size: uint = @import("std").mem.zeroes(uint),
    nblocks: uint = @import("std").mem.zeroes(uint),
    ninodes: uint = @import("std").mem.zeroes(uint),
    nlog: uint = @import("std").mem.zeroes(uint),
    logstart: uint = @import("std").mem.zeroes(uint),
    inodestart: uint = @import("std").mem.zeroes(uint),
    bmapstart: uint = @import("std").mem.zeroes(uint),
};
pub const struct_dinode = extern struct {
    type: i16 = @import("std").mem.zeroes(i16),
    major: i16 = @import("std").mem.zeroes(i16),
    minor: i16 = @import("std").mem.zeroes(i16),
    nlink: i16 = @import("std").mem.zeroes(i16),
    size: uint = @import("std").mem.zeroes(uint),
    addrs: [13]uint = @import("std").mem.zeroes([13]uint),
};
pub const struct_dirent = extern struct {
    inum: ushort = @import("std").mem.zeroes(ushort),
    name: [14]u8 = @import("std").mem.zeroes([14]u8),
};

pub extern fn r_mhartid() uint64;

pub extern fn r_mstatus() uint64;

pub extern fn w_mstatus(arg_x: uint64) void;

pub extern fn w_mepc(arg_x: uint64) void;

pub extern fn r_sstatus() uint64;

pub extern fn w_sstatus(arg_x: uint64) void;

pub extern fn r_sip() uint64;

pub extern fn w_sip(arg_x: uint64) void;

pub extern fn r_sie() uint64;

pub extern fn w_sie(arg_x: uint64) void;

pub extern fn r_mie() uint64;

pub extern fn w_mie(arg_x: uint64) void;

pub extern fn w_sepc(arg_x: uint64) void;

pub extern fn r_sepc() uint64;

pub extern fn r_medeleg() uint64;

pub extern fn w_medeleg(arg_x: uint64) void;

pub extern fn r_mideleg() uint64;

pub extern fn w_mideleg(arg_x: uint64) void;

pub extern fn w_stvec(arg_x: uint64) void;

pub extern fn r_stvec() uint64;

pub extern fn r_stimecmp() uint64;

pub extern fn w_stimecmp(arg_x: uint64) void;

pub extern fn r_menvcfg() uint64;

pub extern fn w_menvcfg(arg_x: uint64) void;

pub extern fn w_pmpcfg0(arg_x: uint64) void;

pub extern fn w_pmpaddr0(arg_x: uint64) void;

pub extern fn w_satp(arg_x: uint64) void;

pub extern fn r_satp() uint64;

pub extern fn r_scause() uint64;

pub extern fn r_stval() uint64;

pub extern fn w_mcounteren(arg_x: uint64) void;

pub extern fn r_mcounteren() uint64;

pub extern fn r_time() uint64;
pub fn intr_on() callconv(.c) void {
    w_sstatus(r_sstatus() | @as(uint64, @bitCast(@as(i64, 1) << @intCast(1))));
}
pub fn intr_off() callconv(.c) void {
    w_sstatus(r_sstatus() & @as(uint64, @bitCast(~(@as(i64, 1) << @intCast(1)))));
}
pub fn intr_get() callconv(.c) i32 {
    var x: uint64 = r_sstatus();
    _ = &x;
    return @intFromBool((x & @as(uint64, @bitCast(@as(i64, 1) << @intCast(1)))) != @as(uint64, @bitCast(@as(i64, @as(i32, 0)))));
}
pub fn r_sp() callconv(.c) uint64 {
    return asm volatile ("mv %[result], sp"
        : [result] "=r" (-> uint64),
    );
}

pub extern fn r_tp() uint64;

pub extern fn w_tp(arg_x: uint64) void;

pub extern fn r_ra() uint64;

pub extern fn sfence_vma() void;
pub const pte_t = uint64;
pub const pagetable_t = [*c]uint64;
pub export var buf: [12288]u8 = @import("std").mem.zeroes([12288]u8);
pub export fn copyin(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var addrs: [5]uint64 = [5]uint64{
        @as(uint64, @bitCast(@as(i64, @truncate(@as(i64, 2147483648))))),
        @as(uint64, @bitCast(@as(i64, 274877898752))),
        @as(uint64, @bitCast(@as(i64, 274877902848))),
        @as(uint64, @bitCast(@as(i64, 274877906944))),
        18446744073709551615,
    };
    _ = &addrs;
    {
        var ai: i32 = 0;
        _ = &ai;
        while (@as(u64, @bitCast(@as(i64, ai))) < (@sizeOf([5]uint64) / @sizeOf(uint64))) : (ai += 1) {
            var addr: uint64 = addrs[@as(u32, @intCast(ai))];
            _ = &addr;
            var fd: i32 = open("copyin1", @as(i32, 512) | @as(i32, 1));
            _ = &fd;
            if (fd < @as(i32, 0)) {
                printf("open(copyin1) failed\n");
                _ = exit(@as(i32, 1));
            }
            var n: i32 = write(fd, @as(?*anyopaque, @ptrFromInt(addr)), @as(i32, 8192));
            _ = &n;
            if (n >= @as(i32, 0)) {
                printf("write(fd, %p, 8192) returned %d, not -1\n", @as(?*anyopaque, @ptrFromInt(addr)), n);
                _ = exit(@as(i32, 1));
            }
            _ = close(fd);
            _ = unlink("copyin1");
            n = write(@as(i32, 1), @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrFromInt(addr)))), @as(i32, 8192));
            if (n > @as(i32, 0)) {
                printf("write(1, %p, 8192) returned %d, not -1 or 0\n", @as(?*anyopaque, @ptrFromInt(addr)), n);
                _ = exit(@as(i32, 1));
            }
            var fds: [2]i32 = undefined;
            _ = &fds;
            if (pipe(@as([*c]i32, @ptrCast(@alignCast(&fds[@as(u64, @intCast(0))])))) < @as(i32, 0)) {
                printf("pipe() failed\n");
                _ = exit(@as(i32, 1));
            }
            n = write(fds[@as(u32, @intCast(@as(i32, 1)))], @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrFromInt(addr)))), @as(i32, 8192));
            if (n > @as(i32, 0)) {
                printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", @as(?*anyopaque, @ptrFromInt(addr)), n);
                _ = exit(@as(i32, 1));
            }
            _ = close(fds[@as(u32, @intCast(@as(i32, 0)))]);
            _ = close(fds[@as(u32, @intCast(@as(i32, 1)))]);
        }
    }
}
pub export fn copyout(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var addrs: [6]uint64 = [6]uint64{
        0,
        @as(uint64, @bitCast(@as(i64, @truncate(@as(i64, 2147483648))))),
        @as(uint64, @bitCast(@as(i64, 274877898752))),
        @as(uint64, @bitCast(@as(i64, 274877902848))),
        @as(uint64, @bitCast(@as(i64, 274877906944))),
        18446744073709551615,
    };
    _ = &addrs;
    {
        var ai: i32 = 0;
        _ = &ai;
        while (@as(u64, @bitCast(@as(i64, ai))) < (@sizeOf([6]uint64) / @sizeOf(uint64))) : (ai += 1) {
            var addr: uint64 = addrs[@as(u32, @intCast(ai))];
            _ = &addr;
            var fd: i32 = open("README", @as(i32, 0));
            _ = &fd;
            if (fd < @as(i32, 0)) {
                printf("open(README) failed\n");
                _ = exit(@as(i32, 1));
            }
            var n: i32 = read(fd, @as(?*anyopaque, @ptrFromInt(addr)), @as(i32, 8192));
            _ = &n;
            if (n > @as(i32, 0)) {
                printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", @as(?*anyopaque, @ptrFromInt(addr)), n);
                _ = exit(@as(i32, 1));
            }
            _ = close(fd);
            var fds: [2]i32 = undefined;
            _ = &fds;
            if (pipe(@as([*c]i32, @ptrCast(@alignCast(&fds[@as(u64, @intCast(0))])))) < @as(i32, 0)) {
                printf("pipe() failed\n");
                _ = exit(@as(i32, 1));
            }
            n = write(fds[@as(u32, @intCast(@as(i32, 1)))], @as(?*const anyopaque, @ptrCast("x")), @as(i32, 1));
            if (n != @as(i32, 1)) {
                printf("pipe write failed\n");
                _ = exit(@as(i32, 1));
            }
            n = read(fds[@as(u32, @intCast(@as(i32, 0)))], @as(?*anyopaque, @ptrFromInt(addr)), @as(i32, 8192));
            if (n > @as(i32, 0)) {
                printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", @as(?*anyopaque, @ptrFromInt(addr)), n);
                _ = exit(@as(i32, 1));
            }
            _ = close(fds[@as(u32, @intCast(@as(i32, 0)))]);
            _ = close(fds[@as(u32, @intCast(@as(i32, 1)))]);
        }
    }
}
pub export fn copyinstr1(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var addrs: [5]uint64 = [5]uint64{
        @as(uint64, @bitCast(@as(i64, @truncate(@as(i64, 2147483648))))),
        @as(uint64, @bitCast(@as(i64, 274877898752))),
        @as(uint64, @bitCast(@as(i64, 274877902848))),
        @as(uint64, @bitCast(@as(i64, 274877906944))),
        18446744073709551615,
    };
    _ = &addrs;
    {
        var ai: i32 = 0;
        _ = &ai;
        while (@as(u64, @bitCast(@as(i64, ai))) < (@sizeOf([5]uint64) / @sizeOf(uint64))) : (ai += 1) {
            var addr: uint64 = addrs[@as(u32, @intCast(ai))];
            _ = &addr;
            var fd: i32 = open(@as([*c]u8, @ptrFromInt(addr)), @as(i32, 512) | @as(i32, 1));
            _ = &fd;
            if (fd >= @as(i32, 0)) {
                printf("open(%p) returned %d, not -1\n", @as(?*anyopaque, @ptrFromInt(addr)), fd);
                _ = exit(@as(i32, 1));
            }
        }
    }
}
pub export fn copyinstr2(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var b: [129]u8 = undefined;
    _ = &b;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < @as(i32, 128)) : (i += 1) {
            b[@as(u32, @intCast(i))] = 'x';
        }
    }
    b[@as(u32, @intCast(@as(i32, 128)))] = '\x00';
    var ret: i32 = unlink(@as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))));
    _ = &ret;
    if (ret != -@as(i32, 1)) {
        printf("unlink(%s) returned %d, not -1\n", @as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))), ret);
        _ = exit(@as(i32, 1));
    }
    var fd: i32 = open(@as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))), @as(i32, 512) | @as(i32, 1));
    _ = &fd;
    if (fd != -@as(i32, 1)) {
        printf("open(%s) returned %d, not -1\n", @as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))), fd);
        _ = exit(@as(i32, 1));
    }
    ret = link(@as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))), @as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))));
    if (ret != -@as(i32, 1)) {
        printf("link(%s, %s) returned %d, not -1\n", @as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))), @as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))), ret);
        _ = exit(@as(i32, 1));
    }
    var args: [2][*c]u8 = [2][*c]u8{
        @constCast("xx"),
        null,
    };
    _ = &args;
    ret = exec(@as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))), @as([*c][*c]u8, @ptrCast(@alignCast(&args[@as(u64, @intCast(0))]))));
    if (ret != -@as(i32, 1)) {
        printf("exec(%s) returned %d, not -1\n", @as([*c]u8, @ptrCast(@alignCast(&b[@as(u64, @intCast(0))]))), fd);
        _ = exit(@as(i32, 1));
    }
    var pid: i32 = fork();
    _ = &pid;
    if (pid < @as(i32, 0)) {
        printf("fork failed\n");
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        const big_1 = struct {
            var static: [4097]u8 = @import("std").mem.zeroes([4097]u8);
        };
        _ = &big_1;
        {
            var i: i32 = 0;
            _ = &i;
            while (i < @as(i32, 4096)) : (i += 1) {
                big_1.static[@as(u32, @intCast(i))] = 'x';
            }
        }
        big_1.static[@as(u32, @intCast(@as(i32, 4096)))] = '\x00';
        var args2: [4][*c]u8 = [4][*c]u8{
            @as([*c]u8, @ptrCast(@alignCast(&big_1.static[@as(u64, @intCast(0))]))),
            @as([*c]u8, @ptrCast(@alignCast(&big_1.static[@as(u64, @intCast(0))]))),
            @as([*c]u8, @ptrCast(@alignCast(&big_1.static[@as(u64, @intCast(0))]))),
            null,
        };
        _ = &args2;
        ret = exec("echo", @as([*c][*c]u8, @ptrCast(@alignCast(&args2[@as(u64, @intCast(0))]))));
        if (ret != -@as(i32, 1)) {
            printf("exec(echo, BIG) returned %d, not -1\n", fd);
            _ = exit(@as(i32, 1));
        }
        _ = exit(@as(i32, 747));
    }
    var st: i32 = 0;
    _ = &st;
    _ = wait(&st);
    if (st != @as(i32, 747)) {
        printf("exec(echo, BIG) succeeded, should have failed\n");
        _ = exit(@as(i32, 1));
    }
}
pub export fn copyinstr3(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    _ = sbrk(@as(i32, 8192));
    var top: uint64 = @as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0)))));
    _ = &top;
    if ((top % @as(uint64, @bitCast(@as(i64, @as(i32, 4096))))) != @as(uint64, @bitCast(@as(i64, @as(i32, 0))))) {
        _ = sbrk(@as(i32, @bitCast(@as(u32, @truncate(@as(uint64, @bitCast(@as(i64, @as(i32, 4096)))) -% (top % @as(uint64, @bitCast(@as(i64, @as(i32, 4096))))))))));
    }
    top = @as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0)))));
    if ((top % @as(uint64, @bitCast(@as(i64, @as(i32, 4096))))) != 0) {
        printf("oops\n");
        _ = exit(@as(i32, 1));
    }
    var b: [*c]u8 = @as([*c]u8, @ptrFromInt(top -% @as(uint64, @bitCast(@as(i64, @as(i32, 1))))));
    _ = &b;
    b.* = 'x';
    var ret: i32 = unlink(b);
    _ = &ret;
    if (ret != -@as(i32, 1)) {
        printf("unlink(%s) returned %d, not -1\n", b, ret);
        _ = exit(@as(i32, 1));
    }
    var fd: i32 = open(b, @as(i32, 512) | @as(i32, 1));
    _ = &fd;
    if (fd != -@as(i32, 1)) {
        printf("open(%s) returned %d, not -1\n", b, fd);
        _ = exit(@as(i32, 1));
    }
    ret = link(b, b);
    if (ret != -@as(i32, 1)) {
        printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
        _ = exit(@as(i32, 1));
    }
    var args: [2][*c]u8 = [2][*c]u8{
        @constCast("xx"),
        null,
    };
    _ = &args;
    ret = exec(b, @as([*c][*c]u8, @ptrCast(@alignCast(&args[@as(u64, @intCast(0))]))));
    if (ret != -@as(i32, 1)) {
        printf("exec(%s) returned %d, not -1\n", b, fd);
        _ = exit(@as(i32, 1));
    }
}
pub export fn rwsbrk(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    var n: i32 = undefined;
    _ = &n;
    var a: uint64 = @as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 8192)))));
    _ = &a;
    if (a == @as(uint64, @intCast(@intFromPtr(SBRK_ERROR)))) {
        printf("sbrk(rwsbrk) failed\n");
        _ = exit(@as(i32, 1));
    }
    if (sbrk(-@as(i32, 8192)) == SBRK_ERROR) {
        printf("sbrk(rwsbrk) shrink failed\n");
        _ = exit(@as(i32, 1));
    }
    fd = open("rwsbrk", @as(i32, 512) | @as(i32, 1));
    if (fd < @as(i32, 0)) {
        printf("open(rwsbrk) failed\n");
        _ = exit(@as(i32, 1));
    }
    n = write(fd, @as(?*anyopaque, @ptrFromInt(a +% @as(uint64, @bitCast(@as(i64, @as(i32, 4096)))))), @as(i32, 1024));
    if (n >= @as(i32, 0)) {
        printf("write(fd, %p, 1024) returned %d, not -1\n", @as(?*anyopaque, @ptrFromInt(a +% @as(uint64, @bitCast(@as(i64, @as(i32, 4096)))))), n);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    _ = unlink("rwsbrk");
    fd = open("README", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("open(README) failed\n");
        _ = exit(@as(i32, 1));
    }
    n = read(fd, @as(?*anyopaque, @ptrFromInt(a +% @as(uint64, @bitCast(@as(i64, @as(i32, 4096)))))), @as(i32, 10));
    if (n >= @as(i32, 0)) {
        printf("read(fd, %p, 10) returned %d, not -1\n", @as(?*anyopaque, @ptrFromInt(a +% @as(uint64, @bitCast(@as(i64, @as(i32, 4096)))))), n);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    _ = exit(@as(i32, 0));
}
pub export fn truncate1(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var buf_1: [32]u8 = undefined;
    _ = &buf_1;
    _ = unlink("truncfile");
    var fd1: i32 = open("truncfile", (@as(i32, 512) | @as(i32, 1)) | @as(i32, 1024));
    _ = &fd1;
    _ = write(fd1, @as(?*const anyopaque, @ptrCast("abcd")), @as(i32, 4));
    _ = close(fd1);
    var fd2: i32 = open("truncfile", @as(i32, 0));
    _ = &fd2;
    var n: i32 = read(fd2, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([32]u8))))));
    _ = &n;
    if (n != @as(i32, 4)) {
        printf("%s: read %d bytes, wanted 4\n", s, n);
        _ = exit(@as(i32, 1));
    }
    fd1 = open("truncfile", @as(i32, 1) | @as(i32, 1024));
    var fd3: i32 = open("truncfile", @as(i32, 0));
    _ = &fd3;
    n = read(fd3, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([32]u8))))));
    if (n != @as(i32, 0)) {
        printf("aaa fd3=%d\n", fd3);
        printf("%s: read %d bytes, wanted 0\n", s, n);
        _ = exit(@as(i32, 1));
    }
    n = read(fd2, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([32]u8))))));
    if (n != @as(i32, 0)) {
        printf("bbb fd2=%d\n", fd2);
        printf("%s: read %d bytes, wanted 0\n", s, n);
        _ = exit(@as(i32, 1));
    }
    _ = write(fd1, @as(?*const anyopaque, @ptrCast("abcdef")), @as(i32, 6));
    n = read(fd3, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([32]u8))))));
    if (n != @as(i32, 6)) {
        printf("%s: read %d bytes, wanted 6\n", s, n);
        _ = exit(@as(i32, 1));
    }
    n = read(fd2, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([32]u8))))));
    if (n != @as(i32, 2)) {
        printf("%s: read %d bytes, wanted 2\n", s, n);
        _ = exit(@as(i32, 1));
    }
    _ = unlink("truncfile");
    _ = close(fd1);
    _ = close(fd2);
    _ = close(fd3);
}
pub export fn truncate2(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    _ = unlink("truncfile");
    var fd1: i32 = open("truncfile", (@as(i32, 512) | @as(i32, 1024)) | @as(i32, 1));
    _ = &fd1;
    _ = write(fd1, @as(?*const anyopaque, @ptrCast("abcd")), @as(i32, 4));
    var fd2: i32 = open("truncfile", @as(i32, 1024) | @as(i32, 1));
    _ = &fd2;
    var n: i32 = write(fd1, @as(?*const anyopaque, @ptrCast("x")), @as(i32, 1));
    _ = &n;
    if (n != -@as(i32, 1)) {
        printf("%s: write returned %d, expected -1\n", s, n);
        _ = exit(@as(i32, 1));
    }
    _ = unlink("truncfile");
    _ = close(fd1);
    _ = close(fd2);
}
pub export fn truncate3(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid: i32 = undefined;
    _ = &pid;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    _ = close(open("truncfile", (@as(i32, 512) | @as(i32, 1024)) | @as(i32, 1)));
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("%s: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        {
            var i: i32 = 0;
            _ = &i;
            while (i < @as(i32, 100)) : (i += 1) {
                var buf_1: [32]u8 = undefined;
                _ = &buf_1;
                var fd: i32 = open("truncfile", @as(i32, 1));
                _ = &fd;
                if (fd < @as(i32, 0)) {
                    printf("%s: open failed\n", s);
                    _ = exit(@as(i32, 1));
                }
                var n: i32 = write(fd, @as(?*const anyopaque, @ptrCast("1234567890")), @as(i32, 10));
                _ = &n;
                if (n != @as(i32, 10)) {
                    printf("%s: write got %d, expected 10\n", s, n);
                    _ = exit(@as(i32, 1));
                }
                _ = close(fd);
                fd = open("truncfile", @as(i32, 0));
                _ = read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([32]u8))))));
                _ = close(fd);
            }
        }
        _ = exit(@as(i32, 0));
    }
    {
        var i: i32 = 0;
        _ = &i;
        while (i < @as(i32, 150)) : (i += 1) {
            var fd: i32 = open("truncfile", (@as(i32, 512) | @as(i32, 1)) | @as(i32, 1024));
            _ = &fd;
            if (fd < @as(i32, 0)) {
                printf("%s: open failed\n", s);
                _ = exit(@as(i32, 1));
            }
            var n: i32 = write(fd, @as(?*const anyopaque, @ptrCast("xxx")), @as(i32, 3));
            _ = &n;
            if (n != @as(i32, 3)) {
                printf("%s: write got %d, expected 3\n", s, n);
                _ = exit(@as(i32, 1));
            }
            _ = close(fd);
        }
    }
    _ = wait(&xstatus);
    _ = unlink("truncfile");
    _ = exit(xstatus);
}
pub export fn iputtest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    if (mkdir("iputdir") < @as(i32, 0)) {
        printf("%s: mkdir failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("iputdir") < @as(i32, 0)) {
        printf("%s: chdir iputdir failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("../iputdir") < @as(i32, 0)) {
        printf("%s: unlink ../iputdir failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("/") < @as(i32, 0)) {
        printf("%s: chdir / failed\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn exitiputtest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid: i32 = undefined;
    _ = &pid;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("%s: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        if (mkdir("iputdir") < @as(i32, 0)) {
            printf("%s: mkdir failed\n", s);
            _ = exit(@as(i32, 1));
        }
        if (chdir("iputdir") < @as(i32, 0)) {
            printf("%s: child chdir failed\n", s);
            _ = exit(@as(i32, 1));
        }
        if (unlink("../iputdir") < @as(i32, 0)) {
            printf("%s: unlink ../iputdir failed\n", s);
            _ = exit(@as(i32, 1));
        }
        _ = exit(@as(i32, 0));
    }
    _ = wait(&xstatus);
    _ = exit(xstatus);
}
pub export fn openiputtest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid: i32 = undefined;
    _ = &pid;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    if (mkdir("oidir") < @as(i32, 0)) {
        printf("%s: mkdir oidir failed\n", s);
        _ = exit(@as(i32, 1));
    }
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("%s: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        var fd: i32 = open("oidir", @as(i32, 2));
        _ = &fd;
        if (fd >= @as(i32, 0)) {
            printf("%s: open directory for write succeeded\n", s);
            _ = exit(@as(i32, 1));
        }
        _ = exit(@as(i32, 0));
    }
    _ = pause(@as(i32, 1));
    if (unlink("oidir") != @as(i32, 0)) {
        printf("%s: unlink failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = wait(&xstatus);
    _ = exit(xstatus);
}
pub export fn opentest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    fd = open("echo", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: open echo failed!\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    fd = open("doesnotexist", @as(i32, 0));
    if (fd >= @as(i32, 0)) {
        printf("%s: open doesnotexist succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn writetest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    var i: i32 = undefined;
    _ = &i;
    const N: i32 = 100;
    _ = &N;
    const SZ: i32 = 10;
    _ = &SZ;
    const enum_unnamed_1 = u32;
    _ = &enum_unnamed_1;
    fd = open("small", @as(i32, 512) | @as(i32, 2));
    if (fd < @as(i32, 0)) {
        printf("%s: error: creat small failed!\n", s);
        _ = exit(@as(i32, 1));
    }
    {
        i = 0;
        while (i < N) : (i += 1) {
            if (write(fd, @as(?*const anyopaque, @ptrCast("aaaaaaaaaa")), SZ) != SZ) {
                printf("%s: error: write aa %d new file failed\n", s, i);
                _ = exit(@as(i32, 1));
            }
            if (write(fd, @as(?*const anyopaque, @ptrCast("bbbbbbbbbb")), SZ) != SZ) {
                printf("%s: error: write bb %d new file failed\n", s, i);
                _ = exit(@as(i32, 1));
            }
        }
    }
    _ = close(fd);
    fd = open("small", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: error: open small failed!\n", s);
        _ = exit(@as(i32, 1));
    }
    i = read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), (N * SZ) * @as(i32, 2));
    if (i != ((N * SZ) * @as(i32, 2))) {
        printf("%s: read failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    if (unlink("small") < @as(i32, 0)) {
        printf("%s: unlink small failed\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn writebig(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var i: i32 = undefined;
    _ = &i;
    var fd: i32 = undefined;
    _ = &fd;
    var n: i32 = undefined;
    _ = &n;
    fd = open("big", @as(i32, 512) | @as(i32, 2));
    if (fd < @as(i32, 0)) {
        printf("%s: error: creat big failed!\n", s);
        _ = exit(@as(i32, 1));
    }
    {
        i = 0;
        while (@as(u64, @bitCast(@as(i64, i))) < (@as(u64, @bitCast(@as(i64, @as(i32, 12)))) +% (@as(u64, @bitCast(@as(i64, @as(i32, 1024)))) / @sizeOf(uint)))) : (i += 1) {
            @as([*c]i32, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))))[@as(u32, @intCast(@as(i32, 0)))] = i;
            if (write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, 1024)) != @as(i32, 1024)) {
                printf("%s: error: write big file failed i=%d\n", s, i);
                _ = exit(@as(i32, 1));
            }
        }
    }
    _ = close(fd);
    fd = open("big", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: error: open big failed!\n", s);
        _ = exit(@as(i32, 1));
    }
    n = 0;
    while (true) {
        i = read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, 1024));
        if (i == @as(i32, 0)) {
            if (@as(u64, @bitCast(@as(i64, n))) != (@as(u64, @bitCast(@as(i64, @as(i32, 12)))) +% (@as(u64, @bitCast(@as(i64, @as(i32, 1024)))) / @sizeOf(uint)))) {
                printf("%s: read only %d blocks from big", s, n);
                _ = exit(@as(i32, 1));
            }
            break;
        } else if (i != @as(i32, 1024)) {
            printf("%s: read failed %d\n", s, i);
            _ = exit(@as(i32, 1));
        }
        if (@as([*c]i32, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))))[@as(u32, @intCast(@as(i32, 0)))] != n) {
            printf("%s: read content of block %d is %d\n", s, n, @as([*c]i32, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))))[@as(u32, @intCast(@as(i32, 0)))]);
            _ = exit(@as(i32, 1));
        }
        n += 1;
    }
    _ = close(fd);
    if (unlink("big") < @as(i32, 0)) {
        printf("%s: unlink big failed\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn createtest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var i: i32 = undefined;
    _ = &i;
    var fd: i32 = undefined;
    _ = &fd;
    const N: i32 = 52;
    _ = &N;
    const enum_unnamed_2 = u32;
    _ = &enum_unnamed_2;
    var name: [3]u8 = undefined;
    _ = &name;
    name[@as(u32, @intCast(@as(i32, 0)))] = 'a';
    name[@as(u32, @intCast(@as(i32, 2)))] = '\x00';
    {
        i = 0;
        while (i < N) : (i += 1) {
            name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + i))));
            fd = open(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))), @as(i32, 512) | @as(i32, 2));
            _ = close(fd);
        }
    }
    name[@as(u32, @intCast(@as(i32, 0)))] = 'a';
    name[@as(u32, @intCast(@as(i32, 2)))] = '\x00';
    {
        i = 0;
        while (i < N) : (i += 1) {
            name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + i))));
            _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
        }
    }
}
pub export fn dirtest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    if (mkdir("dir0") < @as(i32, 0)) {
        printf("%s: mkdir failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("dir0") < @as(i32, 0)) {
        printf("%s: chdir dir0 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("..") < @as(i32, 0)) {
        printf("%s: chdir .. failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dir0") < @as(i32, 0)) {
        printf("%s: unlink dir0 failed\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn exectest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    var pid: i32 = undefined;
    _ = &pid;
    var echoargv: [3][*c]u8 = [3][*c]u8{
        @constCast("echo"),
        @constCast("OK"),
        null,
    };
    _ = &echoargv;
    var buf_1: [3]u8 = undefined;
    _ = &buf_1;
    _ = unlink("echo-ok");
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("%s: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        _ = close(@as(i32, 1));
        fd = open("echo-ok", @as(i32, 512) | @as(i32, 1));
        if (fd < @as(i32, 0)) {
            printf("%s: create failed\n", s);
            _ = exit(@as(i32, 1));
        }
        if (fd != @as(i32, 1)) {
            printf("%s: wrong fd\n", s);
            _ = exit(@as(i32, 1));
        }
        if (exec("echo", @as([*c][*c]u8, @ptrCast(@alignCast(&echoargv[@as(u64, @intCast(0))])))) < @as(i32, 0)) {
            printf("%s: exec echo failed\n", s);
            _ = exit(@as(i32, 1));
        }
    }
    if (wait(&xstatus) != pid) {
        printf("%s: wait failed!\n", s);
    }
    if (xstatus != @as(i32, 0)) {
        _ = exit(xstatus);
    }
    fd = open("echo-ok", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: open failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, 2)) != @as(i32, 2)) {
        printf("%s: read failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = unlink("echo-ok");
    if ((@as(i32, @bitCast(@as(u32, buf_1[@as(u32, @intCast(@as(i32, 0)))]))) == @as(i32, 'O')) and (@as(i32, @bitCast(@as(u32, buf_1[@as(u32, @intCast(@as(i32, 1)))]))) == @as(i32, 'K'))) {
        _ = exit(@as(i32, 0));
    } else {
        printf("%s: wrong output\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn pipe1(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fds: [2]i32 = undefined;
    _ = &fds;
    var pid: i32 = undefined;
    _ = &pid;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    var seq: i32 = undefined;
    _ = &seq;
    var i: i32 = undefined;
    _ = &i;
    var n: i32 = undefined;
    _ = &n;
    var cc: i32 = undefined;
    _ = &cc;
    var total: i32 = undefined;
    _ = &total;
    const N: i32 = 5;
    _ = &N;
    const SZ: i32 = 1033;
    _ = &SZ;
    const enum_unnamed_3 = u32;
    _ = &enum_unnamed_3;
    if (pipe(@as([*c]i32, @ptrCast(@alignCast(&fds[@as(u64, @intCast(0))])))) != @as(i32, 0)) {
        printf("%s: pipe() failed\n", s);
        _ = exit(@as(i32, 1));
    }
    pid = fork();
    seq = 0;
    if (pid == @as(i32, 0)) {
        _ = close(fds[@as(u32, @intCast(@as(i32, 0)))]);
        {
            n = 0;
            while (n < N) : (n += 1) {
                {
                    i = 0;
                    while (i < SZ) : (i += 1) {
                        buf[@as(u32, @intCast(i))] = @as(u8, @bitCast(@as(i8, @truncate(blk: {
                            const ref = &seq;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        }))));
                    }
                }
                if (write(fds[@as(u32, @intCast(@as(i32, 1)))], @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), SZ) != SZ) {
                    printf("%s: pipe1 oops 1\n", s);
                    _ = exit(@as(i32, 1));
                }
            }
        }
        _ = exit(@as(i32, 0));
    } else if (pid > @as(i32, 0)) {
        _ = close(fds[@as(u32, @intCast(@as(i32, 1)))]);
        total = 0;
        cc = 1;
        while ((blk: {
            const tmp = read(fds[@as(u32, @intCast(@as(i32, 0)))], @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), cc);
            n = tmp;
            break :blk tmp;
        }) > @as(i32, 0)) {
            {
                i = 0;
                while (i < n) : (i += 1) {
                    if ((@as(i32, @bitCast(@as(u32, buf[@as(u32, @intCast(i))]))) & @as(i32, 255)) != ((blk: {
                        const ref = &seq;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    }) & @as(i32, 255))) {
                        printf("%s: pipe1 oops 2\n", s);
                        return;
                    }
                }
            }
            total += n;
            cc = cc * @as(i32, 2);
            if (@as(u64, @bitCast(@as(i64, cc))) > @sizeOf([12288]u8)) {
                cc = @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([12288]u8)))));
            }
        }
        if (total != (N * SZ)) {
            printf("%s: pipe1 oops 3 total %d\n", s, total);
            _ = exit(@as(i32, 1));
        }
        _ = close(fds[@as(u32, @intCast(@as(i32, 0)))]);
        _ = wait(&xstatus);
        _ = exit(xstatus);
    } else {
        printf("%s: fork() failed\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn killstatus(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var xst: i32 = undefined;
    _ = &xst;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < @as(i32, 100)) : (i += 1) {
            var pid1: i32 = fork();
            _ = &pid1;
            if (pid1 < @as(i32, 0)) {
                printf("%s: fork failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (pid1 == @as(i32, 0)) {
                while (true) {
                    _ = getpid();
                }
                _ = exit(@as(i32, 0));
            }
            _ = pause(@as(i32, 1));
            _ = kill(pid1);
            _ = wait(&xst);
            if (xst != -@as(i32, 1)) {
                printf("%s: status should be -1\n", s);
                _ = exit(@as(i32, 1));
            }
        }
    }
    _ = exit(@as(i32, 0));
}
pub export fn preempt(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid1: i32 = undefined;
    _ = &pid1;
    var pid2: i32 = undefined;
    _ = &pid2;
    var pid3: i32 = undefined;
    _ = &pid3;
    var pfds: [2]i32 = undefined;
    _ = &pfds;
    pid1 = fork();
    if (pid1 < @as(i32, 0)) {
        printf("%s: fork failed", s);
        _ = exit(@as(i32, 1));
    }
    if (pid1 == @as(i32, 0)) while (true) {};
    pid2 = fork();
    if (pid2 < @as(i32, 0)) {
        printf("%s: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (pid2 == @as(i32, 0)) while (true) {};
    _ = pipe(@as([*c]i32, @ptrCast(@alignCast(&pfds[@as(u64, @intCast(0))]))));
    pid3 = fork();
    if (pid3 < @as(i32, 0)) {
        printf("%s: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (pid3 == @as(i32, 0)) {
        _ = close(pfds[@as(u32, @intCast(@as(i32, 0)))]);
        if (write(pfds[@as(u32, @intCast(@as(i32, 1)))], @as(?*const anyopaque, @ptrCast("x")), @as(i32, 1)) != @as(i32, 1)) {
            printf("%s: preempt write error", s);
        }
        _ = close(pfds[@as(u32, @intCast(@as(i32, 1)))]);
        while (true) {}
    }
    _ = close(pfds[@as(u32, @intCast(@as(i32, 1)))]);
    if (read(pfds[@as(u32, @intCast(@as(i32, 0)))], @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([12288]u8)))))) != @as(i32, 1)) {
        printf("%s: preempt read error", s);
        return;
    }
    _ = close(pfds[@as(u32, @intCast(@as(i32, 0)))]);
    printf("kill... ");
    _ = kill(pid1);
    _ = kill(pid2);
    _ = kill(pid3);
    printf("wait... ");
    _ = wait(null);
    _ = wait(null);
    _ = wait(null);
}
pub export fn exitwait(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var i: i32 = undefined;
    _ = &i;
    var pid: i32 = undefined;
    _ = &pid;
    {
        i = 0;
        while (i < @as(i32, 100)) : (i += 1) {
            pid = fork();
            if (pid < @as(i32, 0)) {
                printf("%s: fork failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (pid != 0) {
                var xstate: i32 = undefined;
                _ = &xstate;
                if (wait(&xstate) != pid) {
                    printf("%s: wait wrong pid\n", s);
                    _ = exit(@as(i32, 1));
                }
                if (i != xstate) {
                    printf("%s: wait wrong exit status\n", s);
                    _ = exit(@as(i32, 1));
                }
            } else {
                _ = exit(i);
            }
        }
    }
}
pub export fn reparent(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var master_pid: i32 = getpid();
    _ = &master_pid;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < @as(i32, 200)) : (i += 1) {
            var pid: i32 = fork();
            _ = &pid;
            if (pid < @as(i32, 0)) {
                printf("%s: fork failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (pid != 0) {
                if (wait(null) != pid) {
                    printf("%s: wait wrong pid\n", s);
                    _ = exit(@as(i32, 1));
                }
            } else {
                var pid2: i32 = fork();
                _ = &pid2;
                if (pid2 < @as(i32, 0)) {
                    _ = kill(master_pid);
                    _ = exit(@as(i32, 1));
                }
                _ = exit(@as(i32, 0));
            }
        }
    }
    _ = exit(@as(i32, 0));
}
pub export fn twochildren(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < @as(i32, 1000)) : (i += 1) {
            var pid1: i32 = fork();
            _ = &pid1;
            if (pid1 < @as(i32, 0)) {
                printf("%s: fork failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (pid1 == @as(i32, 0)) {
                _ = exit(@as(i32, 0));
            } else {
                var pid2: i32 = fork();
                _ = &pid2;
                if (pid2 < @as(i32, 0)) {
                    printf("%s: fork failed\n", s);
                    _ = exit(@as(i32, 1));
                }
                if (pid2 == @as(i32, 0)) {
                    _ = exit(@as(i32, 0));
                } else {
                    _ = wait(null);
                    _ = wait(null);
                }
            }
        }
    }
}
pub export fn forkfork(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const N: i32 = 2;
    _ = &N;
    const enum_unnamed_4 = u32;
    _ = &enum_unnamed_4;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < N) : (i += 1) {
            var pid: i32 = fork();
            _ = &pid;
            if (pid < @as(i32, 0)) {
                printf("%s: fork failed", s);
                _ = exit(@as(i32, 1));
            }
            if (pid == @as(i32, 0)) {
                {
                    var j: i32 = 0;
                    _ = &j;
                    while (j < @as(i32, 200)) : (j += 1) {
                        var pid1: i32 = fork();
                        _ = &pid1;
                        if (pid1 < @as(i32, 0)) {
                            _ = exit(@as(i32, 1));
                        }
                        if (pid1 == @as(i32, 0)) {
                            _ = exit(@as(i32, 0));
                        }
                        _ = wait(null);
                    }
                }
                _ = exit(@as(i32, 0));
            }
        }
    }
    var xstatus: i32 = undefined;
    _ = &xstatus;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < N) : (i += 1) {
            _ = wait(&xstatus);
            if (xstatus != @as(i32, 0)) {
                printf("%s: fork in child failed", s);
                _ = exit(@as(i32, 1));
            }
        }
    }
}
pub export fn forkforkfork(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    _ = unlink("stopforking");
    var pid: i32 = fork();
    _ = &pid;
    if (pid < @as(i32, 0)) {
        printf("%s: fork failed", s);
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        while (true) {
            var fd: i32 = open("stopforking", @as(i32, 0));
            _ = &fd;
            if (fd >= @as(i32, 0)) {
                _ = exit(@as(i32, 0));
            }
            if (fork() < @as(i32, 0)) {
                _ = close(open("stopforking", @as(i32, 512) | @as(i32, 2)));
            }
        }
        _ = exit(@as(i32, 0));
    }
    _ = pause(@as(i32, 20));
    _ = close(open("stopforking", @as(i32, 512) | @as(i32, 2)));
    _ = wait(null);
    _ = pause(@as(i32, 10));
}
pub export fn reparent2(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < @as(i32, 800)) : (i += 1) {
            var pid1: i32 = fork();
            _ = &pid1;
            if (pid1 < @as(i32, 0)) {
                printf("fork failed\n");
                _ = exit(@as(i32, 1));
            }
            if (pid1 == @as(i32, 0)) {
                _ = fork();
                _ = fork();
                _ = exit(@as(i32, 0));
            }
            _ = wait(null);
        }
    }
    _ = exit(@as(i32, 0));
}
pub export fn mem(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var m1: ?*anyopaque = undefined;
    _ = &m1;
    var m2: ?*anyopaque = undefined;
    _ = &m2;
    var pid: i32 = undefined;
    _ = &pid;
    if ((blk: {
        const tmp = fork();
        pid = tmp;
        break :blk tmp;
    }) == @as(i32, 0)) {
        m1 = null;
        while ((blk: {
            const tmp = malloc(@as(uint, @bitCast(@as(i32, 10001))));
            m2 = tmp;
            break :blk tmp;
        }) != null) {
            @as([*c][*c]u8, @ptrCast(@alignCast(m2))).* = @as([*c]u8, @ptrCast(@alignCast(m1)));
            m1 = m2;
        }
        while (m1 != null) {
            m2 = @as(?*anyopaque, @ptrCast(@as([*c][*c]u8, @ptrCast(@alignCast(m1))).*));
            free(m1);
            m1 = m2;
        }
        m1 = malloc(@as(uint, @bitCast(@as(i32, 1024) * @as(i32, 20))));
        if (m1 == null) {
            printf("%s: couldn't allocate mem?!!\n", s);
            _ = exit(@as(i32, 1));
        }
        free(m1);
        _ = exit(@as(i32, 0));
    } else {
        var xstatus: i32 = undefined;
        _ = &xstatus;
        _ = wait(&xstatus);
        if (xstatus == -@as(i32, 1)) {
            _ = exit(@as(i32, 0));
        }
        _ = exit(xstatus);
    }
}
pub export fn sharedfd(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    var pid: i32 = undefined;
    _ = &pid;
    var i: i32 = undefined;
    _ = &i;
    var n: i32 = undefined;
    _ = &n;
    var nc: i32 = undefined;
    _ = &nc;
    var np: i32 = undefined;
    _ = &np;
    const N: i32 = 1000;
    _ = &N;
    const SZ: i32 = 10;
    _ = &SZ;
    const enum_unnamed_5 = u32;
    _ = &enum_unnamed_5;
    var buf_1: [10]u8 = undefined;
    _ = &buf_1;
    _ = unlink("sharedfd");
    fd = open("sharedfd", @as(i32, 512) | @as(i32, 2));
    if (fd < @as(i32, 0)) {
        printf("%s: cannot open sharedfd for writing", s);
        _ = exit(@as(i32, 1));
    }
    pid = fork();
    _ = memset(@as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), if (pid == @as(i32, 0)) @as(i32, 'c') else @as(i32, 'p'), @as(uint, @bitCast(@as(u32, @truncate(@sizeOf([10]u8))))));
    {
        i = 0;
        while (i < N) : (i += 1) {
            if (@as(u64, @bitCast(@as(i64, write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([10]u8))))))))) != @sizeOf([10]u8)) {
                printf("%s: write sharedfd failed\n", s);
                _ = exit(@as(i32, 1));
            }
        }
    }
    if (pid == @as(i32, 0)) {
        _ = exit(@as(i32, 0));
    } else {
        var xstatus: i32 = undefined;
        _ = &xstatus;
        _ = wait(&xstatus);
        if (xstatus != @as(i32, 0)) {
            _ = exit(xstatus);
        }
    }
    _ = close(fd);
    fd = open("sharedfd", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: cannot open sharedfd for reading\n", s);
        _ = exit(@as(i32, 1));
    }
    nc = blk: {
        const tmp = @as(i32, 0);
        np = tmp;
        break :blk tmp;
    };
    while ((blk: {
        const tmp = read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([10]u8))))));
        n = tmp;
        break :blk tmp;
    }) > @as(i32, 0)) {
        {
            i = 0;
            while (@as(u64, @bitCast(@as(i64, i))) < @sizeOf([10]u8)) : (i += 1) {
                if (@as(i32, @bitCast(@as(u32, buf_1[@as(u32, @intCast(i))]))) == @as(i32, 'c')) {
                    nc += 1;
                }
                if (@as(i32, @bitCast(@as(u32, buf_1[@as(u32, @intCast(i))]))) == @as(i32, 'p')) {
                    np += 1;
                }
            }
        }
    }
    _ = close(fd);
    _ = unlink("sharedfd");
    if ((nc == (N * SZ)) and (np == (N * SZ))) {
        _ = exit(@as(i32, 0));
    } else {
        printf("%s: nc/np test fails\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn fourfiles(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    var pid: i32 = undefined;
    _ = &pid;
    var i: i32 = undefined;
    _ = &i;
    var j: i32 = undefined;
    _ = &j;
    var n: i32 = undefined;
    _ = &n;
    var total: i32 = undefined;
    _ = &total;
    var pi: i32 = undefined;
    _ = &pi;
    var names: [4][*c]u8 = [4][*c]u8{
        @constCast("f0"),
        @constCast("f1"),
        @constCast("f2"),
        @constCast("f3"),
    };
    _ = &names;
    var fname: [*c]u8 = undefined;
    _ = &fname;
    const N: i32 = 12;
    _ = &N;
    const NCHILD: i32 = 4;
    _ = &NCHILD;
    const SZ: i32 = 500;
    _ = &SZ;
    const enum_unnamed_6 = u32;
    _ = &enum_unnamed_6;
    {
        pi = 0;
        while (pi < NCHILD) : (pi += 1) {
            fname = names[@as(u32, @intCast(pi))];
            _ = unlink(fname);
            pid = fork();
            if (pid < @as(i32, 0)) {
                printf("%s: fork failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (pid == @as(i32, 0)) {
                fd = open(fname, @as(i32, 512) | @as(i32, 2));
                if (fd < @as(i32, 0)) {
                    printf("%s: create failed\n", s);
                    _ = exit(@as(i32, 1));
                }
                _ = memset(@as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, '0') + pi, @as(uint, @bitCast(SZ)));
                {
                    i = 0;
                    while (i < N) : (i += 1) {
                        if ((blk: {
                            const tmp = write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), SZ);
                            n = tmp;
                            break :blk tmp;
                        }) != SZ) {
                            printf("write failed %d\n", n);
                            _ = exit(@as(i32, 1));
                        }
                    }
                }
                _ = exit(@as(i32, 0));
            }
        }
    }
    var xstatus: i32 = undefined;
    _ = &xstatus;
    {
        pi = 0;
        while (pi < NCHILD) : (pi += 1) {
            _ = wait(&xstatus);
            if (xstatus != @as(i32, 0)) {
                _ = exit(xstatus);
            }
        }
    }
    {
        i = 0;
        while (i < NCHILD) : (i += 1) {
            fname = names[@as(u32, @intCast(i))];
            fd = open(fname, @as(i32, 0));
            total = 0;
            while ((blk: {
                const tmp = read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([12288]u8))))));
                n = tmp;
                break :blk tmp;
            }) > @as(i32, 0)) {
                {
                    j = 0;
                    while (j < n) : (j += 1) {
                        if (@as(i32, @bitCast(@as(u32, buf[@as(u32, @intCast(j))]))) != (@as(i32, '0') + i)) {
                            printf("%s: wrong char\n", s);
                            _ = exit(@as(i32, 1));
                        }
                    }
                }
                total += n;
            }
            _ = close(fd);
            if (total != (N * SZ)) {
                printf("wrong length %d\n", total);
                _ = exit(@as(i32, 1));
            }
            _ = unlink(fname);
        }
    }
}
pub export fn createdelete(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const N: i32 = 20;
    _ = &N;
    const NCHILD: i32 = 4;
    _ = &NCHILD;
    const enum_unnamed_7 = u32;
    _ = &enum_unnamed_7;
    var pid: i32 = undefined;
    _ = &pid;
    var i: i32 = undefined;
    _ = &i;
    var fd: i32 = undefined;
    _ = &fd;
    var pi: i32 = undefined;
    _ = &pi;
    var name: [32]u8 = undefined;
    _ = &name;
    {
        pi = 0;
        while (pi < NCHILD) : (pi += 1) {
            pid = fork();
            if (pid < @as(i32, 0)) {
                printf("%s: fork failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (pid == @as(i32, 0)) {
                name[@as(u32, @intCast(@as(i32, 0)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, 'p') + pi))));
                name[@as(u32, @intCast(@as(i32, 2)))] = '\x00';
                {
                    i = 0;
                    while (i < N) : (i += 1) {
                        name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + i))));
                        fd = open(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))), @as(i32, 512) | @as(i32, 2));
                        if (fd < @as(i32, 0)) {
                            printf("%s: create failed\n", s);
                            _ = exit(@as(i32, 1));
                        }
                        _ = close(fd);
                        if ((i > @as(i32, 0)) and (@import("std").zig.c_translation.signedRemainder(i, @as(i32, 2)) == @as(i32, 0))) {
                            name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(i, @as(i32, 2))))));
                            if (unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))])))) < @as(i32, 0)) {
                                printf("%s: unlink failed\n", s);
                                _ = exit(@as(i32, 1));
                            }
                        }
                    }
                }
                _ = exit(@as(i32, 0));
            }
        }
    }
    var xstatus: i32 = undefined;
    _ = &xstatus;
    {
        pi = 0;
        while (pi < NCHILD) : (pi += 1) {
            _ = wait(&xstatus);
            if (xstatus != @as(i32, 0)) {
                _ = exit(@as(i32, 1));
            }
        }
    }
    name[@as(u32, @intCast(@as(i32, 0)))] = blk: {
        const tmp = blk_1: {
            const tmp_2 = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, 0)))));
            name[@as(u32, @intCast(@as(i32, 2)))] = tmp_2;
            break :blk_1 tmp_2;
        };
        name[@as(u32, @intCast(@as(i32, 1)))] = tmp;
        break :blk tmp;
    };
    {
        i = 0;
        while (i < N) : (i += 1) {
            {
                pi = 0;
                while (pi < NCHILD) : (pi += 1) {
                    name[@as(u32, @intCast(@as(i32, 0)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, 'p') + pi))));
                    name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + i))));
                    fd = open(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))), @as(i32, 0));
                    if (((i == @as(i32, 0)) or (i >= @divTrunc(N, @as(i32, 2)))) and (fd < @as(i32, 0))) {
                        printf("%s: oops createdelete %s didn't exist\n", s, @as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                        _ = exit(@as(i32, 1));
                    } else if (((i >= @as(i32, 1)) and (i < @divTrunc(N, @as(i32, 2)))) and (fd >= @as(i32, 0))) {
                        printf("%s: oops createdelete %s did exist\n", s, @as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                        _ = exit(@as(i32, 1));
                    }
                    if (fd >= @as(i32, 0)) {
                        _ = close(fd);
                    }
                }
            }
        }
    }
    {
        i = 0;
        while (i < N) : (i += 1) {
            {
                pi = 0;
                while (pi < NCHILD) : (pi += 1) {
                    name[@as(u32, @intCast(@as(i32, 0)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, 'p') + pi))));
                    name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + i))));
                    _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                }
            }
        }
    }
}
pub export fn unlinkread(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const SZ: i32 = 5;
    _ = &SZ;
    const enum_unnamed_8 = u32;
    _ = &enum_unnamed_8;
    var fd: i32 = undefined;
    _ = &fd;
    var fd1: i32 = undefined;
    _ = &fd1;
    fd = open("unlinkread", @as(i32, 512) | @as(i32, 2));
    if (fd < @as(i32, 0)) {
        printf("%s: create unlinkread failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = write(fd, @as(?*const anyopaque, @ptrCast("hello")), SZ);
    _ = close(fd);
    fd = open("unlinkread", @as(i32, 2));
    if (fd < @as(i32, 0)) {
        printf("%s: open unlinkread failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("unlinkread") != @as(i32, 0)) {
        printf("%s: unlink unlinkread failed\n", s);
        _ = exit(@as(i32, 1));
    }
    fd1 = open("unlinkread", @as(i32, 512) | @as(i32, 2));
    _ = write(fd1, @as(?*const anyopaque, @ptrCast("yyy")), @as(i32, 3));
    _ = close(fd1);
    if (read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([12288]u8)))))) != SZ) {
        printf("%s: unlinkread read failed", s);
        _ = exit(@as(i32, 1));
    }
    if (@as(i32, @bitCast(@as(u32, buf[@as(u32, @intCast(@as(i32, 0)))]))) != @as(i32, 'h')) {
        printf("%s: unlinkread wrong data\n", s);
        _ = exit(@as(i32, 1));
    }
    if (write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, 10)) != @as(i32, 10)) {
        printf("%s: unlinkread write failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    _ = unlink("unlinkread");
}
pub export fn linktest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const SZ: i32 = 5;
    _ = &SZ;
    const enum_unnamed_9 = u32;
    _ = &enum_unnamed_9;
    var fd: i32 = undefined;
    _ = &fd;
    _ = unlink("lf1");
    _ = unlink("lf2");
    fd = open("lf1", @as(i32, 512) | @as(i32, 2));
    if (fd < @as(i32, 0)) {
        printf("%s: create lf1 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (write(fd, @as(?*const anyopaque, @ptrCast("hello")), SZ) != SZ) {
        printf("%s: write lf1 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    if (link("lf1", "lf2") < @as(i32, 0)) {
        printf("%s: link lf1 lf2 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = unlink("lf1");
    if (open("lf1", @as(i32, 0)) >= @as(i32, 0)) {
        printf("%s: unlinked lf1 but it is still there!\n", s);
        _ = exit(@as(i32, 1));
    }
    fd = open("lf2", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: open lf2 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([12288]u8)))))) != SZ) {
        printf("%s: read lf2 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    if (link("lf2", "lf2") >= @as(i32, 0)) {
        printf("%s: link lf2 lf2 succeeded! oops\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = unlink("lf2");
    if (link("lf2", "lf1") >= @as(i32, 0)) {
        printf("%s: link non-existent succeeded! oops\n", s);
        _ = exit(@as(i32, 1));
    }
    if (link(".", "lf1") >= @as(i32, 0)) {
        printf("%s: link . lf1 succeeded! oops\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn concreate(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const N: i32 = 40;
    _ = &N;
    const enum_unnamed_10 = u32;
    _ = &enum_unnamed_10;
    var file: [3]u8 = undefined;
    _ = &file;
    var i: i32 = undefined;
    _ = &i;
    var pid: i32 = undefined;
    _ = &pid;
    var n: i32 = undefined;
    _ = &n;
    var fd: i32 = undefined;
    _ = &fd;
    var fa: [40]u8 = undefined;
    _ = &fa;
    const struct_unnamed_11 = extern struct {
        inum: ushort = @import("std").mem.zeroes(ushort),
        name: [14]u8 = @import("std").mem.zeroes([14]u8),
    };
    _ = &struct_unnamed_11;
    var de: struct_unnamed_11 = undefined;
    _ = &de;
    file[@as(u32, @intCast(@as(i32, 0)))] = 'C';
    file[@as(u32, @intCast(@as(i32, 2)))] = '\x00';
    {
        i = 0;
        while (i < N) : (i += 1) {
            file[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + i))));
            _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
            pid = fork();
            if ((pid != 0) and (@import("std").zig.c_translation.signedRemainder(i, @as(i32, 3)) == @as(i32, 1))) {
                _ = link("C0", @as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
            } else if ((pid == @as(i32, 0)) and (@import("std").zig.c_translation.signedRemainder(i, @as(i32, 5)) == @as(i32, 1))) {
                _ = link("C0", @as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
            } else {
                fd = open(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))), @as(i32, 512) | @as(i32, 2));
                if (fd < @as(i32, 0)) {
                    printf("concreate create %s failed\n", @as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
                    _ = exit(@as(i32, 1));
                }
                _ = close(fd);
            }
            if (pid == @as(i32, 0)) {
                _ = exit(@as(i32, 0));
            } else {
                var xstatus: i32 = undefined;
                _ = &xstatus;
                _ = wait(&xstatus);
                if (xstatus != @as(i32, 0)) {
                    _ = exit(@as(i32, 1));
                }
            }
        }
    }
    _ = memset(@as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&fa[@as(u64, @intCast(0))]))))), @as(i32, 0), @as(uint, @bitCast(@as(u32, @truncate(@sizeOf([40]u8))))));
    fd = open(".", @as(i32, 0));
    n = 0;
    while (read(fd, @as(?*anyopaque, @ptrCast(&de)), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf(struct_unnamed_11)))))) > @as(i32, 0)) {
        if (@as(i32, @bitCast(@as(u32, de.inum))) == @as(i32, 0)) continue;
        if ((@as(i32, @bitCast(@as(u32, de.name[@as(u32, @intCast(@as(i32, 0)))]))) == @as(i32, 'C')) and (@as(i32, @bitCast(@as(u32, de.name[@as(u32, @intCast(@as(i32, 2)))]))) == @as(i32, '\x00'))) {
            i = @as(i32, @bitCast(@as(u32, de.name[@as(u32, @intCast(@as(i32, 1)))]))) - @as(i32, '0');
            if ((i < @as(i32, 0)) or (@as(u64, @bitCast(@as(i64, i))) >= @sizeOf([40]u8))) {
                printf("%s: concreate weird file %s\n", s, @as([*c]u8, @ptrCast(@alignCast(&de.name[@as(u64, @intCast(0))]))));
                _ = exit(@as(i32, 1));
            }
            if (fa[@as(u32, @intCast(i))] != 0) {
                printf("%s: concreate duplicate file %s\n", s, @as([*c]u8, @ptrCast(@alignCast(&de.name[@as(u64, @intCast(0))]))));
                _ = exit(@as(i32, 1));
            }
            fa[@as(u32, @intCast(i))] = 1;
            n += 1;
        }
    }
    _ = close(fd);
    if (n != N) {
        printf("%s: concreate not enough files in directory listing\n", s);
        _ = exit(@as(i32, 1));
    }
    {
        i = 0;
        while (i < N) : (i += 1) {
            file[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + i))));
            pid = fork();
            if (pid < @as(i32, 0)) {
                printf("%s: fork failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (((@import("std").zig.c_translation.signedRemainder(i, @as(i32, 3)) == @as(i32, 0)) and (pid == @as(i32, 0))) or ((@import("std").zig.c_translation.signedRemainder(i, @as(i32, 3)) == @as(i32, 1)) and (pid != @as(i32, 0)))) {
                _ = close(open(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))), @as(i32, 0)));
                _ = close(open(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))), @as(i32, 0)));
                _ = close(open(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))), @as(i32, 0)));
                _ = close(open(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))), @as(i32, 0)));
                _ = close(open(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))), @as(i32, 0)));
                _ = close(open(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))), @as(i32, 0)));
            } else {
                _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
                _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
                _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
                _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
                _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
                _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&file[@as(u64, @intCast(0))]))));
            }
            if (pid == @as(i32, 0)) {
                _ = exit(@as(i32, 0));
            } else {
                _ = wait(null);
            }
        }
    }
}
pub export fn linkunlink(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid: i32 = undefined;
    _ = &pid;
    var i: i32 = undefined;
    _ = &i;
    _ = unlink("x");
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("%s: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    var x: u32 = @as(u32, @bitCast(if (pid != 0) @as(i32, 1) else @as(i32, 97)));
    _ = &x;
    {
        i = 0;
        while (i < @as(i32, 100)) : (i += 1) {
            x = (x *% @as(u32, @bitCast(@as(i32, 1103515245)))) +% @as(u32, @bitCast(@as(i32, 12345)));
            if ((x % @as(u32, @bitCast(@as(i32, 3)))) == @as(u32, @bitCast(@as(i32, 0)))) {
                _ = close(open("x", @as(i32, 2) | @as(i32, 512)));
            } else if ((x % @as(u32, @bitCast(@as(i32, 3)))) == @as(u32, @bitCast(@as(i32, 1)))) {
                _ = link("cat", "x");
            } else {
                _ = unlink("x");
            }
        }
    }
    if (pid != 0) {
        _ = wait(null);
    } else {
        _ = exit(@as(i32, 0));
    }
}
pub export fn subdir(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    var cc: i32 = undefined;
    _ = &cc;
    _ = unlink("ff");
    if (mkdir("dd") != @as(i32, 0)) {
        printf("%s: mkdir dd failed\n", s);
        _ = exit(@as(i32, 1));
    }
    fd = open("dd/ff", @as(i32, 512) | @as(i32, 2));
    if (fd < @as(i32, 0)) {
        printf("%s: create dd/ff failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = write(fd, @as(?*const anyopaque, @ptrCast("ff")), @as(i32, 2));
    _ = close(fd);
    if (unlink("dd") >= @as(i32, 0)) {
        printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (mkdir("/dd/dd") != @as(i32, 0)) {
        printf("%s: subdir mkdir dd/dd failed\n", s);
        _ = exit(@as(i32, 1));
    }
    fd = open("dd/dd/ff", @as(i32, 512) | @as(i32, 2));
    if (fd < @as(i32, 0)) {
        printf("%s: create dd/dd/ff failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = write(fd, @as(?*const anyopaque, @ptrCast("FF")), @as(i32, 2));
    _ = close(fd);
    fd = open("dd/dd/../ff", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: open dd/dd/../ff failed\n", s);
        _ = exit(@as(i32, 1));
    }
    cc = read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([12288]u8))))));
    if ((cc != @as(i32, 2)) or (@as(i32, @bitCast(@as(u32, buf[@as(u32, @intCast(@as(i32, 0)))]))) != @as(i32, 'f'))) {
        printf("%s: dd/dd/../ff wrong content\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    if (link("dd/dd/ff", "dd/dd/ffff") != @as(i32, 0)) {
        printf("%s: link dd/dd/ff dd/dd/ffff failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dd/dd/ff") != @as(i32, 0)) {
        printf("%s: unlink dd/dd/ff failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (open("dd/dd/ff", @as(i32, 0)) >= @as(i32, 0)) {
        printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("dd") != @as(i32, 0)) {
        printf("%s: chdir dd failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("dd/../../dd") != @as(i32, 0)) {
        printf("%s: chdir dd/../../dd failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("dd/../../../dd") != @as(i32, 0)) {
        printf("%s: chdir dd/../../../dd failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("./..") != @as(i32, 0)) {
        printf("%s: chdir ./.. failed\n", s);
        _ = exit(@as(i32, 1));
    }
    fd = open("dd/dd/ffff", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: open dd/dd/ffff failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([12288]u8)))))) != @as(i32, 2)) {
        printf("%s: read dd/dd/ffff wrong len\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    if (open("dd/dd/ff", @as(i32, 0)) >= @as(i32, 0)) {
        printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (open("dd/ff/ff", @as(i32, 512) | @as(i32, 2)) >= @as(i32, 0)) {
        printf("%s: create dd/ff/ff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (open("dd/xx/ff", @as(i32, 512) | @as(i32, 2)) >= @as(i32, 0)) {
        printf("%s: create dd/xx/ff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (open("dd", @as(i32, 512)) >= @as(i32, 0)) {
        printf("%s: create dd succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (open("dd", @as(i32, 2)) >= @as(i32, 0)) {
        printf("%s: open dd rdwr succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (open("dd", @as(i32, 1)) >= @as(i32, 0)) {
        printf("%s: open dd wronly succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (link("dd/ff/ff", "dd/dd/xx") == @as(i32, 0)) {
        printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (link("dd/xx/ff", "dd/dd/xx") == @as(i32, 0)) {
        printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (link("dd/ff", "dd/dd/ffff") == @as(i32, 0)) {
        printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (mkdir("dd/ff/ff") == @as(i32, 0)) {
        printf("%s: mkdir dd/ff/ff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (mkdir("dd/xx/ff") == @as(i32, 0)) {
        printf("%s: mkdir dd/xx/ff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (mkdir("dd/dd/ffff") == @as(i32, 0)) {
        printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dd/xx/ff") == @as(i32, 0)) {
        printf("%s: unlink dd/xx/ff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dd/ff/ff") == @as(i32, 0)) {
        printf("%s: unlink dd/ff/ff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("dd/ff") == @as(i32, 0)) {
        printf("%s: chdir dd/ff succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("dd/xx") == @as(i32, 0)) {
        printf("%s: chdir dd/xx succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dd/dd/ffff") != @as(i32, 0)) {
        printf("%s: unlink dd/dd/ff failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dd/ff") != @as(i32, 0)) {
        printf("%s: unlink dd/ff failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dd") == @as(i32, 0)) {
        printf("%s: unlink non-empty dd succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dd/dd") < @as(i32, 0)) {
        printf("%s: unlink dd/dd failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dd") < @as(i32, 0)) {
        printf("%s: unlink dd failed\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn bigwrite(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    var sz: i32 = undefined;
    _ = &sz;
    _ = unlink("bigwrite");
    {
        sz = 499;
        while (sz < ((@as(i32, 10) + @as(i32, 2)) * @as(i32, 1024))) : (sz += @as(i32, 471)) {
            fd = open("bigwrite", @as(i32, 512) | @as(i32, 2));
            if (fd < @as(i32, 0)) {
                printf("%s: cannot create bigwrite\n", s);
                _ = exit(@as(i32, 1));
            }
            var i: i32 = undefined;
            _ = &i;
            {
                i = 0;
                while (i < @as(i32, 2)) : (i += 1) {
                    var cc: i32 = write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), sz);
                    _ = &cc;
                    if (cc != sz) {
                        printf("%s: write(%d) ret %d\n", s, sz, cc);
                        _ = exit(@as(i32, 1));
                    }
                }
            }
            _ = close(fd);
            _ = unlink("bigwrite");
        }
    }
}
pub export fn bigfile(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const N: i32 = 20;
    _ = &N;
    const SZ: i32 = 600;
    _ = &SZ;
    const enum_unnamed_12 = u32;
    _ = &enum_unnamed_12;
    var fd: i32 = undefined;
    _ = &fd;
    var i: i32 = undefined;
    _ = &i;
    var total: i32 = undefined;
    _ = &total;
    var cc: i32 = undefined;
    _ = &cc;
    _ = unlink("bigfile.dat");
    fd = open("bigfile.dat", @as(i32, 512) | @as(i32, 2));
    if (fd < @as(i32, 0)) {
        printf("%s: cannot create bigfile", s);
        _ = exit(@as(i32, 1));
    }
    {
        i = 0;
        while (i < N) : (i += 1) {
            _ = memset(@as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), i, @as(uint, @bitCast(SZ)));
            if (write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), SZ) != SZ) {
                printf("%s: write bigfile failed\n", s);
                _ = exit(@as(i32, 1));
            }
        }
    }
    _ = close(fd);
    fd = open("bigfile.dat", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: cannot open bigfile\n", s);
        _ = exit(@as(i32, 1));
    }
    total = 0;
    {
        i = 0;
        while (true) : (i += 1) {
            cc = read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @divTrunc(SZ, @as(i32, 2)));
            if (cc < @as(i32, 0)) {
                printf("%s: read bigfile failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (cc == @as(i32, 0)) break;
            if (cc != @divTrunc(SZ, @as(i32, 2))) {
                printf("%s: short read bigfile\n", s);
                _ = exit(@as(i32, 1));
            }
            if ((@as(i32, @bitCast(@as(u32, buf[@as(u32, @intCast(@as(i32, 0)))]))) != @divTrunc(i, @as(i32, 2))) or (@as(i32, @bitCast(@as(u32, buf[@as(u32, @intCast(@divTrunc(SZ, @as(i32, 2)) - @as(i32, 1)))]))) != @divTrunc(i, @as(i32, 2)))) {
                printf("%s: read bigfile wrong data\n", s);
                _ = exit(@as(i32, 1));
            }
            total += cc;
        }
    }
    _ = close(fd);
    if (total != (N * SZ)) {
        printf("%s: read bigfile wrong total\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = unlink("bigfile.dat");
}
pub export fn fourteen(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    if (mkdir("12345678901234") != @as(i32, 0)) {
        printf("%s: mkdir 12345678901234 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (mkdir("12345678901234/123456789012345") != @as(i32, 0)) {
        printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    fd = open("123456789012345/123456789012345/123456789012345", @as(i32, 512));
    if (fd < @as(i32, 0)) {
        printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    fd = open("12345678901234/12345678901234/12345678901234", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    if (mkdir("12345678901234/12345678901234") == @as(i32, 0)) {
        printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (mkdir("123456789012345/12345678901234") == @as(i32, 0)) {
        printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = unlink("123456789012345/12345678901234");
    _ = unlink("12345678901234/12345678901234");
    _ = unlink("12345678901234/12345678901234/12345678901234");
    _ = unlink("123456789012345/123456789012345/123456789012345");
    _ = unlink("12345678901234/123456789012345");
    _ = unlink("12345678901234");
}
pub export fn rmdot(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    if (mkdir("dots") != @as(i32, 0)) {
        printf("%s: mkdir dots failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("dots") != @as(i32, 0)) {
        printf("%s: chdir dots failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink(".") == @as(i32, 0)) {
        printf("%s: rm . worked!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("..") == @as(i32, 0)) {
        printf("%s: rm .. worked!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (chdir("/") != @as(i32, 0)) {
        printf("%s: chdir / failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dots/.") == @as(i32, 0)) {
        printf("%s: unlink dots/. worked!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dots/..") == @as(i32, 0)) {
        printf("%s: unlink dots/.. worked!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dots") != @as(i32, 0)) {
        printf("%s: unlink dots failed!\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn dirfile(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    fd = open("dirfile", @as(i32, 512));
    if (fd < @as(i32, 0)) {
        printf("%s: create dirfile failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    if (chdir("dirfile") == @as(i32, 0)) {
        printf("%s: chdir dirfile succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    fd = open("dirfile/xx", @as(i32, 0));
    if (fd >= @as(i32, 0)) {
        printf("%s: create dirfile/xx succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    fd = open("dirfile/xx", @as(i32, 512));
    if (fd >= @as(i32, 0)) {
        printf("%s: create dirfile/xx succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (mkdir("dirfile/xx") == @as(i32, 0)) {
        printf("%s: mkdir dirfile/xx succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dirfile/xx") == @as(i32, 0)) {
        printf("%s: unlink dirfile/xx succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (link("README", "dirfile/xx") == @as(i32, 0)) {
        printf("%s: link to dirfile/xx succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (unlink("dirfile") != @as(i32, 0)) {
        printf("%s: unlink dirfile failed!\n", s);
        _ = exit(@as(i32, 1));
    }
    fd = open(".", @as(i32, 2));
    if (fd >= @as(i32, 0)) {
        printf("%s: open . for writing succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    fd = open(".", @as(i32, 0));
    if (write(fd, @as(?*const anyopaque, @ptrCast("x")), @as(i32, 1)) > @as(i32, 0)) {
        printf("%s: write . succeeded!\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
}
pub export fn iref(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var i: i32 = undefined;
    _ = &i;
    var fd: i32 = undefined;
    _ = &fd;
    {
        i = 0;
        while (i < (@as(i32, 50) + @as(i32, 1))) : (i += 1) {
            if (mkdir("irefd") != @as(i32, 0)) {
                printf("%s: mkdir irefd failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (chdir("irefd") != @as(i32, 0)) {
                printf("%s: chdir irefd failed\n", s);
                _ = exit(@as(i32, 1));
            }
            _ = mkdir("");
            _ = link("README", "");
            fd = open("", @as(i32, 512));
            if (fd >= @as(i32, 0)) {
                _ = close(fd);
            }
            fd = open("xx", @as(i32, 512));
            if (fd >= @as(i32, 0)) {
                _ = close(fd);
            }
            _ = unlink("xx");
        }
    }
    {
        i = 0;
        while (i < (@as(i32, 50) + @as(i32, 1))) : (i += 1) {
            _ = chdir("..");
            _ = unlink("irefd");
        }
    }
    _ = chdir("/");
}
pub export fn forktest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const N: i32 = 1000;
    _ = &N;
    const enum_unnamed_13 = u32;
    _ = &enum_unnamed_13;
    var n: i32 = undefined;
    _ = &n;
    var pid: i32 = undefined;
    _ = &pid;
    {
        n = 0;
        while (n < N) : (n += 1) {
            pid = fork();
            if (pid < @as(i32, 0)) break;
            if (pid == @as(i32, 0)) {
                _ = exit(@as(i32, 0));
            }
        }
    }
    if (n == @as(i32, 0)) {
        printf("%s: no fork at all!\n", s);
        _ = exit(@as(i32, 1));
    }
    if (n == N) {
        printf("%s: fork claimed to work 1000 times!\n", s);
        _ = exit(@as(i32, 1));
    }
    while (n > @as(i32, 0)) : (n -= 1) {
        if (wait(null) < @as(i32, 0)) {
            printf("%s: wait stopped early\n", s);
            _ = exit(@as(i32, 1));
        }
    }
    if (wait(null) != -@as(i32, 1)) {
        printf("%s: wait got too many\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn sbrkbasic(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const TOOMUCH: i32 = 1073741824;
    _ = &TOOMUCH;
    const enum_unnamed_14 = u32;
    _ = &enum_unnamed_14;
    var i: i32 = undefined;
    _ = &i;
    var pid: i32 = undefined;
    _ = &pid;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    var c: [*c]u8 = undefined;
    _ = &c;
    var a: [*c]u8 = undefined;
    _ = &a;
    var b: [*c]u8 = undefined;
    _ = &b;
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("fork failed in sbrkbasic\n");
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        a = sbrk(TOOMUCH);
        if (a == SBRK_ERROR) {
            _ = exit(@as(i32, 0));
        }
        {
            b = a;
            while (b < (a + @as(u64, @bitCast(@as(i64, @intCast(TOOMUCH)))))) : (b += @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096)))))) {
                b.* = 99;
            }
        }
        _ = exit(@as(i32, 1));
    }
    _ = wait(&xstatus);
    if (xstatus == @as(i32, 1)) {
        printf("%s: too much memory allocated!\n", s);
        _ = exit(@as(i32, 1));
    }
    a = sbrk(@as(i32, 0));
    {
        i = 0;
        while (i < @as(i32, 5000)) : (i += 1) {
            b = sbrk(@as(i32, 1));
            if (b != a) {
                printf("%s: sbrk test failed %d %p %p\n", s, i, a, b);
                _ = exit(@as(i32, 1));
            }
            b.* = 1;
            a = b + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 1)))));
        }
    }
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("%s: sbrk test fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    c = sbrk(@as(i32, 1));
    c = sbrk(@as(i32, 1));
    if (c != (a + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 1))))))) {
        printf("%s: sbrk test failed post-fork\n", s);
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        _ = exit(@as(i32, 0));
    }
    _ = wait(&xstatus);
    _ = exit(xstatus);
}
pub export fn sbrkmuch(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const BIG: i32 = 104857600;
    _ = &BIG;
    const enum_unnamed_15 = u32;
    _ = &enum_unnamed_15;
    var c: [*c]u8 = undefined;
    _ = &c;
    var oldbrk: [*c]u8 = undefined;
    _ = &oldbrk;
    var a: [*c]u8 = undefined;
    _ = &a;
    var lastaddr: [*c]u8 = undefined;
    _ = &lastaddr;
    var p: [*c]u8 = undefined;
    _ = &p;
    var amt: uint64 = undefined;
    _ = &amt;
    oldbrk = sbrk(@as(i32, 0));
    a = sbrk(@as(i32, 0));
    amt = @as(uint64, @bitCast(@as(i64, BIG))) -% @as(uint64, @intCast(@intFromPtr(a)));
    p = sbrk(@as(i32, @bitCast(@as(u32, @truncate(amt)))));
    if (p != a) {
        printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
        _ = exit(@as(i32, 1));
    }
    lastaddr = @as([*c]u8, @ptrFromInt(BIG - @as(i32, 1)));
    lastaddr.* = 99;
    a = sbrk(@as(i32, 0));
    c = sbrk(-@as(i32, 4096));
    if (c == SBRK_ERROR) {
        printf("%s: sbrk could not deallocate\n", s);
        _ = exit(@as(i32, 1));
    }
    c = sbrk(@as(i32, 0));
    if (c != (a - @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096))))))) {
        printf("%s: sbrk deallocation produced wrong address, a %p c %p\n", s, a, c);
        _ = exit(@as(i32, 1));
    }
    a = sbrk(@as(i32, 0));
    c = sbrk(@as(i32, 4096));
    if ((c != a) or (sbrk(@as(i32, 0)) != (a + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096)))))))) {
        printf("%s: sbrk re-allocation failed, a %p c %p\n", s, a, c);
        _ = exit(@as(i32, 1));
    }
    if (@as(i32, @bitCast(@as(u32, lastaddr.*))) == @as(i32, 99)) {
        printf("%s: sbrk de-allocation didn't really deallocate\n", s);
        _ = exit(@as(i32, 1));
    }
    a = sbrk(@as(i32, 0));
    c = sbrk(@as(i32, @bitCast(@as(i32, @truncate(-@divExact(@as(i64, @bitCast(@intFromPtr(sbrk(@as(i32, 0))) -% @intFromPtr(oldbrk))), @sizeOf(u8)))))));
    if (c != a) {
        printf("%s: sbrk downsize failed, a %p c %p\n", s, a, c);
        _ = exit(@as(i32, 1));
    }
}
pub export fn kernmem(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var a: [*c]u8 = undefined;
    _ = &a;
    var pid: i32 = undefined;
    _ = &pid;
    {
        a = @as([*c]u8, @ptrFromInt(@as(i64, 2147483648)));
        while (a < @as([*c]u8, @ptrFromInt(@as(i64, 2147483648) + @as(i64, @bitCast(@as(i64, @as(i32, 2000000))))))) : (a += @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 50000)))))) {
            pid = fork();
            if (pid < @as(i32, 0)) {
                printf("%s: fork failed\n", s);
                _ = exit(@as(i32, 1));
            }
            if (pid == @as(i32, 0)) {
                printf("%s: oops could read %p = %x\n", s, a, @as(i32, @bitCast(@as(u32, a.*))));
                _ = exit(@as(i32, 1));
            }
            var xstatus: i32 = undefined;
            _ = &xstatus;
            _ = wait(&xstatus);
            if (xstatus != -@as(i32, 1)) {
                _ = exit(@as(i32, 1));
            }
        }
    }
}
pub export fn MAXVAplus(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var a: uint64 = @as(uint64, @bitCast(@as(i64, 1) << @intCast((((@as(i32, 9) + @as(i32, 9)) + @as(i32, 9)) + @as(i32, 12)) - @as(i32, 1))));
    _ = &a;
    while (a != @as(uint64, @bitCast(@as(i64, @as(i32, 0))))) : (a <<= @intCast(@as(i32, 1))) {
        var pid: i32 = undefined;
        _ = &pid;
        pid = fork();
        if (pid < @as(i32, 0)) {
            printf("%s: fork failed\n", s);
            _ = exit(@as(i32, 1));
        }
        if (pid == @as(i32, 0)) {
            @as([*c]u8, @ptrFromInt(a)).* = 99;
            printf("%s: oops wrote %p\n", s, @as(?*anyopaque, @ptrFromInt(a)));
            _ = exit(@as(i32, 1));
        }
        var xstatus: i32 = undefined;
        _ = &xstatus;
        _ = wait(&xstatus);
        if (xstatus != -@as(i32, 1)) {
            _ = exit(@as(i32, 1));
        }
    }
}
pub export fn sbrkfail(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const BIG: i32 = 104857600;
    _ = &BIG;
    const enum_unnamed_16 = u32;
    _ = &enum_unnamed_16;
    var i: i32 = undefined;
    _ = &i;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    var fds: [2]i32 = undefined;
    _ = &fds;
    var scratch: u8 = undefined;
    _ = &scratch;
    var c: [*c]u8 = undefined;
    _ = &c;
    var a: [*c]u8 = undefined;
    _ = &a;
    var pids: [10]i32 = undefined;
    _ = &pids;
    var pid: i32 = undefined;
    _ = &pid;
    var failed: i32 = undefined;
    _ = &failed;
    failed = 0;
    if (pipe(@as([*c]i32, @ptrCast(@alignCast(&fds[@as(u64, @intCast(0))])))) != @as(i32, 0)) {
        printf("%s: pipe() failed\n", s);
        _ = exit(@as(i32, 1));
    }
    {
        i = 0;
        while (@as(u64, @bitCast(@as(i64, i))) < (@sizeOf([10]i32) / @sizeOf(i32))) : (i += 1) {
            if ((blk: {
                const tmp = fork();
                pids[@as(u32, @intCast(i))] = tmp;
                break :blk tmp;
            }) == @as(i32, 0)) {
                if (sbrk(@as(i32, @bitCast(@as(u32, @truncate(@as(uint64, @bitCast(@as(i64, BIG))) -% @as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0)))))))))) == SBRK_ERROR) {
                    _ = write(fds[@as(u32, @intCast(@as(i32, 1)))], @as(?*const anyopaque, @ptrCast("0")), @as(i32, 1));
                } else {
                    _ = write(fds[@as(u32, @intCast(@as(i32, 1)))], @as(?*const anyopaque, @ptrCast("1")), @as(i32, 1));
                }
                while (true) {
                    _ = pause(@as(i32, 1000));
                }
            }
            if (pids[@as(u32, @intCast(i))] != -@as(i32, 1)) {
                _ = read(fds[@as(u32, @intCast(@as(i32, 0)))], @as(?*anyopaque, @ptrCast(&scratch)), @as(i32, 1));
                if (@as(i32, @bitCast(@as(u32, scratch))) == @as(i32, '0')) {
                    failed = 1;
                }
            }
        }
    }
    if (!(failed != 0)) {
        printf("%s: no allocation failed; allocate more?\n", s);
    }
    c = sbrk(@as(i32, 4096));
    {
        i = 0;
        while (@as(u64, @bitCast(@as(i64, i))) < (@sizeOf([10]i32) / @sizeOf(i32))) : (i += 1) {
            if (pids[@as(u32, @intCast(i))] == -@as(i32, 1)) continue;
            _ = kill(pids[@as(u32, @intCast(i))]);
            _ = wait(null);
        }
    }
    if (c == SBRK_ERROR) {
        printf("%s: failed sbrk leaked memory\n", s);
        _ = exit(@as(i32, 1));
    }
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("%s: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        a = sbrk(@as(i32, 10) * BIG);
        if (a == SBRK_ERROR) {
            _ = exit(@as(i32, 0));
        }
        printf("%s: allocate a lot of memory succeeded %d\n", s, @as(i32, 10) * BIG);
        _ = exit(@as(i32, 1));
    }
    _ = wait(&xstatus);
    if (xstatus != @as(i32, 0)) {
        _ = exit(@as(i32, 1));
    }
}
pub export fn sbrkarg(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var a: [*c]u8 = undefined;
    _ = &a;
    var fd: i32 = undefined;
    _ = &fd;
    var n: i32 = undefined;
    _ = &n;
    a = sbrk(@as(i32, 4096));
    fd = open("sbrk", @as(i32, 512) | @as(i32, 1));
    _ = unlink("sbrk");
    if (fd < @as(i32, 0)) {
        printf("%s: open sbrk failed\n", s);
        _ = exit(@as(i32, 1));
    }
    if ((blk: {
        const tmp = write(fd, @as(?*const anyopaque, @ptrCast(a)), @as(i32, 4096));
        n = tmp;
        break :blk tmp;
    }) < @as(i32, 0)) {
        printf("%s: write sbrk failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    a = sbrk(@as(i32, 4096));
    if (pipe(@as([*c]i32, @ptrCast(@alignCast(a)))) != @as(i32, 0)) {
        printf("%s: pipe() failed\n", s);
        _ = exit(@as(i32, 1));
    }
}
pub export fn validatetest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var hi: i32 = undefined;
    _ = &hi;
    var p: uint64 = undefined;
    _ = &p;
    hi = @as(i32, 1100) * @as(i32, 1024);
    {
        p = 0;
        while (p <= @as(uint64, @bitCast(@as(u64, @as(uint, @bitCast(hi)))))) : (p +%= @as(uint64, @bitCast(@as(i64, @as(i32, 4096))))) {
            if (link("nosuchfile", @as([*c]u8, @ptrFromInt(p))) != -@as(i32, 1)) {
                printf("%s: link should not succeed\n", s);
                _ = exit(@as(i32, 1));
            }
        }
    }
}
pub export var uninit: [10000]u8 = @import("std").mem.zeroes([10000]u8);
pub export fn bsstest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var i: i32 = undefined;
    _ = &i;
    {
        i = 0;
        while (@as(u64, @bitCast(@as(i64, i))) < @sizeOf([10000]u8)) : (i += 1) {
            if (@as(i32, @bitCast(@as(u32, uninit[@as(u32, @intCast(i))]))) != @as(i32, '\x00')) {
                printf("%s: bss test failed\n", s);
                _ = exit(@as(i32, 1));
            }
        }
    }
}
pub export fn bigargtest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid: i32 = undefined;
    _ = &pid;
    var fd: i32 = undefined;
    _ = &fd;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    _ = unlink("bigarg-ok");
    pid = fork();
    if (pid == @as(i32, 0)) {
        const args = struct {
            var static: [32][*c]u8 = @import("std").mem.zeroes([32][*c]u8);
        };
        _ = &args;
        var i: i32 = undefined;
        _ = &i;
        var big_1: [400]u8 = undefined;
        _ = &big_1;
        _ = memset(@as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&big_1[@as(u64, @intCast(0))]))))), @as(i32, ' '), @as(uint, @bitCast(@as(u32, @truncate(@sizeOf([400]u8))))));
        big_1[@sizeOf([400]u8) -% @as(u64, @bitCast(@as(i64, @as(i32, 1))))] = '\x00';
        {
            i = 0;
            while (i < (@as(i32, 32) - @as(i32, 1))) : (i += 1) {
                args.static[@as(u32, @intCast(i))] = @as([*c]u8, @ptrCast(@alignCast(&big_1[@as(u64, @intCast(0))])));
            }
        }
        args.static[@as(u32, @intCast(@as(i32, 32) - @as(i32, 1)))] = null;
        _ = exec("echo", @as([*c][*c]u8, @ptrCast(@alignCast(&args.static[@as(u64, @intCast(0))]))));
        fd = open("bigarg-ok", @as(i32, 512));
        _ = close(fd);
        _ = exit(@as(i32, 0));
    } else if (pid < @as(i32, 0)) {
        printf("%s: bigargtest: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = wait(&xstatus);
    if (xstatus != @as(i32, 0)) {
        _ = exit(xstatus);
    }
    fd = open("bigarg-ok", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: bigarg test failed!\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
}
pub export fn fsfull() void {
    var nfiles: i32 = undefined;
    _ = &nfiles;
    var fsblocks: i32 = 0;
    _ = &fsblocks;
    printf("fsfull test\n");
    {
        nfiles = 0;
        while (true) : (nfiles += 1) {
            var name: [64]u8 = undefined;
            _ = &name;
            name[@as(u32, @intCast(@as(i32, 0)))] = 'f';
            name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(nfiles, @as(i32, 1000))))));
            name[@as(u32, @intCast(@as(i32, 2)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(@import("std").zig.c_translation.signedRemainder(nfiles, @as(i32, 1000)), @as(i32, 100))))));
            name[@as(u32, @intCast(@as(i32, 3)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(@import("std").zig.c_translation.signedRemainder(nfiles, @as(i32, 100)), @as(i32, 10))))));
            name[@as(u32, @intCast(@as(i32, 4)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @import("std").zig.c_translation.signedRemainder(nfiles, @as(i32, 10))))));
            name[@as(u32, @intCast(@as(i32, 5)))] = '\x00';
            printf("writing %s\n", @as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
            var fd: i32 = open(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))), @as(i32, 512) | @as(i32, 2));
            _ = &fd;
            if (fd < @as(i32, 0)) {
                printf("open %s failed\n", @as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                break;
            }
            var total: i32 = 0;
            _ = &total;
            while (true) {
                var cc: i32 = write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), @as(i32, 1024));
                _ = &cc;
                if (cc < @as(i32, 1024)) break;
                total += cc;
                fsblocks += 1;
            }
            printf("wrote %d bytes\n", total);
            _ = close(fd);
            if (total == @as(i32, 0)) break;
        }
    }
    while (nfiles >= @as(i32, 0)) {
        var name: [64]u8 = undefined;
        _ = &name;
        name[@as(u32, @intCast(@as(i32, 0)))] = 'f';
        name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(nfiles, @as(i32, 1000))))));
        name[@as(u32, @intCast(@as(i32, 2)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(@import("std").zig.c_translation.signedRemainder(nfiles, @as(i32, 1000)), @as(i32, 100))))));
        name[@as(u32, @intCast(@as(i32, 3)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(@import("std").zig.c_translation.signedRemainder(nfiles, @as(i32, 100)), @as(i32, 10))))));
        name[@as(u32, @intCast(@as(i32, 4)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @import("std").zig.c_translation.signedRemainder(nfiles, @as(i32, 10))))));
        name[@as(u32, @intCast(@as(i32, 5)))] = '\x00';
        _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
        nfiles -= 1;
    }
    printf("fsfull test finished\n");
}
pub export fn argptest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fd: i32 = undefined;
    _ = &fd;
    fd = open("init", @as(i32, 0));
    if (fd < @as(i32, 0)) {
        printf("%s: open failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = read(fd, @as(?*anyopaque, @ptrCast(sbrk(@as(i32, 0)) - @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 1))))))), -@as(i32, 1));
    _ = close(fd);
}
pub export fn stacktest(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid: i32 = undefined;
    _ = &pid;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    pid = fork();
    if (pid == @as(i32, 0)) {
        var sp: [*c]u8 = @as([*c]u8, @ptrFromInt(r_sp()));
        _ = &sp;
        sp -= @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 1) * @as(i32, 4096)))));
        printf("%s: stacktest: read below stack %d\n", s, @as(i32, @bitCast(@as(u32, sp.*))));
        _ = exit(@as(i32, 1));
    } else if (pid < @as(i32, 0)) {
        printf("%s: fork failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = wait(&xstatus);
    if (xstatus == -@as(i32, 1)) {
        _ = exit(@as(i32, 0));
    } else {
        _ = exit(xstatus);
    }
}
pub export fn nowrite(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid: i32 = undefined;
    _ = &pid;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    var addrs: [6]uint64 = [6]uint64{
        0,
        @as(uint64, @bitCast(@as(i64, @truncate(@as(i64, 2147483648))))),
        @as(uint64, @bitCast(@as(i64, 274877898752))),
        @as(uint64, @bitCast(@as(i64, 274877902848))),
        @as(uint64, @bitCast(@as(i64, 274877906944))),
        18446744073709551615,
    };
    _ = &addrs;
    {
        var ai: i32 = 0;
        _ = &ai;
        while (@as(u64, @bitCast(@as(i64, ai))) < (@sizeOf([6]uint64) / @sizeOf(uint64))) : (ai += 1) {
            pid = fork();
            if (pid == @as(i32, 0)) {
                var addr: [*c]volatile i32 = @as([*c]i32, @ptrFromInt(addrs[@as(u32, @intCast(ai))]));
                _ = &addr;
                addr.* = 10;
                printf("%s: write to %p did not fail!\n", s, addr);
                _ = exit(@as(i32, 0));
            } else if (pid < @as(i32, 0)) {
                printf("%s: fork failed\n", s);
                _ = exit(@as(i32, 1));
            }
            _ = wait(&xstatus);
            if (xstatus == @as(i32, 0)) {
                _ = exit(@as(i32, 1));
            }
        }
    }
    _ = exit(@as(i32, 0));
}
pub export var big: ?*anyopaque = @as(?*anyopaque, @ptrFromInt(@as(u64, 16927636109872082782)));
pub export fn pgbug(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var argv: [1][*c]u8 = undefined;
    _ = &argv;
    argv[@as(u32, @intCast(@as(i32, 0)))] = null;
    _ = exec(@as([*c]const u8, @ptrCast(@alignCast(big))), @as([*c][*c]u8, @ptrCast(@alignCast(&argv[@as(u64, @intCast(0))]))));
    _ = pipe(@as([*c]i32, @ptrCast(@alignCast(big))));
    _ = exit(@as(i32, 0));
}
pub export fn sbrkbugs(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid: i32 = fork();
    _ = &pid;
    if (pid < @as(i32, 0)) {
        printf("fork failed\n");
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        var sz: i32 = @as(i32, @bitCast(@as(u32, @truncate(@as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0)))))))));
        _ = &sz;
        _ = sbrk(-sz);
        _ = exit(@as(i32, 0));
    }
    _ = wait(null);
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("fork failed\n");
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        var sz: i32 = @as(i32, @bitCast(@as(u32, @truncate(@as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0)))))))));
        _ = &sz;
        _ = sbrk(-(sz - @as(i32, 3500)));
        _ = exit(@as(i32, 0));
    }
    _ = wait(null);
    pid = fork();
    if (pid < @as(i32, 0)) {
        printf("fork failed\n");
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        _ = sbrk(@as(i32, @bitCast(@as(u32, @truncate(@as(uint64, @bitCast(@as(i64, (@as(i32, 10) * @as(i32, 4096)) + @as(i32, 2048)))) -% @as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0))))))))));
        _ = sbrk(-@as(i32, 10));
        _ = exit(@as(i32, 0));
    }
    _ = wait(null);
    _ = exit(@as(i32, 0));
}
pub export fn sbrklast(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var top: uint64 = @as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0)))));
    _ = &top;
    if ((top % @as(uint64, @bitCast(@as(i64, @as(i32, 4096))))) != @as(uint64, @bitCast(@as(i64, @as(i32, 0))))) {
        _ = sbrk(@as(i32, @bitCast(@as(u32, @truncate(@as(uint64, @bitCast(@as(i64, @as(i32, 4096)))) -% (top % @as(uint64, @bitCast(@as(i64, @as(i32, 4096))))))))));
    }
    _ = sbrk(@as(i32, 4096));
    _ = sbrk(@as(i32, 10));
    _ = sbrk(-@as(i32, 20));
    top = @as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0)))));
    var p: [*c]u8 = @as([*c]u8, @ptrFromInt(top -% @as(uint64, @bitCast(@as(i64, @as(i32, 64))))));
    _ = &p;
    p[@as(u32, @intCast(@as(i32, 0)))] = 'x';
    p[@as(u32, @intCast(@as(i32, 1)))] = '\x00';
    var fd: i32 = open(p, @as(i32, 2) | @as(i32, 512));
    _ = &fd;
    _ = write(fd, @as(?*const anyopaque, @ptrCast(p)), @as(i32, 1));
    _ = close(fd);
    fd = open(p, @as(i32, 2));
    p[@as(u32, @intCast(@as(i32, 0)))] = '\x00';
    _ = read(fd, @as(?*anyopaque, @ptrCast(p)), @as(i32, 1));
    if (@as(i32, @bitCast(@as(u32, p[@as(u32, @intCast(@as(i32, 0)))]))) != @as(i32, 'x')) {
        _ = exit(@as(i32, 1));
    }
}
pub export fn sbrk8000(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    _ = sbrk(@as(i32, @bitCast(@as(u32, 2147483652))));
    var top: [*c]volatile u8 = sbrk(@as(i32, 0));
    _ = &top;
    (top - @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 1)))))).* = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, @bitCast(@as(u32, (top - @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 1)))))).*))) + @as(i32, 1)))));
}
pub export fn badarg(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < @as(i32, 50000)) : (i += 1) {
            var argv: [2][*c]u8 = undefined;
            _ = &argv;
            argv[@as(u32, @intCast(@as(i32, 0)))] = @as([*c]u8, @ptrFromInt(@as(u32, 4294967295)));
            argv[@as(u32, @intCast(@as(i32, 1)))] = null;
            _ = exec("echo", @as([*c][*c]u8, @ptrCast(@alignCast(&argv[@as(u64, @intCast(0))]))));
        }
    }
    _ = exit(@as(i32, 0));
}
pub export fn lazy_alloc(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var i: [*c]u8 = undefined;
    _ = &i;
    var prev_end: [*c]u8 = undefined;
    _ = &prev_end;
    var new_end: [*c]u8 = undefined;
    _ = &new_end;
    prev_end = sbrklazy((@as(i32, 1024) * @as(i32, 1024)) * @as(i32, 1024));
    if (prev_end == SBRK_ERROR) {
        printf("sbrklazy() failed\n");
        _ = exit(@as(i32, 1));
    }
    new_end = prev_end + @as(u64, @bitCast(@as(i64, @intCast((@as(i32, 1024) * @as(i32, 1024)) * @as(i32, 1024)))));
    {
        i = prev_end + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096)))));
        while (i < new_end) : (i += @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 64) * @as(i32, 4096)))))) {
            @as([*c][*c]u8, @ptrCast(@alignCast(i))).* = i;
        }
    }
    {
        i = prev_end + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096)))));
        while (i < new_end) : (i += @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 64) * @as(i32, 4096)))))) {
            if (@as([*c][*c]u8, @ptrCast(@alignCast(i))).* != i) {
                printf("failed to read value from memory\n");
                _ = exit(@as(i32, 1));
            }
        }
    }
    _ = exit(@as(i32, 0));
}
pub export fn lazy_unmap(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var pid: i32 = undefined;
    _ = &pid;
    var i: [*c]u8 = undefined;
    _ = &i;
    var prev_end: [*c]u8 = undefined;
    _ = &prev_end;
    var new_end: [*c]u8 = undefined;
    _ = &new_end;
    prev_end = sbrklazy((@as(i32, 1024) * @as(i32, 1024)) * @as(i32, 1024));
    if (prev_end == SBRK_ERROR) {
        printf("sbrklazy() failed\n");
        _ = exit(@as(i32, 1));
    }
    new_end = prev_end + @as(u64, @bitCast(@as(i64, @intCast((@as(i32, 1024) * @as(i32, 1024)) * @as(i32, 1024)))));
    {
        i = prev_end + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096)))));
        while (i < new_end) : (i += @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096) * @as(i32, 4096)))))) {
            @as([*c][*c]u8, @ptrCast(@alignCast(i))).* = i;
        }
    }
    {
        i = prev_end + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096)))));
        while (i < new_end) : (i += @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096) * @as(i32, 4096)))))) {
            pid = fork();
            if (pid < @as(i32, 0)) {
                printf("error forking\n");
                _ = exit(@as(i32, 1));
            } else if (pid == @as(i32, 0)) {
                _ = sbrklazy(@as(i32, @bitCast(@as(i32, @truncate(-@as(i64, 1) * @as(i64, @bitCast(@as(i64, (@as(i32, 1024) * @as(i32, 1024)) * @as(i32, 1024)))))))));
                @as([*c][*c]u8, @ptrCast(@alignCast(i))).* = i;
                _ = exit(@as(i32, 0));
            } else {
                var status: i32 = undefined;
                _ = &status;
                _ = wait(&status);
                if (status == @as(i32, 0)) {
                    printf("memory not unmapped\n");
                    _ = exit(@as(i32, 1));
                }
            }
        }
    }
    _ = exit(@as(i32, 0));
}
pub export fn lazy_copy(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    {
        var p: [*c]u8 = sbrk(@as(i32, 0));
        _ = &p;
        _ = sbrklazy(@as(i32, 4) * @as(i32, 4096));
        _ = open(p + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 8192))))), @as(i32, 0));
    }
    {
        var xx: ?*anyopaque = @as(?*anyopaque, @ptrCast(sbrk(@as(i32, 0))));
        _ = &xx;
        var ret: ?*anyopaque = @as(?*anyopaque, @ptrCast(sbrk(@as(i32, @bitCast(@as(u32, @truncate(-%(@as(uint64, @intCast(@intFromPtr(xx))) +% @as(uint64, @bitCast(@as(i64, @as(i32, 1))))))))))));
        _ = &ret;
        if (ret != xx) {
            printf("sbrk(sbrk(0)+1) returned %p, not old sz\n", ret);
            _ = exit(@as(i32, 1));
        }
    }
    var bad: [6]u64 = [6]u64{
        @as(u64, @bitCast(@as(i64, 274877890560))),
        @as(u64, @bitCast(@as(i64, 274877894656))),
        @as(u64, @bitCast(@as(i64, 274877898752))),
        @as(u64, @bitCast(@as(i64, 274877902848))),
        @as(u64, @bitCast(@as(i64, 274877906944))),
        @as(u64, @bitCast(@as(i64, 549755813888))),
    };
    _ = &bad;
    {
        var i: i32 = 0;
        _ = &i;
        while (@as(u64, @bitCast(@as(i64, i))) < (@sizeOf([6]u64) / @sizeOf(u64))) : (i += 1) {
            var fd: i32 = open("README", @as(i32, 0));
            _ = &fd;
            if (fd < @as(i32, 0)) {
                printf("cannot open README\n");
                _ = exit(@as(i32, 1));
            }
            if (read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrFromInt(bad[@as(u32, @intCast(i))])))), @as(i32, 512)) >= @as(i32, 0)) {
                printf("read succeeded\n");
                _ = exit(@as(i32, 1));
            }
            _ = close(fd);
            fd = open("junk", (@as(i32, 512) | @as(i32, 2)) | @as(i32, 1024));
            if (fd < @as(i32, 0)) {
                printf("cannot open junk\n");
                _ = exit(@as(i32, 1));
            }
            if (write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrFromInt(bad[@as(u32, @intCast(i))])))), @as(i32, 512)) >= @as(i32, 0)) {
                printf("write succeeded\n");
                _ = exit(@as(i32, 1));
            }
            _ = close(fd);
        }
    }
    _ = exit(@as(i32, 0));
}
pub export fn lazy_sbrk(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var p: [*c]u8 = sbrk(@as(i32, 0));
    _ = &p;
    while (@as(uint64, @intCast(@intFromPtr(p))) < @as(uint64, @bitCast((@as(i64, 1) << @intCast((((@as(i32, 9) + @as(i32, 9)) + @as(i32, 9)) + @as(i32, 12)) - @as(i32, 1))) - @as(i64, @bitCast(@as(i64, @as(i32, 1) << @intCast(30))))))) {
        p = sbrklazy(@as(i32, 1) << @intCast(30));
        if (p < null) {
            printf("sbrklazy(%d) returned %p\n", @as(i32, 1) << @intCast(30), p);
            _ = exit(@as(i32, 1));
        }
        p = sbrklazy(@as(i32, 0));
    }
    var n: i32 = @as(i32, @bitCast(@as(u32, @truncate(@as(uint64, @bitCast((((@as(i64, 1) << @intCast((((@as(i32, 9) + @as(i32, 9)) + @as(i32, 9)) + @as(i32, 12)) - @as(i32, 1))) - @as(i64, @bitCast(@as(i64, @as(i32, 4096))))) - @as(i64, @bitCast(@as(i64, @as(i32, 4096))))) - @as(i64, @bitCast(@as(i64, @as(i32, 4096)))))) -% @as(uint64, @intCast(@intFromPtr(p)))))));
    _ = &n;
    var p1: [*c]u8 = sbrklazy(n);
    _ = &p1;
    if ((p1 < null) or (p1 != p)) {
        printf("sbrklazy(%d) returned %p, not expected %p\n", n, p1, p);
        _ = exit(@as(i32, 1));
    }
    p = sbrk(@as(i32, 4096));
    if ((p < null) or (@as(uint64, @intCast(@intFromPtr(p))) != @as(uint64, @bitCast((((@as(i64, 1) << @intCast((((@as(i32, 9) + @as(i32, 9)) + @as(i32, 9)) + @as(i32, 12)) - @as(i32, 1))) - @as(i64, @bitCast(@as(i64, @as(i32, 4096))))) - @as(i64, @bitCast(@as(i64, @as(i32, 4096))))) - @as(i64, @bitCast(@as(i64, @as(i32, 4096)))))))) {
        printf("sbrk(%d) returned %p, not expected TRAPFRAME-PGSIZE\n", @as(i32, 4096), p);
        _ = exit(@as(i32, 1));
    }
    p[@as(u32, @intCast(@as(i32, 0)))] = 1;
    if (@as(i32, @bitCast(@as(u32, p[@as(u32, @intCast(@as(i32, 1)))]))) != @as(i32, 0)) {
        printf("sbrk() returned non-zero-filled memory\n");
        _ = exit(@as(i32, 1));
    }
    p = sbrk(@as(i32, 1));
    if (@as(uint64, @intCast(@intFromPtr(p))) != @as(uint64, @bitCast(@as(i64, -@as(i32, 1))))) {
        printf("sbrk(1) returned %p, expected error\n", p);
        _ = exit(@as(i32, 1));
    }
    p = sbrklazy(@as(i32, 1));
    if (@as(uint64, @intCast(@intFromPtr(p))) != @as(uint64, @bitCast(@as(i64, -@as(i32, 1))))) {
        printf("sbrklazy(1) returned %p, expected error\n", p);
        _ = exit(@as(i32, 1));
    }
    _ = exit(@as(i32, 0));
}
pub const struct_test = extern struct {
    f: ?*const fn ([*c]u8) callconv(.c) void = @import("std").mem.zeroes(?*const fn ([*c]u8) callconv(.c) void),
    s: [*c]u8 = @import("std").mem.zeroes([*c]u8),
};
pub export var quicktests: [65]struct_test = [65]struct_test{
    struct_test{
        .f = &copyin,
        .s = &(struct {
            var static = "copyin".*;
        }).static,
    },
    struct_test{
        .f = &copyout,
        .s = &(struct {
            var static = "copyout".*;
        }).static,
    },
    struct_test{
        .f = &copyinstr1,
        .s = &(struct {
            var static = "copyinstr1".*;
        }).static,
    },
    struct_test{
        .f = &copyinstr2,
        .s = &(struct {
            var static = "copyinstr2".*;
        }).static,
    },
    struct_test{
        .f = &copyinstr3,
        .s = &(struct {
            var static = "copyinstr3".*;
        }).static,
    },
    struct_test{
        .f = &rwsbrk,
        .s = &(struct {
            var static = "rwsbrk".*;
        }).static,
    },
    struct_test{
        .f = &truncate1,
        .s = &(struct {
            var static = "truncate1".*;
        }).static,
    },
    struct_test{
        .f = &truncate2,
        .s = &(struct {
            var static = "truncate2".*;
        }).static,
    },
    struct_test{
        .f = &truncate3,
        .s = &(struct {
            var static = "truncate3".*;
        }).static,
    },
    struct_test{
        .f = &openiputtest,
        .s = &(struct {
            var static = "openiput".*;
        }).static,
    },
    struct_test{
        .f = &exitiputtest,
        .s = &(struct {
            var static = "exitiput".*;
        }).static,
    },
    struct_test{
        .f = &iputtest,
        .s = &(struct {
            var static = "iput".*;
        }).static,
    },
    struct_test{
        .f = &opentest,
        .s = &(struct {
            var static = "opentest".*;
        }).static,
    },
    struct_test{
        .f = &writetest,
        .s = &(struct {
            var static = "writetest".*;
        }).static,
    },
    struct_test{
        .f = &writebig,
        .s = &(struct {
            var static = "writebig".*;
        }).static,
    },
    struct_test{
        .f = &createtest,
        .s = &(struct {
            var static = "createtest".*;
        }).static,
    },
    struct_test{
        .f = &dirtest,
        .s = &(struct {
            var static = "dirtest".*;
        }).static,
    },
    struct_test{
        .f = &exectest,
        .s = &(struct {
            var static = "exectest".*;
        }).static,
    },
    struct_test{
        .f = &pipe1,
        .s = &(struct {
            var static = "pipe1".*;
        }).static,
    },
    struct_test{
        .f = &killstatus,
        .s = &(struct {
            var static = "killstatus".*;
        }).static,
    },
    struct_test{
        .f = &preempt,
        .s = &(struct {
            var static = "preempt".*;
        }).static,
    },
    struct_test{
        .f = &exitwait,
        .s = &(struct {
            var static = "exitwait".*;
        }).static,
    },
    struct_test{
        .f = &reparent,
        .s = &(struct {
            var static = "reparent".*;
        }).static,
    },
    struct_test{
        .f = &twochildren,
        .s = &(struct {
            var static = "twochildren".*;
        }).static,
    },
    struct_test{
        .f = &forkfork,
        .s = &(struct {
            var static = "forkfork".*;
        }).static,
    },
    struct_test{
        .f = &forkforkfork,
        .s = &(struct {
            var static = "forkforkfork".*;
        }).static,
    },
    struct_test{
        .f = &reparent2,
        .s = &(struct {
            var static = "reparent2".*;
        }).static,
    },
    struct_test{
        .f = &mem,
        .s = &(struct {
            var static = "mem".*;
        }).static,
    },
    struct_test{
        .f = &sharedfd,
        .s = &(struct {
            var static = "sharedfd".*;
        }).static,
    },
    struct_test{
        .f = &fourfiles,
        .s = &(struct {
            var static = "fourfiles".*;
        }).static,
    },
    struct_test{
        .f = &createdelete,
        .s = &(struct {
            var static = "createdelete".*;
        }).static,
    },
    struct_test{
        .f = &unlinkread,
        .s = &(struct {
            var static = "unlinkread".*;
        }).static,
    },
    struct_test{
        .f = &linktest,
        .s = &(struct {
            var static = "linktest".*;
        }).static,
    },
    struct_test{
        .f = &concreate,
        .s = &(struct {
            var static = "concreate".*;
        }).static,
    },
    struct_test{
        .f = &linkunlink,
        .s = &(struct {
            var static = "linkunlink".*;
        }).static,
    },
    struct_test{
        .f = &subdir,
        .s = &(struct {
            var static = "subdir".*;
        }).static,
    },
    struct_test{
        .f = &bigwrite,
        .s = &(struct {
            var static = "bigwrite".*;
        }).static,
    },
    struct_test{
        .f = &bigfile,
        .s = &(struct {
            var static = "bigfile".*;
        }).static,
    },
    struct_test{
        .f = &fourteen,
        .s = &(struct {
            var static = "fourteen".*;
        }).static,
    },
    struct_test{
        .f = &rmdot,
        .s = &(struct {
            var static = "rmdot".*;
        }).static,
    },
    struct_test{
        .f = &dirfile,
        .s = &(struct {
            var static = "dirfile".*;
        }).static,
    },
    struct_test{
        .f = &iref,
        .s = &(struct {
            var static = "iref".*;
        }).static,
    },
    struct_test{
        .f = &forktest,
        .s = &(struct {
            var static = "forktest".*;
        }).static,
    },
    struct_test{
        .f = &sbrkbasic,
        .s = &(struct {
            var static = "sbrkbasic".*;
        }).static,
    },
    struct_test{
        .f = &sbrkmuch,
        .s = &(struct {
            var static = "sbrkmuch".*;
        }).static,
    },
    struct_test{
        .f = &kernmem,
        .s = &(struct {
            var static = "kernmem".*;
        }).static,
    },
    struct_test{
        .f = &MAXVAplus,
        .s = &(struct {
            var static = "MAXVAplus".*;
        }).static,
    },
    struct_test{
        .f = &sbrkfail,
        .s = &(struct {
            var static = "sbrkfail".*;
        }).static,
    },
    struct_test{
        .f = &sbrkarg,
        .s = &(struct {
            var static = "sbrkarg".*;
        }).static,
    },
    struct_test{
        .f = &validatetest,
        .s = &(struct {
            var static = "validatetest".*;
        }).static,
    },
    struct_test{
        .f = &bsstest,
        .s = &(struct {
            var static = "bsstest".*;
        }).static,
    },
    struct_test{
        .f = &bigargtest,
        .s = &(struct {
            var static = "bigargtest".*;
        }).static,
    },
    struct_test{
        .f = &argptest,
        .s = &(struct {
            var static = "argptest".*;
        }).static,
    },
    struct_test{
        .f = &stacktest,
        .s = &(struct {
            var static = "stacktest".*;
        }).static,
    },
    struct_test{
        .f = &nowrite,
        .s = &(struct {
            var static = "nowrite".*;
        }).static,
    },
    struct_test{
        .f = &pgbug,
        .s = &(struct {
            var static = "pgbug".*;
        }).static,
    },
    struct_test{
        .f = &sbrkbugs,
        .s = &(struct {
            var static = "sbrkbugs".*;
        }).static,
    },
    struct_test{
        .f = &sbrklast,
        .s = &(struct {
            var static = "sbrklast".*;
        }).static,
    },
    struct_test{
        .f = &sbrk8000,
        .s = &(struct {
            var static = "sbrk8000".*;
        }).static,
    },
    struct_test{
        .f = &badarg,
        .s = &(struct {
            var static = "badarg".*;
        }).static,
    },
    struct_test{
        .f = &lazy_alloc,
        .s = &(struct {
            var static = "lazy_alloc".*;
        }).static,
    },
    struct_test{
        .f = &lazy_unmap,
        .s = &(struct {
            var static = "lazy_unmap".*;
        }).static,
    },
    struct_test{
        .f = &lazy_copy,
        .s = &(struct {
            var static = "lazy_copy".*;
        }).static,
    },
    struct_test{
        .f = &lazy_sbrk,
        .s = &(struct {
            var static = "lazy_sbrk".*;
        }).static,
    },
    struct_test{
        .f = null,
        .s = null,
    },
};
pub export fn bigdir(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    const N: i32 = 500;
    _ = &N;
    const enum_unnamed_17 = u32;
    _ = &enum_unnamed_17;
    var i: i32 = undefined;
    _ = &i;
    var fd: i32 = undefined;
    _ = &fd;
    var name: [10]u8 = undefined;
    _ = &name;
    _ = unlink("bd");
    fd = open("bd", @as(i32, 512));
    if (fd < @as(i32, 0)) {
        printf("%s: bigdir create failed\n", s);
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    {
        i = 0;
        while (i < N) : (i += 1) {
            name[@as(u32, @intCast(@as(i32, 0)))] = 'x';
            name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(i, @as(i32, 64))))));
            name[@as(u32, @intCast(@as(i32, 2)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @import("std").zig.c_translation.signedRemainder(i, @as(i32, 64))))));
            name[@as(u32, @intCast(@as(i32, 3)))] = '\x00';
            if (link("bd", @as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))])))) != @as(i32, 0)) {
                printf("%s: bigdir i=%d link(bd, %s) failed\n", s, i, @as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                _ = exit(@as(i32, 1));
            }
        }
    }
    _ = unlink("bd");
    {
        i = 0;
        while (i < N) : (i += 1) {
            name[@as(u32, @intCast(@as(i32, 0)))] = 'x';
            name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(i, @as(i32, 64))))));
            name[@as(u32, @intCast(@as(i32, 2)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @import("std").zig.c_translation.signedRemainder(i, @as(i32, 64))))));
            name[@as(u32, @intCast(@as(i32, 3)))] = '\x00';
            if (unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))])))) != @as(i32, 0)) {
                printf("%s: bigdir unlink failed", s);
                _ = exit(@as(i32, 1));
            }
        }
    }
}
pub export fn manywrites(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var nchildren: i32 = 4;
    _ = &nchildren;
    var howmany: i32 = 30;
    _ = &howmany;
    {
        var ci: i32 = 0;
        _ = &ci;
        while (ci < nchildren) : (ci += 1) {
            var pid: i32 = fork();
            _ = &pid;
            if (pid < @as(i32, 0)) {
                printf("fork failed\n");
                _ = exit(@as(i32, 1));
            }
            if (pid == @as(i32, 0)) {
                var name: [3]u8 = undefined;
                _ = &name;
                name[@as(u32, @intCast(@as(i32, 0)))] = 'b';
                name[@as(u32, @intCast(@as(i32, 1)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, 'a') + ci))));
                name[@as(u32, @intCast(@as(i32, 2)))] = '\x00';
                _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                {
                    var iters: i32 = 0;
                    _ = &iters;
                    while (iters < howmany) : (iters += 1) {
                        {
                            var i: i32 = 0;
                            _ = &i;
                            while (i < (ci + @as(i32, 1))) : (i += 1) {
                                var fd: i32 = open(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))), @as(i32, 512) | @as(i32, 2));
                                _ = &fd;
                                if (fd < @as(i32, 0)) {
                                    printf("%s: cannot create %s\n", s, @as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                                    _ = exit(@as(i32, 1));
                                }
                                var sz: i32 = @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([12288]u8)))));
                                _ = &sz;
                                var cc: i32 = write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf[@as(u64, @intCast(0))]))))), sz);
                                _ = &cc;
                                if (cc != sz) {
                                    printf("%s: write(%d) ret %d\n", s, sz, cc);
                                    _ = exit(@as(i32, 1));
                                }
                                _ = close(fd);
                            }
                        }
                        _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                    }
                }
                _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                _ = exit(@as(i32, 0));
            }
        }
    }
    {
        var ci: i32 = 0;
        _ = &ci;
        while (ci < nchildren) : (ci += 1) {
            var st: i32 = 0;
            _ = &st;
            _ = wait(&st);
            if (st != @as(i32, 0)) {
                _ = exit(st);
            }
        }
    }
    _ = exit(@as(i32, 0));
}
pub export fn badwrite(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var assumed_free: i32 = 600;
    _ = &assumed_free;
    _ = unlink("junk");
    {
        var i: i32 = 0;
        _ = &i;
        while (i < assumed_free) : (i += 1) {
            var fd: i32 = open("junk", @as(i32, 512) | @as(i32, 1));
            _ = &fd;
            if (fd < @as(i32, 0)) {
                printf("open junk failed\n");
                _ = exit(@as(i32, 1));
            }
            _ = write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrFromInt(@as(i64, 1099511627775))))), @as(i32, 1));
            _ = close(fd);
            _ = unlink("junk");
        }
    }
    var fd: i32 = open("junk", @as(i32, 512) | @as(i32, 1));
    _ = &fd;
    if (fd < @as(i32, 0)) {
        printf("open junk failed\n");
        _ = exit(@as(i32, 1));
    }
    if (write(fd, @as(?*const anyopaque, @ptrCast("x")), @as(i32, 1)) != @as(i32, 1)) {
        printf("write failed\n");
        _ = exit(@as(i32, 1));
    }
    _ = close(fd);
    _ = unlink("junk");
    _ = exit(@as(i32, 0));
}
pub export fn execout(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    {
        var avail: i32 = 0;
        _ = &avail;
        while (avail < @as(i32, 15)) : (avail += 1) {
            var pid: i32 = fork();
            _ = &pid;
            if (pid < @as(i32, 0)) {
                printf("fork failed\n");
                _ = exit(@as(i32, 1));
            } else if (pid == @as(i32, 0)) {
                while (true) {
                    var a: [*c]u8 = sbrk(@as(i32, 4096));
                    _ = &a;
                    if (a == SBRK_ERROR) break;
                    ((a + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 4096)))))) - @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 1)))))).* = 1;
                }
                {
                    var i: i32 = 0;
                    _ = &i;
                    while (i < avail) : (i += 1) {
                        _ = sbrk(-@as(i32, 4096));
                    }
                }
                _ = close(@as(i32, 1));
                var args: [3][*c]u8 = [3][*c]u8{
                    @constCast("echo"),
                    @constCast("x"),
                    null,
                };
                _ = &args;
                _ = exec("echo", @as([*c][*c]u8, @ptrCast(@alignCast(&args[@as(u64, @intCast(0))]))));
                _ = exit(@as(i32, 0));
            } else {
                _ = wait(@as([*c]i32, @ptrFromInt(@as(i32, 0))));
            }
        }
    }
    _ = exit(@as(i32, 0));
}
pub export fn diskfull(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var fi: i32 = undefined;
    _ = &fi;
    var done: i32 = 0;
    _ = &done;
    _ = unlink("diskfulldir");
    {
        fi = 0;
        while ((done == @as(i32, 0)) and ((@as(i32, '0') + fi) < @as(i32, 127))) : (fi += 1) {
            var name: [32]u8 = undefined;
            _ = &name;
            name[@as(u32, @intCast(@as(i32, 0)))] = 'b';
            name[@as(u32, @intCast(@as(i32, 1)))] = 'i';
            name[@as(u32, @intCast(@as(i32, 2)))] = 'g';
            name[@as(u32, @intCast(@as(i32, 3)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + fi))));
            name[@as(u32, @intCast(@as(i32, 4)))] = '\x00';
            _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
            var fd: i32 = open(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))), (@as(i32, 512) | @as(i32, 2)) | @as(i32, 1024));
            _ = &fd;
            if (fd < @as(i32, 0)) {
                printf("%s: could not create file %s\n", s, @as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
                done = 1;
                break;
            }
            {
                var i: i32 = 0;
                _ = &i;
                while (@as(u64, @bitCast(@as(i64, i))) < (@as(u64, @bitCast(@as(i64, @as(i32, 12)))) +% (@as(u64, @bitCast(@as(i64, @as(i32, 1024)))) / @sizeOf(uint)))) : (i += 1) {
                    var buf_1: [1024]u8 = undefined;
                    _ = &buf_1;
                    if (write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))))), @as(i32, 1024)) != @as(i32, 1024)) {
                        done = 1;
                        _ = close(fd);
                        break;
                    }
                }
            }
            _ = close(fd);
        }
    }
    var nzz: i32 = 128;
    _ = &nzz;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < nzz) : (i += 1) {
            var name: [32]u8 = undefined;
            _ = &name;
            name[@as(u32, @intCast(@as(i32, 0)))] = 'z';
            name[@as(u32, @intCast(@as(i32, 1)))] = 'z';
            name[@as(u32, @intCast(@as(i32, 2)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(i, @as(i32, 32))))));
            name[@as(u32, @intCast(@as(i32, 3)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @import("std").zig.c_translation.signedRemainder(i, @as(i32, 32))))));
            name[@as(u32, @intCast(@as(i32, 4)))] = '\x00';
            _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
            var fd: i32 = open(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))), (@as(i32, 512) | @as(i32, 2)) | @as(i32, 1024));
            _ = &fd;
            if (fd < @as(i32, 0)) break;
            _ = close(fd);
        }
    }
    if (mkdir("diskfulldir") == @as(i32, 0)) {
        printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n", s);
    }
    _ = unlink("diskfulldir");
    {
        var i: i32 = 0;
        _ = &i;
        while (i < nzz) : (i += 1) {
            var name: [32]u8 = undefined;
            _ = &name;
            name[@as(u32, @intCast(@as(i32, 0)))] = 'z';
            name[@as(u32, @intCast(@as(i32, 1)))] = 'z';
            name[@as(u32, @intCast(@as(i32, 2)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(i, @as(i32, 32))))));
            name[@as(u32, @intCast(@as(i32, 3)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @import("std").zig.c_translation.signedRemainder(i, @as(i32, 32))))));
            name[@as(u32, @intCast(@as(i32, 4)))] = '\x00';
            _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
        }
    }
    {
        var i: i32 = 0;
        _ = &i;
        while ((@as(i32, '0') + i) < @as(i32, 127)) : (i += 1) {
            var name: [32]u8 = undefined;
            _ = &name;
            name[@as(u32, @intCast(@as(i32, 0)))] = 'b';
            name[@as(u32, @intCast(@as(i32, 1)))] = 'i';
            name[@as(u32, @intCast(@as(i32, 2)))] = 'g';
            name[@as(u32, @intCast(@as(i32, 3)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + i))));
            name[@as(u32, @intCast(@as(i32, 4)))] = '\x00';
            _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
        }
    }
}
pub export fn outofinodes(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var nzz: i32 = @as(i32, 32) * @as(i32, 32);
    _ = &nzz;
    {
        var i: i32 = 0;
        _ = &i;
        while (i < nzz) : (i += 1) {
            var name: [32]u8 = undefined;
            _ = &name;
            name[@as(u32, @intCast(@as(i32, 0)))] = 'z';
            name[@as(u32, @intCast(@as(i32, 1)))] = 'z';
            name[@as(u32, @intCast(@as(i32, 2)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(i, @as(i32, 32))))));
            name[@as(u32, @intCast(@as(i32, 3)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @import("std").zig.c_translation.signedRemainder(i, @as(i32, 32))))));
            name[@as(u32, @intCast(@as(i32, 4)))] = '\x00';
            _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
            var fd: i32 = open(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))), (@as(i32, 512) | @as(i32, 2)) | @as(i32, 1024));
            _ = &fd;
            if (fd < @as(i32, 0)) {
                break;
            }
            _ = close(fd);
        }
    }
    {
        var i: i32 = 0;
        _ = &i;
        while (i < nzz) : (i += 1) {
            var name: [32]u8 = undefined;
            _ = &name;
            name[@as(u32, @intCast(@as(i32, 0)))] = 'z';
            name[@as(u32, @intCast(@as(i32, 1)))] = 'z';
            name[@as(u32, @intCast(@as(i32, 2)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @divTrunc(i, @as(i32, 32))))));
            name[@as(u32, @intCast(@as(i32, 3)))] = @as(u8, @bitCast(@as(i8, @truncate(@as(i32, '0') + @import("std").zig.c_translation.signedRemainder(i, @as(i32, 32))))));
            name[@as(u32, @intCast(@as(i32, 4)))] = '\x00';
            _ = unlink(@as([*c]u8, @ptrCast(@alignCast(&name[@as(u64, @intCast(0))]))));
        }
    }
}
pub export var slowtests: [7]struct_test = [7]struct_test{
    struct_test{
        .f = &bigdir,
        .s = &(struct {
            var static = "bigdir".*;
        }).static,
    },
    struct_test{
        .f = &manywrites,
        .s = &(struct {
            var static = "manywrites".*;
        }).static,
    },
    struct_test{
        .f = &badwrite,
        .s = &(struct {
            var static = "badwrite".*;
        }).static,
    },
    struct_test{
        .f = &execout,
        .s = &(struct {
            var static = "execout".*;
        }).static,
    },
    struct_test{
        .f = &diskfull,
        .s = &(struct {
            var static = "diskfull".*;
        }).static,
    },
    struct_test{
        .f = &outofinodes,
        .s = &(struct {
            var static = "outofinodes".*;
        }).static,
    },
    struct_test{
        .f = null,
        .s = null,
    },
};
pub export fn run(arg_f: ?*const fn ([*c]u8) callconv(.c) void, arg_s: [*c]u8) i32 {
    var f = arg_f;
    _ = &f;
    var s = arg_s;
    _ = &s;
    var pid: i32 = undefined;
    _ = &pid;
    var xstatus: i32 = undefined;
    _ = &xstatus;
    printf("test %s: ", s);
    if ((blk: {
        const tmp = fork();
        pid = tmp;
        break :blk tmp;
    }) < @as(i32, 0)) {
        printf("runtest: fork error\n");
        _ = exit(@as(i32, 1));
    }
    if (pid == @as(i32, 0)) {
        f.?(s);
        _ = exit(@as(i32, 0));
    } else {
        _ = wait(&xstatus);
        if (xstatus != @as(i32, 0)) {
            printf("FAILED\n");
        } else {
            printf("OK\n");
        }
        return @intFromBool(xstatus == @as(i32, 0));
    }
    return 0;
}
pub export fn runtests(arg_tests: [*c]struct_test, arg_justone: [*c]u8, arg_continuous: i32) i32 {
    var tests = arg_tests;
    _ = &tests;
    var justone = arg_justone;
    _ = &justone;
    var continuous = arg_continuous;
    _ = &continuous;
    var ntests: i32 = 0;
    _ = &ntests;
    {
        var t: [*c]struct_test = tests;
        _ = &t;
        while (t.*.s != null) : (t += 1) {
            if ((justone == null) or (strcmp(t.*.s, justone) == @as(i32, 0))) {
                ntests += 1;
                if (!(run(t.*.f, t.*.s) != 0)) {
                    if (continuous != @as(i32, 2)) {
                        printf("SOME TESTS FAILED\n");
                        return -@as(i32, 1);
                    }
                }
            }
        }
    }
    return ntests;
}
pub export fn countfree() i32 {
    var n: i32 = 0;
    _ = &n;
    var sz0: uint64 = @as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0)))));
    _ = &sz0;
    while (true) {
        var a: [*c]u8 = sbrk(@as(i32, 4096));
        _ = &a;
        if (a == SBRK_ERROR) {
            break;
        }
        n += @as(i32, 1);
    }
    _ = sbrk(@as(i32, @bitCast(@as(u32, @truncate(-%(@as(uint64, @intCast(@intFromPtr(sbrk(@as(i32, 0))))) -% sz0))))));
    return n;
}
pub export fn drivetests(arg_quick: i32, arg_continuous: i32, arg_justone: [*c]u8) i32 {
    var quick = arg_quick;
    _ = &quick;
    var continuous = arg_continuous;
    _ = &continuous;
    var justone = arg_justone;
    _ = &justone;
    while (true) {
        printf("usertests starting\n");
        var free0: i32 = countfree();
        _ = &free0;
        var free1: i32 = 0;
        _ = &free1;
        var ntests: i32 = 0;
        _ = &ntests;
        var n: i32 = undefined;
        _ = &n;
        n = runtests(@as([*c]struct_test, @ptrCast(@alignCast(&quicktests[@as(u64, @intCast(0))]))), justone, continuous);
        if (n < @as(i32, 0)) {
            if (continuous != @as(i32, 2)) {
                return 1;
            }
        } else {
            ntests += n;
        }
        if (!(quick != 0)) {
            if (justone == null) {
                printf("usertests slow tests starting\n");
            }
            n = runtests(@as([*c]struct_test, @ptrCast(@alignCast(&slowtests[@as(u64, @intCast(0))]))), justone, continuous);
            if (n < @as(i32, 0)) {
                if (continuous != @as(i32, 2)) {
                    return 1;
                }
            } else {
                ntests += n;
            }
        }
        if ((blk: {
            const tmp = countfree();
            free1 = tmp;
            break :blk tmp;
        }) < free0) {
            printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
            if (continuous != @as(i32, 2)) {
                return 1;
            }
        }
        if ((justone != null) and (ntests == @as(i32, 0))) {
            printf("NO TESTS EXECUTED\n");
            return 1;
        }
        if (!(continuous != 0)) break;
    }
    return 0;
}
pub export fn main(arg_argc: i32, arg_argv: [*c][*c]u8) i32 {
    var argc = arg_argc;
    _ = &argc;
    var argv = arg_argv;
    _ = &argv;
    var continuous: i32 = 0;
    _ = &continuous;
    var quick: i32 = 0;
    _ = &quick;
    var justone: [*c]u8 = null;
    _ = &justone;
    if ((argc == @as(i32, 2)) and (strcmp(argv[@as(u32, @intCast(@as(i32, 1)))], "-q") == @as(i32, 0))) {
        quick = 1;
    } else if ((argc == @as(i32, 2)) and (strcmp(argv[@as(u32, @intCast(@as(i32, 1)))], "-c") == @as(i32, 0))) {
        continuous = 1;
    } else if ((argc == @as(i32, 2)) and (strcmp(argv[@as(u32, @intCast(@as(i32, 1)))], "-C") == @as(i32, 0))) {
        continuous = 2;
    } else if ((argc == @as(i32, 2)) and (@as(i32, @bitCast(@as(u32, argv[@as(u32, @intCast(@as(i32, 1)))][@as(u32, @intCast(@as(i32, 0)))]))) != @as(i32, '-'))) {
        justone = argv[@as(u32, @intCast(@as(i32, 1)))];
    } else if (argc > @as(i32, 1)) {
        printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
        _ = exit(@as(i32, 1));
    }
    if (drivetests(quick, continuous, justone) != 0) {
        _ = exit(@as(i32, 1));
    }
    printf("ALL TESTS PASSED\n");
    _ = exit(@as(i32, 0));
    return 0;
}
pub const __llvm__ = @as(i32, 1);
pub const __clang__ = @as(i32, 1);
pub const __clang_major__ = @as(i32, 20);
pub const __clang_minor__ = @as(i32, 1);
pub const __clang_patchlevel__ = @as(i32, 8);
pub const __clang_version__ = "20.1.8 ";
pub const __GNUC__ = @as(i32, 4);
pub const __GNUC_MINOR__ = @as(i32, 2);
pub const __GNUC_PATCHLEVEL__ = @as(i32, 1);
pub const __GXX_ABI_VERSION = @as(i32, 1002);
pub const __ATOMIC_RELAXED = @as(i32, 0);
pub const __ATOMIC_CONSUME = @as(i32, 1);
pub const __ATOMIC_ACQUIRE = @as(i32, 2);
pub const __ATOMIC_RELEASE = @as(i32, 3);
pub const __ATOMIC_ACQ_REL = @as(i32, 4);
pub const __ATOMIC_SEQ_CST = @as(i32, 5);
pub const __MEMORY_SCOPE_SYSTEM = @as(i32, 0);
pub const __MEMORY_SCOPE_DEVICE = @as(i32, 1);
pub const __MEMORY_SCOPE_WRKGRP = @as(i32, 2);
pub const __MEMORY_SCOPE_WVFRNT = @as(i32, 3);
pub const __MEMORY_SCOPE_SINGLE = @as(i32, 4);
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(i32, 0);
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(i32, 1);
pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(i32, 2);
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(i32, 3);
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(i32, 4);
pub const __FPCLASS_SNAN = @as(i32, 0x0001);
pub const __FPCLASS_QNAN = @as(i32, 0x0002);
pub const __FPCLASS_NEGINF = @as(i32, 0x0004);
pub const __FPCLASS_NEGNORMAL = @as(i32, 0x0008);
pub const __FPCLASS_NEGSUBNORMAL = @as(i32, 0x0010);
pub const __FPCLASS_NEGZERO = @as(i32, 0x0020);
pub const __FPCLASS_POSZERO = @as(i32, 0x0040);
pub const __FPCLASS_POSSUBNORMAL = @as(i32, 0x0080);
pub const __FPCLASS_POSNORMAL = @as(i32, 0x0100);
pub const __FPCLASS_POSINF = @as(i32, 0x0200);
pub const __PRAGMA_REDEFINE_EXTNAME = @as(i32, 1);
pub const __VERSION__ = "Homebrew Clang 20.1.8";
pub const __OBJC_BOOL_IS_BOOL = @as(i32, 1);
pub const __CONSTANT_CFSTRINGS__ = @as(i32, 1);
pub const __block = @compileError("unable to translate macro: undefined identifier `__blocks__`");
// (no file):42:9
pub const __BLOCKS__ = @as(i32, 1);
pub const __clang_literal_encoding__ = "UTF-8";
pub const __clang_wide_literal_encoding__ = "UTF-32";
pub const __ORDER_LITTLE_ENDIAN__ = @as(i32, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(i32, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(i32, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(i32, 1);
pub const _LP64 = @as(i32, 1);
pub const __LP64__ = @as(i32, 1);
pub const __CHAR_BIT__ = @as(i32, 8);
pub const __BOOL_WIDTH__ = @as(i32, 1);
pub const __SHRT_WIDTH__ = @as(i32, 16);
pub const __INT_WIDTH__ = @as(i32, 32);
pub const __LONG_WIDTH__ = @as(i32, 64);
pub const __LLONG_WIDTH__ = @as(i32, 64);
pub const __BITINT_MAXWIDTH__ = @as(i32, 128);
pub const __SCHAR_MAX__ = @as(i32, 127);
pub const __SHRT_MAX__ = @as(i32, 32767);
pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 2147483647, .decimal);
pub const __LONG_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i64, 9223372036854775807, .decimal);
pub const __LONG_LONG_MAX__ = @as(i64, 9223372036854775807);
pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 2147483647, .decimal);
pub const __WCHAR_WIDTH__ = @as(i32, 32);
pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 2147483647, .decimal);
pub const __WINT_WIDTH__ = @as(i32, 32);
pub const __INTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i64, 9223372036854775807, .decimal);
pub const __INTMAX_WIDTH__ = @as(i32, 64);
pub const __SIZE_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(u64, 18446744073709551615, .decimal);
pub const __SIZE_WIDTH__ = @as(i32, 64);
pub const __UINTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(u64, 18446744073709551615, .decimal);
pub const __UINTMAX_WIDTH__ = @as(i32, 64);
pub const __PTRDIFF_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i64, 9223372036854775807, .decimal);
pub const __PTRDIFF_WIDTH__ = @as(i32, 64);
pub const __INTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i64, 9223372036854775807, .decimal);
pub const __INTPTR_WIDTH__ = @as(i32, 64);
pub const __UINTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(u64, 18446744073709551615, .decimal);
pub const __UINTPTR_WIDTH__ = @as(i32, 64);
pub const __SIZEOF_DOUBLE__ = @as(i32, 8);
pub const __SIZEOF_FLOAT__ = @as(i32, 4);
pub const __SIZEOF_INT__ = @as(i32, 4);
pub const __SIZEOF_LONG__ = @as(i32, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(i32, 8);
pub const __SIZEOF_LONG_LONG__ = @as(i32, 8);
pub const __SIZEOF_POINTER__ = @as(i32, 8);
pub const __SIZEOF_SHORT__ = @as(i32, 2);
pub const __SIZEOF_PTRDIFF_T__ = @as(i32, 8);
pub const __SIZEOF_SIZE_T__ = @as(i32, 8);
pub const __SIZEOF_WCHAR_T__ = @as(i32, 4);
pub const __SIZEOF_WINT_T__ = @as(i32, 4);
pub const __SIZEOF_INT128__ = @as(i32, 16);
pub const __INTMAX_TYPE__ = i64;
pub const __INTMAX_FMTd__ = "ld";
pub const __INTMAX_FMTi__ = "li";
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`");
// (no file):97:9
pub const __INTMAX_C = @import("std").zig.c_translation.Macros.L_SUFFIX;
pub const __UINTMAX_TYPE__ = u64;
pub const __UINTMAX_FMTo__ = "lo";
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINTMAX_FMTX__ = "lX";
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`");
// (no file):104:9
pub const __UINTMAX_C = @import("std").zig.c_translation.Macros.UL_SUFFIX;
pub const __PTRDIFF_TYPE__ = i64;
pub const __PTRDIFF_FMTd__ = "ld";
pub const __PTRDIFF_FMTi__ = "li";
pub const __INTPTR_TYPE__ = i64;
pub const __INTPTR_FMTd__ = "ld";
pub const __INTPTR_FMTi__ = "li";
pub const __SIZE_TYPE__ = u64;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZE_FMTx__ = "lx";
pub const __SIZE_FMTX__ = "lX";
pub const __WCHAR_TYPE__ = i32;
pub const __WINT_TYPE__ = i32;
pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(i32, 32);
pub const __CHAR16_TYPE__ = u16;
pub const __CHAR32_TYPE__ = u32;
pub const __UINTPTR_TYPE__ = u64;
pub const __UINTPTR_FMTo__ = "lo";
pub const __UINTPTR_FMTu__ = "lu";
pub const __UINTPTR_FMTx__ = "lx";
pub const __UINTPTR_FMTX__ = "lX";
pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
pub const __FLT16_NORM_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_HAS_DENORM__ = @as(i32, 1);
pub const __FLT16_DIG__ = @as(i32, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(i32, 5);
pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
pub const __FLT16_HAS_INFINITY__ = @as(i32, 1);
pub const __FLT16_HAS_QUIET_NAN__ = @as(i32, 1);
pub const __FLT16_MANT_DIG__ = @as(i32, 11);
pub const __FLT16_MAX_10_EXP__ = @as(i32, 4);
pub const __FLT16_MAX_EXP__ = @as(i32, 16);
pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_MIN_10_EXP__ = -@as(i32, 4);
pub const __FLT16_MIN_EXP__ = -@as(i32, 13);
pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_NORM_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_HAS_DENORM__ = @as(i32, 1);
pub const __FLT_DIG__ = @as(i32, 6);
pub const __FLT_DECIMAL_DIG__ = @as(i32, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = @as(i32, 1);
pub const __FLT_HAS_QUIET_NAN__ = @as(i32, 1);
pub const __FLT_MANT_DIG__ = @as(i32, 24);
pub const __FLT_MAX_10_EXP__ = @as(i32, 38);
pub const __FLT_MAX_EXP__ = @as(i32, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(i32, 37);
pub const __FLT_MIN_EXP__ = -@as(i32, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_NORM_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_HAS_DENORM__ = @as(i32, 1);
pub const __DBL_DIG__ = @as(i32, 15);
pub const __DBL_DECIMAL_DIG__ = @as(i32, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = @as(i32, 1);
pub const __DBL_HAS_QUIET_NAN__ = @as(i32, 1);
pub const __DBL_MANT_DIG__ = @as(i32, 53);
pub const __DBL_MAX_10_EXP__ = @as(i32, 308);
pub const __DBL_MAX_EXP__ = @as(i32, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(i32, 307);
pub const __DBL_MIN_EXP__ = -@as(i32, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __LDBL_NORM_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __LDBL_HAS_DENORM__ = @as(i32, 1);
pub const __LDBL_DIG__ = @as(i32, 15);
pub const __LDBL_DECIMAL_DIG__ = @as(i32, 17);
pub const __LDBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __LDBL_HAS_INFINITY__ = @as(i32, 1);
pub const __LDBL_HAS_QUIET_NAN__ = @as(i32, 1);
pub const __LDBL_MANT_DIG__ = @as(i32, 53);
pub const __LDBL_MAX_10_EXP__ = @as(i32, 308);
pub const __LDBL_MAX_EXP__ = @as(i32, 1024);
pub const __LDBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __LDBL_MIN_10_EXP__ = -@as(i32, 307);
pub const __LDBL_MIN_EXP__ = -@as(i32, 1021);
pub const __LDBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __POINTER_WIDTH__ = @as(i32, 64);
pub const __BIGGEST_ALIGNMENT__ = @as(i32, 8);
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub inline fn __INT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT16_TYPE__ = i16;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub inline fn __INT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT32_TYPE__ = i32;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub inline fn __INT32_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT64_TYPE__ = i64;
pub const __INT64_FMTd__ = "lld";
pub const __INT64_FMTi__ = "lli";
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`");
// (no file):208:9
pub const __INT64_C = @import("std").zig.c_translation.Macros.LL_SUFFIX;
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub inline fn __UINT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT8_MAX__ = @as(i32, 255);
pub const __INT8_MAX__ = @as(i32, 127);
pub const __UINT16_TYPE__ = u16;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub inline fn __UINT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 65535, .decimal);
pub const __INT16_MAX__ = @as(i32, 32767);
pub const __UINT32_TYPE__ = u32;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`");
// (no file):233:9
pub const __UINT32_C = @import("std").zig.c_translation.Macros.U_SUFFIX;
pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(u32, 4294967295, .decimal);
pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 2147483647, .decimal);
pub const __UINT64_TYPE__ = u64;
pub const __UINT64_FMTo__ = "llo";
pub const __UINT64_FMTu__ = "llu";
pub const __UINT64_FMTx__ = "llx";
pub const __UINT64_FMTX__ = "llX";
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`");
// (no file):242:9
pub const __UINT64_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
pub const __UINT64_MAX__ = @as(u64, 18446744073709551615);
pub const __INT64_MAX__ = @as(i64, 9223372036854775807);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(i32, 127);
pub const __INT_LEAST8_WIDTH__ = @as(i32, 8);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(i32, 255);
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = i16;
pub const __INT_LEAST16_MAX__ = @as(i32, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(i32, 16);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = u16;
pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 65535, .decimal);
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = i32;
pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(i32, 32);
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = u32;
pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(u32, 4294967295, .decimal);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = i64;
pub const __INT_LEAST64_MAX__ = @as(i64, 9223372036854775807);
pub const __INT_LEAST64_WIDTH__ = @as(i32, 64);
pub const __INT_LEAST64_FMTd__ = "lld";
pub const __INT_LEAST64_FMTi__ = "lli";
pub const __UINT_LEAST64_TYPE__ = u64;
pub const __UINT_LEAST64_MAX__ = @as(u64, 18446744073709551615);
pub const __UINT_LEAST64_FMTo__ = "llo";
pub const __UINT_LEAST64_FMTu__ = "llu";
pub const __UINT_LEAST64_FMTx__ = "llx";
pub const __UINT_LEAST64_FMTX__ = "llX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(i32, 127);
pub const __INT_FAST8_WIDTH__ = @as(i32, 8);
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(i32, 255);
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = i16;
pub const __INT_FAST16_MAX__ = @as(i32, 32767);
pub const __INT_FAST16_WIDTH__ = @as(i32, 16);
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = u16;
pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 65535, .decimal);
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = i32;
pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(i32, 32);
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = u32;
pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(u32, 4294967295, .decimal);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_TYPE__ = i64;
pub const __INT_FAST64_MAX__ = @as(i64, 9223372036854775807);
pub const __INT_FAST64_WIDTH__ = @as(i32, 64);
pub const __INT_FAST64_FMTd__ = "lld";
pub const __INT_FAST64_FMTi__ = "lli";
pub const __UINT_FAST64_TYPE__ = u64;
pub const __UINT_FAST64_MAX__ = @as(u64, 18446744073709551615);
pub const __UINT_FAST64_FMTo__ = "llo";
pub const __UINT_FAST64_FMTu__ = "llu";
pub const __UINT_FAST64_FMTx__ = "llx";
pub const __UINT_FAST64_FMTX__ = "llX";
pub const __USER_LABEL_PREFIX__ = @compileError("unable to translate macro: undefined identifier `_`");
// (no file):334:9
pub const __NO_MATH_ERRNO__ = @as(i32, 1);
pub const __FINITE_MATH_ONLY__ = @as(i32, 0);
pub const __GNUC_STDC_INLINE__ = @as(i32, 1);
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(i32, 1);
pub const __GCC_DESTRUCTIVE_SIZE = @as(i32, 64);
pub const __GCC_CONSTRUCTIVE_SIZE = @as(i32, 64);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(i32, 2);
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(i32, 2);
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(i32, 2);
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(i32, 2);
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(i32, 2);
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(i32, 2);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(i32, 2);
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(i32, 2);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(i32, 2);
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(i32, 2);
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(i32, 2);
pub const __NO_INLINE__ = @as(i32, 1);
pub const __PIC__ = @as(i32, 2);
pub const __pic__ = @as(i32, 2);
pub const __FLT_RADIX__ = @as(i32, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __SSP_STRONG__ = @as(i32, 2);
pub const __nonnull = @compileError("unable to translate macro: undefined identifier `_Nonnull`");
// (no file):369:9
pub const __null_unspecified = @compileError("unable to translate macro: undefined identifier `_Null_unspecified`");
// (no file):370:9
pub const __nullable = @compileError("unable to translate macro: undefined identifier `_Nullable`");
// (no file):371:9
pub const TARGET_OS_WIN32 = @as(i32, 0);
pub const TARGET_OS_WINDOWS = @as(i32, 0);
pub const TARGET_OS_LINUX = @as(i32, 0);
pub const TARGET_OS_UNIX = @as(i32, 0);
pub const TARGET_OS_MAC = @as(i32, 1);
pub const TARGET_OS_OSX = @as(i32, 1);
pub const TARGET_OS_IPHONE = @as(i32, 0);
pub const TARGET_OS_IOS = @as(i32, 0);
pub const TARGET_OS_TV = @as(i32, 0);
pub const TARGET_OS_WATCH = @as(i32, 0);
pub const TARGET_OS_VISION = @as(i32, 0);
pub const TARGET_OS_DRIVERKIT = @as(i32, 0);
pub const TARGET_OS_MACCATALYST = @as(i32, 0);
pub const TARGET_OS_SIMULATOR = @as(i32, 0);
pub const TARGET_OS_EMBEDDED = @as(i32, 0);
pub const TARGET_OS_NANO = @as(i32, 0);
pub const TARGET_IPHONE_SIMULATOR = @as(i32, 0);
pub const TARGET_OS_UIKITFORMAC = @as(i32, 0);
pub const __AARCH64EL__ = @as(i32, 1);
pub const __aarch64__ = @as(i32, 1);
pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(i32, 1);
pub const __AARCH64_CMODEL_SMALL__ = @as(i32, 1);
pub inline fn __ARM_ACLE_VERSION(year: anytype, quarter: anytype, patch: anytype) @TypeOf(((@as(i32, 100) * year) + (@as(i32, 10) * quarter)) + patch) {
    _ = &year;
    _ = &quarter;
    _ = &patch;
    return ((@as(i32, 100) * year) + (@as(i32, 10) * quarter)) + patch;
}
pub const __ARM_ACLE = @import("std").zig.c_translation.promoteIntLiteral(i32, 202420, .decimal);
pub const __FUNCTION_MULTI_VERSIONING_SUPPORT_LEVEL = @import("std").zig.c_translation.promoteIntLiteral(i32, 202430, .decimal);
pub const __ARM_ARCH = @as(i32, 8);
pub const __ARM_ARCH_PROFILE = 'A';
pub const __ARM_64BIT_STATE = @as(i32, 1);
pub const __ARM_PCS_AAPCS64 = @as(i32, 1);
pub const __ARM_ARCH_ISA_A64 = @as(i32, 1);
pub const __ARM_FEATURE_CLZ = @as(i32, 1);
pub const __ARM_FEATURE_FMA = @as(i32, 1);
pub const __ARM_FEATURE_LDREX = @as(i32, 0xF);
pub const __ARM_FEATURE_IDIV = @as(i32, 1);
pub const __ARM_FEATURE_DIV = @as(i32, 1);
pub const __ARM_FEATURE_NUMERIC_MAXMIN = @as(i32, 1);
pub const __ARM_FEATURE_DIRECTED_ROUNDING = @as(i32, 1);
pub const __ARM_ALIGN_MAX_STACK_PWR = @as(i32, 4);
pub const __ARM_STATE_ZA = @as(i32, 1);
pub const __ARM_STATE_ZT0 = @as(i32, 1);
pub const __ARM_FP = @as(i32, 0xE);
pub const __ARM_FP16_FORMAT_IEEE = @as(i32, 1);
pub const __ARM_FP16_ARGS = @as(i32, 1);
pub const __ARM_NEON_SVE_BRIDGE = @as(i32, 1);
pub const __ARM_SIZEOF_WCHAR_T = @as(i32, 4);
pub const __ARM_SIZEOF_MINIMAL_ENUM = @as(i32, 4);
pub const __ARM_NEON = @as(i32, 1);
pub const __ARM_NEON_FP = @as(i32, 0xE);
pub const __ARM_FEATURE_CRC32 = @as(i32, 1);
pub const __ARM_FEATURE_RCPC = @as(i32, 1);
pub const __ARM_FEATURE_CRYPTO = @as(i32, 1);
pub const __ARM_FEATURE_AES = @as(i32, 1);
pub const __ARM_FEATURE_SHA2 = @as(i32, 1);
pub const __ARM_FEATURE_SHA3 = @as(i32, 1);
pub const __ARM_FEATURE_SHA512 = @as(i32, 1);
pub const __ARM_FEATURE_PAUTH = @as(i32, 1);
pub const __ARM_FEATURE_UNALIGNED = @as(i32, 1);
pub const __ARM_FEATURE_FP16_VECTOR_ARITHMETIC = @as(i32, 1);
pub const __ARM_FEATURE_FP16_SCALAR_ARITHMETIC = @as(i32, 1);
pub const __ARM_FEATURE_DOTPROD = @as(i32, 1);
pub const __ARM_FEATURE_ATOMICS = @as(i32, 1);
pub const __ARM_FEATURE_FP16_FML = @as(i32, 1);
pub const __ARM_FEATURE_COMPLEX = @as(i32, 1);
pub const __ARM_FEATURE_JCVT = @as(i32, 1);
pub const __ARM_FEATURE_QRDMX = @as(i32, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(i32, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(i32, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(i32, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(i32, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(i32, 1);
pub const __FP_FAST_FMA = @as(i32, 1);
pub const __FP_FAST_FMAF = @as(i32, 1);
pub const __AARCH64_SIMD__ = @as(i32, 1);
pub const __ARM64_ARCH_8__ = @as(i32, 1);
pub const __ARM_NEON__ = @as(i32, 1);
pub const __REGISTER_PREFIX__ = "";
pub const __arm64 = @as(i32, 1);
pub const __arm64__ = @as(i32, 1);
pub const __APPLE_CC__ = @as(i32, 6000);
pub const __APPLE__ = @as(i32, 1);
pub const __weak = @compileError("unable to translate macro: undefined identifier `objc_gc`");
// (no file):452:9
pub const __strong = "";
pub const __unsafe_unretained = "";
pub const __DYNAMIC__ = @as(i32, 1);
pub const __MACH__ = @as(i32, 1);
pub const __STDC_NO_THREADS__ = @as(i32, 1);
pub const __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 260300, .decimal);
pub const __ENVIRONMENT_OS_VERSION_MIN_REQUIRED__ = @import("std").zig.c_translation.promoteIntLiteral(i32, 260300, .decimal);
pub const __STDC__ = @as(i32, 1);
pub const __STDC_HOSTED__ = @as(i32, 1);
pub const __STDC_VERSION__ = @as(i64, 201710);
pub const __STDC_UTF_16__ = @as(i32, 1);
pub const __STDC_UTF_32__ = @as(i32, 1);
pub const __STDC_EMBED_NOT_FOUND__ = @as(i32, 0);
pub const __STDC_EMBED_FOUND__ = @as(i32, 1);
pub const __STDC_EMBED_EMPTY__ = @as(i32, 2);
pub const __GCC_HAVE_DWARF2_CFI_ASM = @as(i32, 1);
pub const NPROC = @as(i32, 64);
pub const NCPU = @as(i32, 8);
pub const NOFILE = @as(i32, 16);
pub const NFILE = @as(i32, 100);
pub const NINODE = @as(i32, 50);
pub const NDEV = @as(i32, 10);
pub const ROOTDEV = @as(i32, 1);
pub const MAXARG = @as(i32, 32);
pub const MAXOPBLOCKS = @as(i32, 10);
pub const LOGBLOCKS = MAXOPBLOCKS * @as(i32, 3);
pub const NBUF = MAXOPBLOCKS * @as(i32, 3);
pub const FSSIZE = @as(i32, 2000);
pub const MAXPATH = @as(i32, 128);
pub const USERSTACK = @as(i32, 1);
pub const T_DIR = @as(i32, 1);
pub const T_FILE = @as(i32, 2);
pub const T_DEVICE = @as(i32, 3);
pub const SBRK_ERROR = @import("std").zig.c_translation.cast([*c]u8, -@as(i32, 1));
pub const ROOTINO = @as(i32, 1);
pub const BSIZE = @as(i32, 1024);
pub const FSMAGIC = @import("std").zig.c_translation.promoteIntLiteral(i32, 0x10203040, .hex);
pub const NDIRECT = @as(i32, 12);
pub const NINDIRECT = @import("std").zig.c_translation.MacroArithmetic.div(BSIZE, @import("std").zig.c_translation.sizeof(uint));
pub const MAXFILE = NDIRECT + NINDIRECT;
pub const IPB = @import("std").zig.c_translation.MacroArithmetic.div(BSIZE, @import("std").zig.c_translation.sizeof(struct_dinode));
pub inline fn IBLOCK(i: anytype, sb: anytype) @TypeOf(@import("std").zig.c_translation.MacroArithmetic.div(i, IPB) + sb.inodestart) {
    _ = &i;
    _ = &sb;
    return @import("std").zig.c_translation.MacroArithmetic.div(i, IPB) + sb.inodestart;
}
pub const BPB = BSIZE * @as(i32, 8);
pub inline fn BBLOCK(b: anytype, sb: anytype) @TypeOf(@import("std").zig.c_translation.MacroArithmetic.div(b, BPB) + sb.bmapstart) {
    _ = &b;
    _ = &sb;
    return @import("std").zig.c_translation.MacroArithmetic.div(b, BPB) + sb.bmapstart;
}
pub const DIRSIZ = @as(i32, 14);
pub const O_RDONLY = @as(i32, 0x000);
pub const O_WRONLY = @as(i32, 0x001);
pub const O_RDWR = @as(i32, 0x002);
pub const O_CREATE = @as(i32, 0x200);
pub const O_TRUNC = @as(i32, 0x400);
pub const SYS_fork = @as(i32, 1);
pub const SYS_exit = @as(i32, 2);
pub const SYS_wait = @as(i32, 3);
pub const SYS_pipe = @as(i32, 4);
pub const SYS_read = @as(i32, 5);
pub const SYS_kill = @as(i32, 6);
pub const SYS_exec = @as(i32, 7);
pub const SYS_fstat = @as(i32, 8);
pub const SYS_chdir = @as(i32, 9);
pub const SYS_dup = @as(i32, 10);
pub const SYS_getpid = @as(i32, 11);
pub const SYS_sbrk = @as(i32, 12);
pub const SYS_pause = @as(i32, 13);
pub const SYS_uptime = @as(i32, 14);
pub const SYS_open = @as(i32, 15);
pub const SYS_write = @as(i32, 16);
pub const SYS_mknod = @as(i32, 17);
pub const SYS_unlink = @as(i32, 18);
pub const SYS_link = @as(i32, 19);
pub const SYS_mkdir = @as(i32, 20);
pub const SYS_close = @as(i32, 21);
pub const UART0 = @as(i64, 0x10000000);
pub const UART0_IRQ = @as(i32, 10);
pub const VIRTIO0 = @import("std").zig.c_translation.promoteIntLiteral(i32, 0x10001000, .hex);
pub const VIRTIO0_IRQ = @as(i32, 1);
pub const PLIC = @as(i64, 0x0c000000);
pub const PLIC_PRIORITY = PLIC + @as(i32, 0x0);
pub const PLIC_PENDING = PLIC + @as(i32, 0x1000);
pub inline fn PLIC_SENABLE(hart: anytype) @TypeOf((PLIC + @as(i32, 0x2080)) + (hart * @as(i32, 0x100))) {
    _ = &hart;
    return (PLIC + @as(i32, 0x2080)) + (hart * @as(i32, 0x100));
}
pub inline fn PLIC_SPRIORITY(hart: anytype) @TypeOf((PLIC + @import("std").zig.c_translation.promoteIntLiteral(i32, 0x201000, .hex)) + (hart * @as(i32, 0x2000))) {
    _ = &hart;
    return (PLIC + @import("std").zig.c_translation.promoteIntLiteral(i32, 0x201000, .hex)) + (hart * @as(i32, 0x2000));
}
pub inline fn PLIC_SCLAIM(hart: anytype) @TypeOf((PLIC + @import("std").zig.c_translation.promoteIntLiteral(i32, 0x201004, .hex)) + (hart * @as(i32, 0x2000))) {
    _ = &hart;
    return (PLIC + @import("std").zig.c_translation.promoteIntLiteral(i32, 0x201004, .hex)) + (hart * @as(i32, 0x2000));
}
pub const KERNBASE = @import("std").zig.c_translation.promoteIntLiteral(i64, 0x80000000, .hex);
pub const PHYSTOP = KERNBASE + ((@as(i32, 128) * @as(i32, 1024)) * @as(i32, 1024));
pub const TRAMPOLINE = MAXVA - PGSIZE;
pub inline fn KSTACK(p: anytype) @TypeOf(TRAMPOLINE - (((p + @as(i32, 1)) * @as(i32, 2)) * PGSIZE)) {
    _ = &p;
    return TRAMPOLINE - (((p + @as(i32, 1)) * @as(i32, 2)) * PGSIZE);
}
pub const TRAPFRAME = TRAMPOLINE - PGSIZE;
pub const MSTATUS_MPP_MASK = @as(i64, 3) << @as(i32, 11);
pub const MSTATUS_MPP_M = @as(i64, 3) << @as(i32, 11);
pub const MSTATUS_MPP_S = @as(i64, 1) << @as(i32, 11);
pub const MSTATUS_MPP_U = @as(i64, 0) << @as(i32, 11);
pub const SSTATUS_SPP = @as(i64, 1) << @as(i32, 8);
pub const SSTATUS_SPIE = @as(i64, 1) << @as(i32, 5);
pub const SSTATUS_UPIE = @as(i64, 1) << @as(i32, 4);
pub const SSTATUS_SIE = @as(i64, 1) << @as(i32, 1);
pub const SSTATUS_UIE = @as(i64, 1) << @as(i32, 0);
pub const SIE_SEIE = @as(i64, 1) << @as(i32, 9);
pub const SIE_STIE = @as(i64, 1) << @as(i32, 5);
pub const MIE_STIE = @as(i64, 1) << @as(i32, 5);
pub const SATP_SV39 = @as(i64, 8) << @as(i32, 60);
pub inline fn MAKE_SATP(pagetable: anytype) @TypeOf(SATP_SV39 | (@import("std").zig.c_translation.cast(uint64, pagetable) >> @as(i32, 12))) {
    _ = &pagetable;
    return SATP_SV39 | (@import("std").zig.c_translation.cast(uint64, pagetable) >> @as(i32, 12));
}
pub const PGSIZE = @as(i32, 4096);
pub const PGSHIFT = @as(i32, 12);
pub inline fn PGROUNDUP(sz: anytype) @TypeOf(((sz + PGSIZE) - @as(i32, 1)) & ~(PGSIZE - @as(i32, 1))) {
    _ = &sz;
    return ((sz + PGSIZE) - @as(i32, 1)) & ~(PGSIZE - @as(i32, 1));
}
pub inline fn PGROUNDDOWN(a: anytype) @TypeOf(a & ~(PGSIZE - @as(i32, 1))) {
    _ = &a;
    return a & ~(PGSIZE - @as(i32, 1));
}
pub const PTE_V = @as(i64, 1) << @as(i32, 0);
pub const PTE_R = @as(i64, 1) << @as(i32, 1);
pub const PTE_W = @as(i64, 1) << @as(i32, 2);
pub const PTE_X = @as(i64, 1) << @as(i32, 3);
pub const PTE_U = @as(i64, 1) << @as(i32, 4);
pub inline fn PA2PTE(pa: anytype) @TypeOf((@import("std").zig.c_translation.cast(uint64, pa) >> @as(i32, 12)) << @as(i32, 10)) {
    _ = &pa;
    return (@import("std").zig.c_translation.cast(uint64, pa) >> @as(i32, 12)) << @as(i32, 10);
}
pub inline fn PTE2PA(pte: anytype) @TypeOf((pte >> @as(i32, 10)) << @as(i32, 12)) {
    _ = &pte;
    return (pte >> @as(i32, 10)) << @as(i32, 12);
}
pub inline fn PTE_FLAGS(pte: anytype) @TypeOf(pte & @as(i32, 0x3FF)) {
    _ = &pte;
    return pte & @as(i32, 0x3FF);
}
pub const PXMASK = @as(i32, 0x1FF);
pub inline fn PXSHIFT(level: anytype) @TypeOf(PGSHIFT + (@as(i32, 9) * level)) {
    _ = &level;
    return PGSHIFT + (@as(i32, 9) * level);
}
pub inline fn PX(level: anytype, va: anytype) @TypeOf((@import("std").zig.c_translation.cast(uint64, va) >> PXSHIFT(level)) & PXMASK) {
    _ = &level;
    _ = &va;
    return (@import("std").zig.c_translation.cast(uint64, va) >> PXSHIFT(level)) & PXMASK;
}
pub const MAXVA = @as(i64, 1) << ((((@as(i32, 9) + @as(i32, 9)) + @as(i32, 9)) + @as(i32, 12)) - @as(i32, 1));
pub const BUFSZ = (MAXOPBLOCKS + @as(i32, 2)) * BSIZE;
pub const REGION_SZ = (@as(i32, 1024) * @as(i32, 1024)) * @as(i32, 1024);
pub const superblock = struct_superblock;
pub const dinode = struct_dinode;
pub const dirent = struct_dirent;
pub const @"test" = struct_test;
