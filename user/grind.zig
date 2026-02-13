pub const __builtin_bswap16 = @import("std").zig.c_builtins.__builtin_bswap16;
pub const __builtin_bswap32 = @import("std").zig.c_builtins.__builtin_bswap32;
pub const __builtin_bswap64 = @import("std").zig.c_builtins.__builtin_bswap64;
pub const __builtin_signbit = @import("std").zig.c_builtins.__builtin_signbit;
pub const __builtin_signbitf = @import("std").zig.c_builtins.__builtin_signbitf;
pub const __builtin_popcount = @import("std").zig.c_builtins.__builtin_popcount;
pub const __builtin_ctz = @import("std").zig.c_builtins.__builtin_ctz;
pub const __builtin_clz = @import("std").zig.c_builtins.__builtin_clz;
pub const __builtin_sqrt = @import("std").zig.c_builtins.__builtin_sqrt;
pub const __builtin_sqrtf = @import("std").zig.c_builtins.__builtin_sqrtf;
pub const __builtin_sin = @import("std").zig.c_builtins.__builtin_sin;
pub const __builtin_sinf = @import("std").zig.c_builtins.__builtin_sinf;
pub const __builtin_cos = @import("std").zig.c_builtins.__builtin_cos;
pub const __builtin_cosf = @import("std").zig.c_builtins.__builtin_cosf;
pub const __builtin_exp = @import("std").zig.c_builtins.__builtin_exp;
pub const __builtin_expf = @import("std").zig.c_builtins.__builtin_expf;
pub const __builtin_exp2 = @import("std").zig.c_builtins.__builtin_exp2;
pub const __builtin_exp2f = @import("std").zig.c_builtins.__builtin_exp2f;
pub const __builtin_log = @import("std").zig.c_builtins.__builtin_log;
pub const __builtin_logf = @import("std").zig.c_builtins.__builtin_logf;
pub const __builtin_log2 = @import("std").zig.c_builtins.__builtin_log2;
pub const __builtin_log2f = @import("std").zig.c_builtins.__builtin_log2f;
pub const __builtin_log10 = @import("std").zig.c_builtins.__builtin_log10;
pub const __builtin_log10f = @import("std").zig.c_builtins.__builtin_log10f;
pub const __builtin_abs = @import("std").zig.c_builtins.__builtin_abs;
pub const __builtin_labs = @import("std").zig.c_builtins.__builtin_labs;
pub const __builtin_llabs = @import("std").zig.c_builtins.__builtin_llabs;
pub const __builtin_fabs = @import("std").zig.c_builtins.__builtin_fabs;
pub const __builtin_fabsf = @import("std").zig.c_builtins.__builtin_fabsf;
pub const __builtin_floor = @import("std").zig.c_builtins.__builtin_floor;
pub const __builtin_floorf = @import("std").zig.c_builtins.__builtin_floorf;
pub const __builtin_ceil = @import("std").zig.c_builtins.__builtin_ceil;
pub const __builtin_ceilf = @import("std").zig.c_builtins.__builtin_ceilf;
pub const __builtin_trunc = @import("std").zig.c_builtins.__builtin_trunc;
pub const __builtin_truncf = @import("std").zig.c_builtins.__builtin_truncf;
pub const __builtin_round = @import("std").zig.c_builtins.__builtin_round;
pub const __builtin_roundf = @import("std").zig.c_builtins.__builtin_roundf;
pub const __builtin_strlen = @import("std").zig.c_builtins.__builtin_strlen;
pub const __builtin_strcmp = @import("std").zig.c_builtins.__builtin_strcmp;
pub const __builtin_object_size = @import("std").zig.c_builtins.__builtin_object_size;
pub const __builtin___memset_chk = @import("std").zig.c_builtins.__builtin___memset_chk;
pub const __builtin_memset = @import("std").zig.c_builtins.__builtin_memset;
pub const __builtin___memcpy_chk = @import("std").zig.c_builtins.__builtin___memcpy_chk;
pub const __builtin_memcpy = @import("std").zig.c_builtins.__builtin_memcpy;
pub const __builtin_expect = @import("std").zig.c_builtins.__builtin_expect;
pub const __builtin_nanf = @import("std").zig.c_builtins.__builtin_nanf;
pub const __builtin_huge_valf = @import("std").zig.c_builtins.__builtin_huge_valf;
pub const __builtin_inff = @import("std").zig.c_builtins.__builtin_inff;
pub const __builtin_isnan = @import("std").zig.c_builtins.__builtin_isnan;
pub const __builtin_isinf = @import("std").zig.c_builtins.__builtin_isinf;
pub const __builtin_isinf_sign = @import("std").zig.c_builtins.__builtin_isinf_sign;
pub const __has_builtin = @import("std").zig.c_builtins.__has_builtin;
pub const __builtin_assume = @import("std").zig.c_builtins.__builtin_assume;
pub const __builtin_unreachable = @import("std").zig.c_builtins.__builtin_unreachable;
pub const __builtin_constant_p = @import("std").zig.c_builtins.__builtin_constant_p;
pub const __builtin_mul_overflow = @import("std").zig.c_builtins.__builtin_mul_overflow;
pub const uint = c_uint;
pub const ushort = c_ushort;
pub const uchar = u8;
pub const uint8 = u8;
pub const uint16 = c_ushort;
pub const uint32 = c_uint;
pub const uint64 = c_ulong;
pub const pde_t = uint64;
pub const struct_stat = extern struct {
    dev: c_int = @import("std").mem.zeroes(c_int),
    ino: uint = @import("std").mem.zeroes(uint),
    type: c_short = @import("std").mem.zeroes(c_short),
    nlink: c_short = @import("std").mem.zeroes(c_short),
    size: uint64 = @import("std").mem.zeroes(uint64),
};
pub extern fn fork() c_int;
pub extern fn exit(c_int) noreturn;
pub extern fn wait([*c]c_int) c_int;
pub extern fn pipe([*c]c_int) c_int;
pub extern fn write(c_int, ?*const anyopaque, c_int) c_int;
pub extern fn read(c_int, ?*anyopaque, c_int) c_int;
pub extern fn close(c_int) c_int;
pub extern fn kill(c_int) c_int;
pub extern fn exec([*c]const u8, [*c][*c]u8) c_int;
pub extern fn open([*c]const u8, c_int) c_int;
pub extern fn mknod([*c]const u8, c_short, c_short) c_int;
pub extern fn unlink([*c]const u8) c_int;
pub extern fn fstat(fd: c_int, [*c]struct_stat) c_int;
pub extern fn link([*c]const u8, [*c]const u8) c_int;
pub extern fn mkdir([*c]const u8) c_int;
pub extern fn chdir([*c]const u8) c_int;
pub extern fn dup(c_int) c_int;
pub extern fn getpid() c_int;
pub extern fn sys_sbrk(c_int, c_int) [*c]u8;
pub extern fn pause(c_int) c_int;
pub extern fn uptime() c_int;
pub extern fn stat([*c]const u8, [*c]struct_stat) c_int;
pub extern fn strcpy([*c]u8, [*c]const u8) [*c]u8;
pub extern fn memmove(?*anyopaque, ?*const anyopaque, c_int) ?*anyopaque;
pub extern fn strchr([*c]const u8, c: u8) [*c]u8;
pub extern fn strcmp([*c]const u8, [*c]const u8) c_int;
pub extern fn gets([*c]u8, max: c_int) [*c]u8;
pub extern fn strlen([*c]const u8) uint;
pub extern fn memset(?*anyopaque, c_int, uint) ?*anyopaque;
pub extern fn atoi([*c]const u8) c_int;
pub extern fn memcmp(?*const anyopaque, ?*const anyopaque, uint) c_int;
pub extern fn memcpy(?*anyopaque, ?*const anyopaque, uint) ?*anyopaque;
pub extern fn sbrk(c_int) [*c]u8;
pub extern fn sbrklazy(c_int) [*c]u8;
pub extern fn fprintf(c_int, [*c]const u8, ...) void;
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
    type: c_short = @import("std").mem.zeroes(c_short),
    major: c_short = @import("std").mem.zeroes(c_short),
    minor: c_short = @import("std").mem.zeroes(c_short),
    nlink: c_short = @import("std").mem.zeroes(c_short),
    size: uint = @import("std").mem.zeroes(uint),
    addrs: [13]uint = @import("std").mem.zeroes([13]uint),
};
pub const struct_dirent = extern struct {
    inum: ushort = @import("std").mem.zeroes(ushort),
    name: [14]u8 = @import("std").mem.zeroes([14]u8),
};
// ./kernel/riscv.h:8:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:5:1: warning: unable to translate function, demoted to extern
pub extern fn r_mhartid() callconv(.c) uint64;
// ./kernel/riscv.h:23:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:20:1: warning: unable to translate function, demoted to extern
pub extern fn r_mstatus() callconv(.c) uint64;
// ./kernel/riscv.h:30:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:28:1: warning: unable to translate function, demoted to extern
pub extern fn w_mstatus(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:39:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:37:1: warning: unable to translate function, demoted to extern
pub extern fn w_mepc(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:54:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:51:1: warning: unable to translate function, demoted to extern
pub extern fn r_sstatus() callconv(.c) uint64;
// ./kernel/riscv.h:61:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:59:1: warning: unable to translate function, demoted to extern
pub extern fn w_sstatus(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:69:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:66:1: warning: unable to translate function, demoted to extern
pub extern fn r_sip() callconv(.c) uint64;
// ./kernel/riscv.h:76:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:74:1: warning: unable to translate function, demoted to extern
pub extern fn w_sip(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:86:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:83:1: warning: unable to translate function, demoted to extern
pub extern fn r_sie() callconv(.c) uint64;
// ./kernel/riscv.h:93:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:91:1: warning: unable to translate function, demoted to extern
pub extern fn w_sie(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:102:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:99:1: warning: unable to translate function, demoted to extern
pub extern fn r_mie() callconv(.c) uint64;
// ./kernel/riscv.h:109:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:107:1: warning: unable to translate function, demoted to extern
pub extern fn w_mie(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:118:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:116:1: warning: unable to translate function, demoted to extern
pub extern fn w_sepc(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:125:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:122:1: warning: unable to translate function, demoted to extern
pub extern fn r_sepc() callconv(.c) uint64;
// ./kernel/riscv.h:134:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:131:1: warning: unable to translate function, demoted to extern
pub extern fn r_medeleg() callconv(.c) uint64;
// ./kernel/riscv.h:141:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:139:1: warning: unable to translate function, demoted to extern
pub extern fn w_medeleg(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:149:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:146:1: warning: unable to translate function, demoted to extern
pub extern fn r_mideleg() callconv(.c) uint64;
// ./kernel/riscv.h:156:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:154:1: warning: unable to translate function, demoted to extern
pub extern fn w_mideleg(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:164:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:162:1: warning: unable to translate function, demoted to extern
pub extern fn w_stvec(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:171:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:168:1: warning: unable to translate function, demoted to extern
pub extern fn r_stvec() callconv(.c) uint64;
// ./kernel/riscv.h:181:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:177:1: warning: unable to translate function, demoted to extern
pub extern fn r_stimecmp() callconv(.c) uint64;
// ./kernel/riscv.h:189:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:186:1: warning: unable to translate function, demoted to extern
pub extern fn w_stimecmp(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:198:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:194:1: warning: unable to translate function, demoted to extern
pub extern fn r_menvcfg() callconv(.c) uint64;
// ./kernel/riscv.h:206:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:203:1: warning: unable to translate function, demoted to extern
pub extern fn w_menvcfg(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:213:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:211:1: warning: unable to translate function, demoted to extern
pub extern fn w_pmpcfg0(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:219:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:217:1: warning: unable to translate function, demoted to extern
pub extern fn w_pmpaddr0(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:232:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:230:1: warning: unable to translate function, demoted to extern
pub extern fn w_satp(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:239:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:236:1: warning: unable to translate function, demoted to extern
pub extern fn r_satp() callconv(.c) uint64;
// ./kernel/riscv.h:248:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:245:1: warning: unable to translate function, demoted to extern
pub extern fn r_scause() callconv(.c) uint64;
// ./kernel/riscv.h:257:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:254:1: warning: unable to translate function, demoted to extern
pub extern fn r_stval() callconv(.c) uint64;
// ./kernel/riscv.h:265:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:263:1: warning: unable to translate function, demoted to extern
pub extern fn w_mcounteren(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:272:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:269:1: warning: unable to translate function, demoted to extern
pub extern fn r_mcounteren() callconv(.c) uint64;
// ./kernel/riscv.h:281:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:278:1: warning: unable to translate function, demoted to extern
pub extern fn r_time() callconv(.c) uint64;
pub fn intr_on() callconv(.c) void {
    w_sstatus(r_sstatus() | @as(uint64, @bitCast(@as(c_long, 1) << @intCast(1))));
}
pub fn intr_off() callconv(.c) void {
    w_sstatus(r_sstatus() & @as(uint64, @bitCast(~(@as(c_long, 1) << @intCast(1)))));
}
pub fn intr_get() callconv(.c) c_int {
    var x: uint64 = r_sstatus();
    _ = &x;
    return @intFromBool((x & @as(uint64, @bitCast(@as(c_long, 1) << @intCast(1)))) != @as(uint64, @bitCast(@as(c_long, @as(c_int, 0)))));
}
// ./kernel/riscv.h:311:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:308:1: warning: unable to translate function, demoted to extern
pub extern fn r_sp() callconv(.c) uint64;
// ./kernel/riscv.h:321:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:318:1: warning: unable to translate function, demoted to extern
pub extern fn r_tp() callconv(.c) uint64;
// ./kernel/riscv.h:328:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:326:1: warning: unable to translate function, demoted to extern
pub extern fn w_tp(arg_x: uint64) callconv(.c) void;
// ./kernel/riscv.h:335:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:332:1: warning: unable to translate function, demoted to extern
pub extern fn r_ra() callconv(.c) uint64;
// ./kernel/riscv.h:344:3: warning: TODO implement translation of stmt class GCCAsmStmtClass

// ./kernel/riscv.h:341:1: warning: unable to translate function, demoted to extern
pub extern fn sfence_vma() callconv(.c) void;
pub const pte_t = uint64;
pub const pagetable_t = [*c]uint64;
pub export fn do_rand(arg_ctx: [*c]c_ulong) c_int {
    var ctx = arg_ctx;
    _ = &ctx;
    var hi: c_long = undefined;
    _ = &hi;
    var lo: c_long = undefined;
    _ = &lo;
    var x: c_long = undefined;
    _ = &x;
    x = @as(c_long, @bitCast((ctx.* % @as(c_ulong, @bitCast(@as(c_long, @as(c_int, 2147483646))))) +% @as(c_ulong, @bitCast(@as(c_long, @as(c_int, 1))))));
    hi = @divTrunc(x, @as(c_long, @bitCast(@as(c_long, @as(c_int, 127773)))));
    lo = @import("std").zig.c_translation.signedRemainder(x, @as(c_long, @bitCast(@as(c_long, @as(c_int, 127773)))));
    x = (@as(c_long, @bitCast(@as(c_long, @as(c_int, 16807)))) * lo) - (@as(c_long, @bitCast(@as(c_long, @as(c_int, 2836)))) * hi);
    if (x < @as(c_long, @bitCast(@as(c_long, @as(c_int, 0))))) {
        x += @as(c_long, @bitCast(@as(c_long, @as(c_int, 2147483647))));
    }
    x -= 1;
    ctx.* = @as(c_ulong, @bitCast(x));
    return @as(c_int, @bitCast(@as(c_int, @truncate(x))));
}
pub export var rand_next: c_ulong = 1;
pub export fn rand() c_int {
    return do_rand(&rand_next);
}
pub export fn go(arg_which_child: c_int) void {
    var which_child = arg_which_child;
    _ = &which_child;
    var fd: c_int = -@as(c_int, 1);
    _ = &fd;
    const buf = struct {
        var static: [999]u8 = @import("std").mem.zeroes([999]u8);
    };
    _ = &buf;
    var break0: [*c]u8 = sbrk(@as(c_int, 0));
    _ = &break0;
    var iters: uint64 = 0;
    _ = &iters;
    _ = mkdir("grindir");
    if (chdir("grindir") != @as(c_int, 0)) {
        printf("grind: chdir grindir failed\n");
        _ = exit(@as(c_int, 1));
    }
    _ = chdir("/");
    while (true) {
        iters +%= 1;
        if ((iters % @as(uint64, @bitCast(@as(c_long, @as(c_int, 500))))) == @as(uint64, @bitCast(@as(c_long, @as(c_int, 0))))) {
            _ = write(@as(c_int, 1), @as(?*const anyopaque, @ptrCast(if (which_child != 0) "B" else "A")), @as(c_int, 1));
        }
        var what: c_int = @import("std").zig.c_translation.signedRemainder(rand(), @as(c_int, 23));
        _ = &what;
        if (what == @as(c_int, 1)) {
            _ = close(open("grindir/../a", @as(c_int, 512) | @as(c_int, 2)));
        } else if (what == @as(c_int, 2)) {
            _ = close(open("grindir/../grindir/../b", @as(c_int, 512) | @as(c_int, 2)));
        } else if (what == @as(c_int, 3)) {
            _ = unlink("grindir/../a");
        } else if (what == @as(c_int, 4)) {
            if (chdir("grindir") != @as(c_int, 0)) {
                printf("grind: chdir grindir failed\n");
                _ = exit(@as(c_int, 1));
            }
            _ = unlink("../b");
            _ = chdir("/");
        } else if (what == @as(c_int, 5)) {
            _ = close(fd);
            fd = open("/grindir/../a", @as(c_int, 512) | @as(c_int, 2));
        } else if (what == @as(c_int, 6)) {
            _ = close(fd);
            fd = open("/./grindir/./../b", @as(c_int, 512) | @as(c_int, 2));
        } else if (what == @as(c_int, 7)) {
            _ = write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf.static[@as(usize, @intCast(0))]))))), @as(c_int, @bitCast(@as(c_uint, @truncate(@sizeOf([999]u8))))));
        } else if (what == @as(c_int, 8)) {
            _ = read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf.static[@as(usize, @intCast(0))]))))), @as(c_int, @bitCast(@as(c_uint, @truncate(@sizeOf([999]u8))))));
        } else if (what == @as(c_int, 9)) {
            _ = mkdir("grindir/../a");
            _ = close(open("a/../a/./a", @as(c_int, 512) | @as(c_int, 2)));
            _ = unlink("a/a");
        } else if (what == @as(c_int, 10)) {
            _ = mkdir("/../b");
            _ = close(open("grindir/../b/b", @as(c_int, 512) | @as(c_int, 2)));
            _ = unlink("b/b");
        } else if (what == @as(c_int, 11)) {
            _ = unlink("b");
            _ = link("../grindir/./../a", "../b");
        } else if (what == @as(c_int, 12)) {
            _ = unlink("../grindir/../a");
            _ = link(".././b", "/grindir/../a");
        } else if (what == @as(c_int, 13)) {
            var pid: c_int = fork();
            _ = &pid;
            if (pid == @as(c_int, 0)) {
                _ = exit(@as(c_int, 0));
            } else if (pid < @as(c_int, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(c_int, 1));
            }
            _ = wait(null);
        } else if (what == @as(c_int, 14)) {
            var pid: c_int = fork();
            _ = &pid;
            if (pid == @as(c_int, 0)) {
                _ = fork();
                _ = fork();
                _ = exit(@as(c_int, 0));
            } else if (pid < @as(c_int, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(c_int, 1));
            }
            _ = wait(null);
        } else if (what == @as(c_int, 15)) {
            _ = sbrk(@as(c_int, 6011));
        } else if (what == @as(c_int, 16)) {
            if (sbrk(@as(c_int, 0)) > break0) {
                _ = sbrk(@as(c_int, @bitCast(@as(c_int, @truncate(-@divExact(@as(c_long, @bitCast(@intFromPtr(sbrk(@as(c_int, 0))) -% @intFromPtr(break0))), @sizeOf(u8)))))));
            }
        } else if (what == @as(c_int, 17)) {
            var pid: c_int = fork();
            _ = &pid;
            if (pid == @as(c_int, 0)) {
                _ = close(open("a", @as(c_int, 512) | @as(c_int, 2)));
                _ = exit(@as(c_int, 0));
            } else if (pid < @as(c_int, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(c_int, 1));
            }
            if (chdir("../grindir/..") != @as(c_int, 0)) {
                printf("grind: chdir failed\n");
                _ = exit(@as(c_int, 1));
            }
            _ = kill(pid);
            _ = wait(null);
        } else if (what == @as(c_int, 18)) {
            var pid: c_int = fork();
            _ = &pid;
            if (pid == @as(c_int, 0)) {
                _ = kill(getpid());
                _ = exit(@as(c_int, 0));
            } else if (pid < @as(c_int, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(c_int, 1));
            }
            _ = wait(null);
        } else if (what == @as(c_int, 19)) {
            var fds: [2]c_int = undefined;
            _ = &fds;
            if (pipe(@as([*c]c_int, @ptrCast(@alignCast(&fds[@as(usize, @intCast(0))])))) < @as(c_int, 0)) {
                printf("grind: pipe failed\n");
                _ = exit(@as(c_int, 1));
            }
            var pid: c_int = fork();
            _ = &pid;
            if (pid == @as(c_int, 0)) {
                _ = fork();
                _ = fork();
                if (write(fds[@as(c_uint, @intCast(@as(c_int, 1)))], @as(?*const anyopaque, @ptrCast("x")), @as(c_int, 1)) != @as(c_int, 1)) {
                    printf("grind: pipe write failed\n");
                }
                var c: u8 = undefined;
                _ = &c;
                if (read(fds[@as(c_uint, @intCast(@as(c_int, 0)))], @as(?*anyopaque, @ptrCast(&c)), @as(c_int, 1)) != @as(c_int, 1)) {
                    printf("grind: pipe read failed\n");
                }
                _ = exit(@as(c_int, 0));
            } else if (pid < @as(c_int, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(c_int, 1));
            }
            _ = close(fds[@as(c_uint, @intCast(@as(c_int, 0)))]);
            _ = close(fds[@as(c_uint, @intCast(@as(c_int, 1)))]);
            _ = wait(null);
        } else if (what == @as(c_int, 20)) {
            var pid: c_int = fork();
            _ = &pid;
            if (pid == @as(c_int, 0)) {
                _ = unlink("a");
                _ = mkdir("a");
                _ = chdir("a");
                _ = unlink("../a");
                fd = open("x", @as(c_int, 512) | @as(c_int, 2));
                _ = unlink("x");
                _ = exit(@as(c_int, 0));
            } else if (pid < @as(c_int, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(c_int, 1));
            }
            _ = wait(null);
        } else if (what == @as(c_int, 21)) {
            _ = unlink("c");
            var fd1: c_int = open("c", @as(c_int, 512) | @as(c_int, 2));
            _ = &fd1;
            if (fd1 < @as(c_int, 0)) {
                printf("grind: create c failed\n");
                _ = exit(@as(c_int, 1));
            }
            if (write(fd1, @as(?*const anyopaque, @ptrCast("x")), @as(c_int, 1)) != @as(c_int, 1)) {
                printf("grind: write c failed\n");
                _ = exit(@as(c_int, 1));
            }
            var st: struct_stat = undefined;
            _ = &st;
            if (fstat(fd1, &st) != @as(c_int, 0)) {
                printf("grind: fstat failed\n");
                _ = exit(@as(c_int, 1));
            }
            if (st.size != @as(uint64, @bitCast(@as(c_long, @as(c_int, 1))))) {
                printf("grind: fstat reports wrong size %d\n", @as(c_int, @bitCast(@as(c_uint, @truncate(st.size)))));
                _ = exit(@as(c_int, 1));
            }
            if (st.ino > @as(uint, @bitCast(@as(c_int, 200)))) {
                printf("grind: fstat reports crazy i-number %d\n", st.ino);
                _ = exit(@as(c_int, 1));
            }
            _ = close(fd1);
            _ = unlink("c");
        } else if (what == @as(c_int, 22)) {
            var aa: [2]c_int = undefined;
            _ = &aa;
            var bb: [2]c_int = undefined;
            _ = &bb;
            if (pipe(@as([*c]c_int, @ptrCast(@alignCast(&aa[@as(usize, @intCast(0))])))) < @as(c_int, 0)) {
                fprintf(@as(c_int, 2), "grind: pipe failed\n");
                _ = exit(@as(c_int, 1));
            }
            if (pipe(@as([*c]c_int, @ptrCast(@alignCast(&bb[@as(usize, @intCast(0))])))) < @as(c_int, 0)) {
                fprintf(@as(c_int, 2), "grind: pipe failed\n");
                _ = exit(@as(c_int, 1));
            }
            var pid1: c_int = fork();
            _ = &pid1;
            if (pid1 == @as(c_int, 0)) {
                _ = close(bb[@as(c_uint, @intCast(@as(c_int, 0)))]);
                _ = close(bb[@as(c_uint, @intCast(@as(c_int, 1)))]);
                _ = close(aa[@as(c_uint, @intCast(@as(c_int, 0)))]);
                _ = close(@as(c_int, 1));
                if (dup(aa[@as(c_uint, @intCast(@as(c_int, 1)))]) != @as(c_int, 1)) {
                    fprintf(@as(c_int, 2), "grind: dup failed\n");
                    _ = exit(@as(c_int, 1));
                }
                _ = close(aa[@as(c_uint, @intCast(@as(c_int, 1)))]);
                var args: [3][*c]u8 = [3][*c]u8{
                    @constCast("echo"),
                    @constCast("hi"),
                    null,
                };
                _ = &args;
                _ = exec("grindir/../echo", @as([*c][*c]u8, @ptrCast(@alignCast(&args[@as(usize, @intCast(0))]))));
                fprintf(@as(c_int, 2), "grind: echo: not found\n");
                _ = exit(@as(c_int, 2));
            } else if (pid1 < @as(c_int, 0)) {
                fprintf(@as(c_int, 2), "grind: fork failed\n");
                _ = exit(@as(c_int, 3));
            }
            var pid2: c_int = fork();
            _ = &pid2;
            if (pid2 == @as(c_int, 0)) {
                _ = close(aa[@as(c_uint, @intCast(@as(c_int, 1)))]);
                _ = close(bb[@as(c_uint, @intCast(@as(c_int, 0)))]);
                _ = close(@as(c_int, 0));
                if (dup(aa[@as(c_uint, @intCast(@as(c_int, 0)))]) != @as(c_int, 0)) {
                    fprintf(@as(c_int, 2), "grind: dup failed\n");
                    _ = exit(@as(c_int, 4));
                }
                _ = close(aa[@as(c_uint, @intCast(@as(c_int, 0)))]);
                _ = close(@as(c_int, 1));
                if (dup(bb[@as(c_uint, @intCast(@as(c_int, 1)))]) != @as(c_int, 1)) {
                    fprintf(@as(c_int, 2), "grind: dup failed\n");
                    _ = exit(@as(c_int, 5));
                }
                _ = close(bb[@as(c_uint, @intCast(@as(c_int, 1)))]);
                var args: [2][*c]u8 = [2][*c]u8{
                    @constCast("cat"),
                    null,
                };
                _ = &args;
                _ = exec("/cat", @as([*c][*c]u8, @ptrCast(@alignCast(&args[@as(usize, @intCast(0))]))));
                fprintf(@as(c_int, 2), "grind: cat: not found\n");
                _ = exit(@as(c_int, 6));
            } else if (pid2 < @as(c_int, 0)) {
                fprintf(@as(c_int, 2), "grind: fork failed\n");
                _ = exit(@as(c_int, 7));
            }
            _ = close(aa[@as(c_uint, @intCast(@as(c_int, 0)))]);
            _ = close(aa[@as(c_uint, @intCast(@as(c_int, 1)))]);
            _ = close(bb[@as(c_uint, @intCast(@as(c_int, 1)))]);
            var buf_1: [4]u8 = [4]u8{
                0,
                0,
                0,
                0,
            };
            _ = &buf_1;
            _ = read(bb[@as(c_uint, @intCast(@as(c_int, 0)))], @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(usize, @intCast(0))]))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 0))))))), @as(c_int, 1));
            _ = read(bb[@as(c_uint, @intCast(@as(c_int, 0)))], @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(usize, @intCast(0))]))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))))), @as(c_int, 1));
            _ = read(bb[@as(c_uint, @intCast(@as(c_int, 0)))], @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(usize, @intCast(0))]))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 2))))))), @as(c_int, 1));
            _ = close(bb[@as(c_uint, @intCast(@as(c_int, 0)))]);
            var st1: c_int = undefined;
            _ = &st1;
            var st2: c_int = undefined;
            _ = &st2;
            _ = wait(&st1);
            _ = wait(&st2);
            if (((st1 != @as(c_int, 0)) or (st2 != @as(c_int, 0))) or (strcmp(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(usize, @intCast(0))]))), "hi\n") != @as(c_int, 0))) {
                printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, @as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(usize, @intCast(0))]))));
                _ = exit(@as(c_int, 1));
            }
        }
    }
}
pub export fn iter() void {
    _ = unlink("a");
    _ = unlink("b");
    var pid1: c_int = fork();
    _ = &pid1;
    if (pid1 < @as(c_int, 0)) {
        printf("grind: fork failed\n");
        _ = exit(@as(c_int, 1));
    }
    if (pid1 == @as(c_int, 0)) {
        rand_next ^= @as(c_ulong, @bitCast(@as(c_long, @as(c_int, 31))));
        go(@as(c_int, 0));
        _ = exit(@as(c_int, 0));
    }
    var pid2: c_int = fork();
    _ = &pid2;
    if (pid2 < @as(c_int, 0)) {
        printf("grind: fork failed\n");
        _ = exit(@as(c_int, 1));
    }
    if (pid2 == @as(c_int, 0)) {
        rand_next ^= @as(c_ulong, @bitCast(@as(c_long, @as(c_int, 7177))));
        go(@as(c_int, 1));
        _ = exit(@as(c_int, 0));
    }
    var st1: c_int = -@as(c_int, 1);
    _ = &st1;
    _ = wait(&st1);
    if (st1 != @as(c_int, 0)) {
        _ = kill(pid1);
        _ = kill(pid2);
    }
    var st2: c_int = -@as(c_int, 1);
    _ = &st2;
    _ = wait(&st2);
    _ = exit(@as(c_int, 0));
}
pub export fn main() c_int {
    while (true) {
        var pid: c_int = fork();
        _ = &pid;
        if (pid == @as(c_int, 0)) {
            iter();
            _ = exit(@as(c_int, 0));
        }
        if (pid > @as(c_int, 0)) {
            _ = wait(null);
        }
        _ = pause(@as(c_int, 20));
        rand_next +%= @as(c_ulong, @bitCast(@as(c_long, @as(c_int, 1))));
    }
    return 0;
}
pub const __llvm__ = @as(c_int, 1);
pub const __clang__ = @as(c_int, 1);
pub const __clang_major__ = @as(c_int, 20);
pub const __clang_minor__ = @as(c_int, 1);
pub const __clang_patchlevel__ = @as(c_int, 8);
pub const __clang_version__ = "20.1.8 ";
pub const __GNUC__ = @as(c_int, 4);
pub const __GNUC_MINOR__ = @as(c_int, 2);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
pub const __GXX_ABI_VERSION = @as(c_int, 1002);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __MEMORY_SCOPE_SYSTEM = @as(c_int, 0);
pub const __MEMORY_SCOPE_DEVICE = @as(c_int, 1);
pub const __MEMORY_SCOPE_WRKGRP = @as(c_int, 2);
pub const __MEMORY_SCOPE_WVFRNT = @as(c_int, 3);
pub const __MEMORY_SCOPE_SINGLE = @as(c_int, 4);
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
pub const __FPCLASS_SNAN = @as(c_int, 0x0001);
pub const __FPCLASS_QNAN = @as(c_int, 0x0002);
pub const __FPCLASS_NEGINF = @as(c_int, 0x0004);
pub const __FPCLASS_NEGNORMAL = @as(c_int, 0x0008);
pub const __FPCLASS_NEGSUBNORMAL = @as(c_int, 0x0010);
pub const __FPCLASS_NEGZERO = @as(c_int, 0x0020);
pub const __FPCLASS_POSZERO = @as(c_int, 0x0040);
pub const __FPCLASS_POSSUBNORMAL = @as(c_int, 0x0080);
pub const __FPCLASS_POSNORMAL = @as(c_int, 0x0100);
pub const __FPCLASS_POSINF = @as(c_int, 0x0200);
pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
pub const __VERSION__ = "Homebrew Clang 20.1.8";
pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 1);
pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
pub const __block = @compileError("unable to translate macro: undefined identifier `__blocks__`");
// (no file):42:9
pub const __BLOCKS__ = @as(c_int, 1);
pub const __clang_literal_encoding__ = "UTF-8";
pub const __clang_wide_literal_encoding__ = "UTF-32";
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 1);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_WIDTH__ = @as(c_int, 64);
pub const __LLONG_WIDTH__ = @as(c_int, 64);
pub const __BITINT_MAXWIDTH__ = @as(c_int, 128);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __LONG_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WINT_WIDTH__ = @as(c_int, 32);
pub const __INTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_WINT_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_FMTd__ = "ld";
pub const __INTMAX_FMTi__ = "li";
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`");
// (no file):97:9
pub const __INTMAX_C = @import("std").zig.c_translation.Macros.L_SUFFIX;
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_FMTo__ = "lo";
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINTMAX_FMTX__ = "lX";
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`");
// (no file):104:9
pub const __UINTMAX_C = @import("std").zig.c_translation.Macros.UL_SUFFIX;
pub const __PTRDIFF_TYPE__ = c_long;
pub const __PTRDIFF_FMTd__ = "ld";
pub const __PTRDIFF_FMTi__ = "li";
pub const __INTPTR_TYPE__ = c_long;
pub const __INTPTR_FMTd__ = "ld";
pub const __INTPTR_FMTi__ = "li";
pub const __SIZE_TYPE__ = c_ulong;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZE_FMTx__ = "lx";
pub const __SIZE_FMTX__ = "lX";
pub const __WCHAR_TYPE__ = c_int;
pub const __WINT_TYPE__ = c_int;
pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __UINTPTR_FMTo__ = "lo";
pub const __UINTPTR_FMTu__ = "lu";
pub const __UINTPTR_FMTx__ = "lx";
pub const __UINTPTR_FMTX__ = "lX";
pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
pub const __FLT16_NORM_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
pub const __FLT16_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT16_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_NORM_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_NORM_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 4.9406564584124654e-324);
pub const __LDBL_NORM_MAX__ = @as(c_longdouble, 1.7976931348623157e+308);
pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
pub const __LDBL_DIG__ = @as(c_int, 15);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 2.2204460492503131e-16);
pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __LDBL_MANT_DIG__ = @as(c_int, 53);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __LDBL_MAX_EXP__ = @as(c_int, 1024);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.7976931348623157e+308);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __LDBL_MIN__ = @as(c_longdouble, 2.2250738585072014e-308);
pub const __POINTER_WIDTH__ = @as(c_int, 64);
pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 8);
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub inline fn __INT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub inline fn __INT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub inline fn __INT32_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT64_TYPE__ = c_longlong;
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
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub inline fn __UINT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`");
// (no file):233:9
pub const __UINT32_C = @import("std").zig.c_translation.Macros.U_SUFFIX;
pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulonglong;
pub const __UINT64_FMTo__ = "llo";
pub const __UINT64_FMTu__ = "llu";
pub const __UINT64_FMTx__ = "llx";
pub const __UINT64_FMTX__ = "llX";
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`");
// (no file):242:9
pub const __UINT64_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_longlong;
pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_LEAST64_FMTd__ = "lld";
pub const __INT_LEAST64_FMTi__ = "lli";
pub const __UINT_LEAST64_TYPE__ = c_ulonglong;
pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_LEAST64_FMTo__ = "llo";
pub const __UINT_LEAST64_FMTu__ = "llu";
pub const __UINT_LEAST64_FMTx__ = "llx";
pub const __UINT_LEAST64_FMTX__ = "llX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_TYPE__ = c_longlong;
pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_FAST64_FMTd__ = "lld";
pub const __INT_FAST64_FMTi__ = "lli";
pub const __UINT_FAST64_TYPE__ = c_ulonglong;
pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_FAST64_FMTo__ = "llo";
pub const __UINT_FAST64_FMTu__ = "llu";
pub const __UINT_FAST64_FMTx__ = "llx";
pub const __UINT_FAST64_FMTX__ = "llX";
pub const __USER_LABEL_PREFIX__ = @compileError("unable to translate macro: undefined identifier `_`");
// (no file):334:9
pub const __NO_MATH_ERRNO__ = @as(c_int, 1);
pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
pub const __GCC_DESTRUCTIVE_SIZE = @as(c_int, 64);
pub const __GCC_CONSTRUCTIVE_SIZE = @as(c_int, 64);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __NO_INLINE__ = @as(c_int, 1);
pub const __PIC__ = @as(c_int, 2);
pub const __pic__ = @as(c_int, 2);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __SSP_STRONG__ = @as(c_int, 2);
pub const __nonnull = @compileError("unable to translate macro: undefined identifier `_Nonnull`");
// (no file):369:9
pub const __null_unspecified = @compileError("unable to translate macro: undefined identifier `_Null_unspecified`");
// (no file):370:9
pub const __nullable = @compileError("unable to translate macro: undefined identifier `_Nullable`");
// (no file):371:9
pub const TARGET_OS_WIN32 = @as(c_int, 0);
pub const TARGET_OS_WINDOWS = @as(c_int, 0);
pub const TARGET_OS_LINUX = @as(c_int, 0);
pub const TARGET_OS_UNIX = @as(c_int, 0);
pub const TARGET_OS_MAC = @as(c_int, 1);
pub const TARGET_OS_OSX = @as(c_int, 1);
pub const TARGET_OS_IPHONE = @as(c_int, 0);
pub const TARGET_OS_IOS = @as(c_int, 0);
pub const TARGET_OS_TV = @as(c_int, 0);
pub const TARGET_OS_WATCH = @as(c_int, 0);
pub const TARGET_OS_VISION = @as(c_int, 0);
pub const TARGET_OS_DRIVERKIT = @as(c_int, 0);
pub const TARGET_OS_MACCATALYST = @as(c_int, 0);
pub const TARGET_OS_SIMULATOR = @as(c_int, 0);
pub const TARGET_OS_EMBEDDED = @as(c_int, 0);
pub const TARGET_OS_NANO = @as(c_int, 0);
pub const TARGET_IPHONE_SIMULATOR = @as(c_int, 0);
pub const TARGET_OS_UIKITFORMAC = @as(c_int, 0);
pub const __AARCH64EL__ = @as(c_int, 1);
pub const __aarch64__ = @as(c_int, 1);
pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(c_int, 1);
pub const __AARCH64_CMODEL_SMALL__ = @as(c_int, 1);
pub inline fn __ARM_ACLE_VERSION(year: anytype, quarter: anytype, patch: anytype) @TypeOf(((@as(c_int, 100) * year) + (@as(c_int, 10) * quarter)) + patch) {
    _ = &year;
    _ = &quarter;
    _ = &patch;
    return ((@as(c_int, 100) * year) + (@as(c_int, 10) * quarter)) + patch;
}
pub const __ARM_ACLE = @import("std").zig.c_translation.promoteIntLiteral(c_int, 202420, .decimal);
pub const __FUNCTION_MULTI_VERSIONING_SUPPORT_LEVEL = @import("std").zig.c_translation.promoteIntLiteral(c_int, 202430, .decimal);
pub const __ARM_ARCH = @as(c_int, 8);
pub const __ARM_ARCH_PROFILE = 'A';
pub const __ARM_64BIT_STATE = @as(c_int, 1);
pub const __ARM_PCS_AAPCS64 = @as(c_int, 1);
pub const __ARM_ARCH_ISA_A64 = @as(c_int, 1);
pub const __ARM_FEATURE_CLZ = @as(c_int, 1);
pub const __ARM_FEATURE_FMA = @as(c_int, 1);
pub const __ARM_FEATURE_LDREX = @as(c_int, 0xF);
pub const __ARM_FEATURE_IDIV = @as(c_int, 1);
pub const __ARM_FEATURE_DIV = @as(c_int, 1);
pub const __ARM_FEATURE_NUMERIC_MAXMIN = @as(c_int, 1);
pub const __ARM_FEATURE_DIRECTED_ROUNDING = @as(c_int, 1);
pub const __ARM_ALIGN_MAX_STACK_PWR = @as(c_int, 4);
pub const __ARM_STATE_ZA = @as(c_int, 1);
pub const __ARM_STATE_ZT0 = @as(c_int, 1);
pub const __ARM_FP = @as(c_int, 0xE);
pub const __ARM_FP16_FORMAT_IEEE = @as(c_int, 1);
pub const __ARM_FP16_ARGS = @as(c_int, 1);
pub const __ARM_NEON_SVE_BRIDGE = @as(c_int, 1);
pub const __ARM_SIZEOF_WCHAR_T = @as(c_int, 4);
pub const __ARM_SIZEOF_MINIMAL_ENUM = @as(c_int, 4);
pub const __ARM_NEON = @as(c_int, 1);
pub const __ARM_NEON_FP = @as(c_int, 0xE);
pub const __ARM_FEATURE_CRC32 = @as(c_int, 1);
pub const __ARM_FEATURE_RCPC = @as(c_int, 1);
pub const __ARM_FEATURE_CRYPTO = @as(c_int, 1);
pub const __ARM_FEATURE_AES = @as(c_int, 1);
pub const __ARM_FEATURE_SHA2 = @as(c_int, 1);
pub const __ARM_FEATURE_SHA3 = @as(c_int, 1);
pub const __ARM_FEATURE_SHA512 = @as(c_int, 1);
pub const __ARM_FEATURE_PAUTH = @as(c_int, 1);
pub const __ARM_FEATURE_UNALIGNED = @as(c_int, 1);
pub const __ARM_FEATURE_FP16_VECTOR_ARITHMETIC = @as(c_int, 1);
pub const __ARM_FEATURE_FP16_SCALAR_ARITHMETIC = @as(c_int, 1);
pub const __ARM_FEATURE_DOTPROD = @as(c_int, 1);
pub const __ARM_FEATURE_ATOMICS = @as(c_int, 1);
pub const __ARM_FEATURE_FP16_FML = @as(c_int, 1);
pub const __ARM_FEATURE_COMPLEX = @as(c_int, 1);
pub const __ARM_FEATURE_JCVT = @as(c_int, 1);
pub const __ARM_FEATURE_QRDMX = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(c_int, 1);
pub const __FP_FAST_FMA = @as(c_int, 1);
pub const __FP_FAST_FMAF = @as(c_int, 1);
pub const __AARCH64_SIMD__ = @as(c_int, 1);
pub const __ARM64_ARCH_8__ = @as(c_int, 1);
pub const __ARM_NEON__ = @as(c_int, 1);
pub const __REGISTER_PREFIX__ = "";
pub const __arm64 = @as(c_int, 1);
pub const __arm64__ = @as(c_int, 1);
pub const __APPLE_CC__ = @as(c_int, 6000);
pub const __APPLE__ = @as(c_int, 1);
pub const __weak = @compileError("unable to translate macro: undefined identifier `objc_gc`");
// (no file):452:9
pub const __strong = "";
pub const __unsafe_unretained = "";
pub const __DYNAMIC__ = @as(c_int, 1);
pub const __MACH__ = @as(c_int, 1);
pub const __STDC_NO_THREADS__ = @as(c_int, 1);
pub const __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 260300, .decimal);
pub const __ENVIRONMENT_OS_VERSION_MIN_REQUIRED__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 260300, .decimal);
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const __STDC_EMBED_NOT_FOUND__ = @as(c_int, 0);
pub const __STDC_EMBED_FOUND__ = @as(c_int, 1);
pub const __STDC_EMBED_EMPTY__ = @as(c_int, 2);
pub const __GCC_HAVE_DWARF2_CFI_ASM = @as(c_int, 1);
pub const NPROC = @as(c_int, 64);
pub const NCPU = @as(c_int, 8);
pub const NOFILE = @as(c_int, 16);
pub const NFILE = @as(c_int, 100);
pub const NINODE = @as(c_int, 50);
pub const NDEV = @as(c_int, 10);
pub const ROOTDEV = @as(c_int, 1);
pub const MAXARG = @as(c_int, 32);
pub const MAXOPBLOCKS = @as(c_int, 10);
pub const LOGBLOCKS = MAXOPBLOCKS * @as(c_int, 3);
pub const NBUF = MAXOPBLOCKS * @as(c_int, 3);
pub const FSSIZE = @as(c_int, 2000);
pub const MAXPATH = @as(c_int, 128);
pub const USERSTACK = @as(c_int, 1);
pub const T_DIR = @as(c_int, 1);
pub const T_FILE = @as(c_int, 2);
pub const T_DEVICE = @as(c_int, 3);
pub const SBRK_ERROR = @import("std").zig.c_translation.cast([*c]u8, -@as(c_int, 1));
pub const ROOTINO = @as(c_int, 1);
pub const BSIZE = @as(c_int, 1024);
pub const FSMAGIC = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x10203040, .hex);
pub const NDIRECT = @as(c_int, 12);
pub const NINDIRECT = @import("std").zig.c_translation.MacroArithmetic.div(BSIZE, @import("std").zig.c_translation.sizeof(uint));
pub const MAXFILE = NDIRECT + NINDIRECT;
pub const IPB = @import("std").zig.c_translation.MacroArithmetic.div(BSIZE, @import("std").zig.c_translation.sizeof(struct_dinode));
pub inline fn IBLOCK(i: anytype, sb: anytype) @TypeOf(@import("std").zig.c_translation.MacroArithmetic.div(i, IPB) + sb.inodestart) {
    _ = &i;
    _ = &sb;
    return @import("std").zig.c_translation.MacroArithmetic.div(i, IPB) + sb.inodestart;
}
pub const BPB = BSIZE * @as(c_int, 8);
pub inline fn BBLOCK(b: anytype, sb: anytype) @TypeOf(@import("std").zig.c_translation.MacroArithmetic.div(b, BPB) + sb.bmapstart) {
    _ = &b;
    _ = &sb;
    return @import("std").zig.c_translation.MacroArithmetic.div(b, BPB) + sb.bmapstart;
}
pub const DIRSIZ = @as(c_int, 14);
pub const O_RDONLY = @as(c_int, 0x000);
pub const O_WRONLY = @as(c_int, 0x001);
pub const O_RDWR = @as(c_int, 0x002);
pub const O_CREATE = @as(c_int, 0x200);
pub const O_TRUNC = @as(c_int, 0x400);
pub const SYS_fork = @as(c_int, 1);
pub const SYS_exit = @as(c_int, 2);
pub const SYS_wait = @as(c_int, 3);
pub const SYS_pipe = @as(c_int, 4);
pub const SYS_read = @as(c_int, 5);
pub const SYS_kill = @as(c_int, 6);
pub const SYS_exec = @as(c_int, 7);
pub const SYS_fstat = @as(c_int, 8);
pub const SYS_chdir = @as(c_int, 9);
pub const SYS_dup = @as(c_int, 10);
pub const SYS_getpid = @as(c_int, 11);
pub const SYS_sbrk = @as(c_int, 12);
pub const SYS_pause = @as(c_int, 13);
pub const SYS_uptime = @as(c_int, 14);
pub const SYS_open = @as(c_int, 15);
pub const SYS_write = @as(c_int, 16);
pub const SYS_mknod = @as(c_int, 17);
pub const SYS_unlink = @as(c_int, 18);
pub const SYS_link = @as(c_int, 19);
pub const SYS_mkdir = @as(c_int, 20);
pub const SYS_close = @as(c_int, 21);
pub const UART0 = @as(c_long, 0x10000000);
pub const UART0_IRQ = @as(c_int, 10);
pub const VIRTIO0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x10001000, .hex);
pub const VIRTIO0_IRQ = @as(c_int, 1);
pub const PLIC = @as(c_long, 0x0c000000);
pub const PLIC_PRIORITY = PLIC + @as(c_int, 0x0);
pub const PLIC_PENDING = PLIC + @as(c_int, 0x1000);
pub inline fn PLIC_SENABLE(hart: anytype) @TypeOf((PLIC + @as(c_int, 0x2080)) + (hart * @as(c_int, 0x100))) {
    _ = &hart;
    return (PLIC + @as(c_int, 0x2080)) + (hart * @as(c_int, 0x100));
}
pub inline fn PLIC_SPRIORITY(hart: anytype) @TypeOf((PLIC + @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x201000, .hex)) + (hart * @as(c_int, 0x2000))) {
    _ = &hart;
    return (PLIC + @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x201000, .hex)) + (hart * @as(c_int, 0x2000));
}
pub inline fn PLIC_SCLAIM(hart: anytype) @TypeOf((PLIC + @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x201004, .hex)) + (hart * @as(c_int, 0x2000))) {
    _ = &hart;
    return (PLIC + @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x201004, .hex)) + (hart * @as(c_int, 0x2000));
}
pub const KERNBASE = @import("std").zig.c_translation.promoteIntLiteral(c_long, 0x80000000, .hex);
pub const PHYSTOP = KERNBASE + ((@as(c_int, 128) * @as(c_int, 1024)) * @as(c_int, 1024));
pub const TRAMPOLINE = MAXVA - PGSIZE;
pub inline fn KSTACK(p: anytype) @TypeOf(TRAMPOLINE - (((p + @as(c_int, 1)) * @as(c_int, 2)) * PGSIZE)) {
    _ = &p;
    return TRAMPOLINE - (((p + @as(c_int, 1)) * @as(c_int, 2)) * PGSIZE);
}
pub const TRAPFRAME = TRAMPOLINE - PGSIZE;
pub const MSTATUS_MPP_MASK = @as(c_long, 3) << @as(c_int, 11);
pub const MSTATUS_MPP_M = @as(c_long, 3) << @as(c_int, 11);
pub const MSTATUS_MPP_S = @as(c_long, 1) << @as(c_int, 11);
pub const MSTATUS_MPP_U = @as(c_long, 0) << @as(c_int, 11);
pub const SSTATUS_SPP = @as(c_long, 1) << @as(c_int, 8);
pub const SSTATUS_SPIE = @as(c_long, 1) << @as(c_int, 5);
pub const SSTATUS_UPIE = @as(c_long, 1) << @as(c_int, 4);
pub const SSTATUS_SIE = @as(c_long, 1) << @as(c_int, 1);
pub const SSTATUS_UIE = @as(c_long, 1) << @as(c_int, 0);
pub const SIE_SEIE = @as(c_long, 1) << @as(c_int, 9);
pub const SIE_STIE = @as(c_long, 1) << @as(c_int, 5);
pub const MIE_STIE = @as(c_long, 1) << @as(c_int, 5);
pub const SATP_SV39 = @as(c_long, 8) << @as(c_int, 60);
pub inline fn MAKE_SATP(pagetable: anytype) @TypeOf(SATP_SV39 | (@import("std").zig.c_translation.cast(uint64, pagetable) >> @as(c_int, 12))) {
    _ = &pagetable;
    return SATP_SV39 | (@import("std").zig.c_translation.cast(uint64, pagetable) >> @as(c_int, 12));
}
pub const PGSIZE = @as(c_int, 4096);
pub const PGSHIFT = @as(c_int, 12);
pub inline fn PGROUNDUP(sz: anytype) @TypeOf(((sz + PGSIZE) - @as(c_int, 1)) & ~(PGSIZE - @as(c_int, 1))) {
    _ = &sz;
    return ((sz + PGSIZE) - @as(c_int, 1)) & ~(PGSIZE - @as(c_int, 1));
}
pub inline fn PGROUNDDOWN(a: anytype) @TypeOf(a & ~(PGSIZE - @as(c_int, 1))) {
    _ = &a;
    return a & ~(PGSIZE - @as(c_int, 1));
}
pub const PTE_V = @as(c_long, 1) << @as(c_int, 0);
pub const PTE_R = @as(c_long, 1) << @as(c_int, 1);
pub const PTE_W = @as(c_long, 1) << @as(c_int, 2);
pub const PTE_X = @as(c_long, 1) << @as(c_int, 3);
pub const PTE_U = @as(c_long, 1) << @as(c_int, 4);
pub inline fn PA2PTE(pa: anytype) @TypeOf((@import("std").zig.c_translation.cast(uint64, pa) >> @as(c_int, 12)) << @as(c_int, 10)) {
    _ = &pa;
    return (@import("std").zig.c_translation.cast(uint64, pa) >> @as(c_int, 12)) << @as(c_int, 10);
}
pub inline fn PTE2PA(pte: anytype) @TypeOf((pte >> @as(c_int, 10)) << @as(c_int, 12)) {
    _ = &pte;
    return (pte >> @as(c_int, 10)) << @as(c_int, 12);
}
pub inline fn PTE_FLAGS(pte: anytype) @TypeOf(pte & @as(c_int, 0x3FF)) {
    _ = &pte;
    return pte & @as(c_int, 0x3FF);
}
pub const PXMASK = @as(c_int, 0x1FF);
pub inline fn PXSHIFT(level: anytype) @TypeOf(PGSHIFT + (@as(c_int, 9) * level)) {
    _ = &level;
    return PGSHIFT + (@as(c_int, 9) * level);
}
pub inline fn PX(level: anytype, va: anytype) @TypeOf((@import("std").zig.c_translation.cast(uint64, va) >> PXSHIFT(level)) & PXMASK) {
    _ = &level;
    _ = &va;
    return (@import("std").zig.c_translation.cast(uint64, va) >> PXSHIFT(level)) & PXMASK;
}
pub const MAXVA = @as(c_long, 1) << ((((@as(c_int, 9) + @as(c_int, 9)) + @as(c_int, 9)) + @as(c_int, 12)) - @as(c_int, 1));
pub const superblock = struct_superblock;
pub const dinode = struct_dinode;
pub const dirent = struct_dirent;
