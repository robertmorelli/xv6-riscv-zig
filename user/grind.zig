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
pub fn intr_on() void {
    w_sstatus(r_sstatus() | @as(uint64, @bitCast(@as(i64, 1) << @intCast(1))));
}
pub fn intr_off() void {
    w_sstatus(r_sstatus() & @as(uint64, @bitCast(~(@as(i64, 1) << @intCast(1)))));
}
pub fn intr_get() i32 {
    var x: uint64 = r_sstatus();
    _ = &x;
    return @intFromBool((x & @as(uint64, @bitCast(@as(i64, 1) << @intCast(1)))) != @as(uint64, @bitCast(@as(i64, @as(i32, 0)))));
}

pub extern fn r_sp() uint64;

pub extern fn r_tp() uint64;

pub extern fn w_tp(arg_x: uint64) void;

pub extern fn r_ra() uint64;

pub extern fn sfence_vma() void;
pub const pte_t = uint64;
pub const pagetable_t = [*c]uint64;
pub export fn do_rand(arg_ctx: [*c]u64) i32 {
    var ctx = arg_ctx;
    _ = &ctx;
    var hi: i64 = undefined;
    _ = &hi;
    var lo: i64 = undefined;
    _ = &lo;
    var x: i64 = undefined;
    _ = &x;
    x = @as(i64, @bitCast((ctx.* % @as(u64, @bitCast(@as(i64, @as(i32, 2147483646))))) +% @as(u64, @bitCast(@as(i64, @as(i32, 1))))));
    hi = @divTrunc(x, @as(i64, @bitCast(@as(i64, @as(i32, 127773)))));
    lo = @import("std").zig.c_translation.signedRemainder(x, @as(i64, @bitCast(@as(i64, @as(i32, 127773)))));
    x = (@as(i64, @bitCast(@as(i64, @as(i32, 16807)))) * lo) - (@as(i64, @bitCast(@as(i64, @as(i32, 2836)))) * hi);
    if (x < @as(i64, @bitCast(@as(i64, @as(i32, 0))))) {
        x += @as(i64, @bitCast(@as(i64, @as(i32, 2147483647))));
    }
    x -= 1;
    ctx.* = @as(u64, @bitCast(x));
    return @as(i32, @bitCast(@as(i32, @truncate(x))));
}
pub export var rand_next: u64 = 1;
pub export fn rand() i32 {
    return do_rand(&rand_next);
}
pub export fn go(arg_which_child: i32) void {
    var which_child = arg_which_child;
    _ = &which_child;
    var fd: i32 = -@as(i32, 1);
    _ = &fd;
    const buf = struct {
        var static: [999]u8 = @import("std").mem.zeroes([999]u8);
    };
    _ = &buf;
    var break0: [*c]u8 = sbrk(@as(i32, 0));
    _ = &break0;
    var iters: uint64 = 0;
    _ = &iters;
    _ = mkdir("grindir");
    if (chdir("grindir") != @as(i32, 0)) {
        printf("grind: chdir grindir failed\n");
        _ = exit(@as(i32, 1));
    }
    _ = chdir("/");
    while (true) {
        iters +%= 1;
        if ((iters % @as(uint64, @bitCast(@as(i64, @as(i32, 500))))) == @as(uint64, @bitCast(@as(i64, @as(i32, 0))))) {
            _ = write(@as(i32, 1), @as(?*const anyopaque, @ptrCast(if (which_child != 0) "B" else "A")), @as(i32, 1));
        }
        var what: i32 = @import("std").zig.c_translation.signedRemainder(rand(), @as(i32, 23));
        _ = &what;
        if (what == @as(i32, 1)) {
            _ = close(open("grindir/../a", @as(i32, 512) | @as(i32, 2)));
        } else if (what == @as(i32, 2)) {
            _ = close(open("grindir/../grindir/../b", @as(i32, 512) | @as(i32, 2)));
        } else if (what == @as(i32, 3)) {
            _ = unlink("grindir/../a");
        } else if (what == @as(i32, 4)) {
            if (chdir("grindir") != @as(i32, 0)) {
                printf("grind: chdir grindir failed\n");
                _ = exit(@as(i32, 1));
            }
            _ = unlink("../b");
            _ = chdir("/");
        } else if (what == @as(i32, 5)) {
            _ = close(fd);
            fd = open("/grindir/../a", @as(i32, 512) | @as(i32, 2));
        } else if (what == @as(i32, 6)) {
            _ = close(fd);
            fd = open("/./grindir/./../b", @as(i32, 512) | @as(i32, 2));
        } else if (what == @as(i32, 7)) {
            _ = write(fd, @as(?*const anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf.static[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([999]u8))))));
        } else if (what == @as(i32, 8)) {
            _ = read(fd, @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf.static[@as(u64, @intCast(0))]))))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([999]u8))))));
        } else if (what == @as(i32, 9)) {
            _ = mkdir("grindir/../a");
            _ = close(open("a/../a/./a", @as(i32, 512) | @as(i32, 2)));
            _ = unlink("a/a");
        } else if (what == @as(i32, 10)) {
            _ = mkdir("/../b");
            _ = close(open("grindir/../b/b", @as(i32, 512) | @as(i32, 2)));
            _ = unlink("b/b");
        } else if (what == @as(i32, 11)) {
            _ = unlink("b");
            _ = link("../grindir/./../a", "../b");
        } else if (what == @as(i32, 12)) {
            _ = unlink("../grindir/../a");
            _ = link(".././b", "/grindir/../a");
        } else if (what == @as(i32, 13)) {
            var pid: i32 = fork();
            _ = &pid;
            if (pid == @as(i32, 0)) {
                _ = exit(@as(i32, 0));
            } else if (pid < @as(i32, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(i32, 1));
            }
            _ = wait(null);
        } else if (what == @as(i32, 14)) {
            var pid: i32 = fork();
            _ = &pid;
            if (pid == @as(i32, 0)) {
                _ = fork();
                _ = fork();
                _ = exit(@as(i32, 0));
            } else if (pid < @as(i32, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(i32, 1));
            }
            _ = wait(null);
        } else if (what == @as(i32, 15)) {
            _ = sbrk(@as(i32, 6011));
        } else if (what == @as(i32, 16)) {
            if (sbrk(@as(i32, 0)) > break0) {
                _ = sbrk(@as(i32, @bitCast(@as(i32, @truncate(-@divExact(@as(i64, @bitCast(@intFromPtr(sbrk(@as(i32, 0))) -% @intFromPtr(break0))), @sizeOf(u8)))))));
            }
        } else if (what == @as(i32, 17)) {
            var pid: i32 = fork();
            _ = &pid;
            if (pid == @as(i32, 0)) {
                _ = close(open("a", @as(i32, 512) | @as(i32, 2)));
                _ = exit(@as(i32, 0));
            } else if (pid < @as(i32, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(i32, 1));
            }
            if (chdir("../grindir/..") != @as(i32, 0)) {
                printf("grind: chdir failed\n");
                _ = exit(@as(i32, 1));
            }
            _ = kill(pid);
            _ = wait(null);
        } else if (what == @as(i32, 18)) {
            var pid: i32 = fork();
            _ = &pid;
            if (pid == @as(i32, 0)) {
                _ = kill(getpid());
                _ = exit(@as(i32, 0));
            } else if (pid < @as(i32, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(i32, 1));
            }
            _ = wait(null);
        } else if (what == @as(i32, 19)) {
            var fds: [2]i32 = undefined;
            _ = &fds;
            if (pipe(@as([*c]i32, @ptrCast(@alignCast(&fds[@as(u64, @intCast(0))])))) < @as(i32, 0)) {
                printf("grind: pipe failed\n");
                _ = exit(@as(i32, 1));
            }
            var pid: i32 = fork();
            _ = &pid;
            if (pid == @as(i32, 0)) {
                _ = fork();
                _ = fork();
                if (write(fds[@as(u32, @intCast(@as(i32, 1)))], @as(?*const anyopaque, @ptrCast("x")), @as(i32, 1)) != @as(i32, 1)) {
                    printf("grind: pipe write failed\n");
                }
                var c: u8 = undefined;
                _ = &c;
                if (read(fds[@as(u32, @intCast(@as(i32, 0)))], @as(?*anyopaque, @ptrCast(&c)), @as(i32, 1)) != @as(i32, 1)) {
                    printf("grind: pipe read failed\n");
                }
                _ = exit(@as(i32, 0));
            } else if (pid < @as(i32, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(i32, 1));
            }
            _ = close(fds[@as(u32, @intCast(@as(i32, 0)))]);
            _ = close(fds[@as(u32, @intCast(@as(i32, 1)))]);
            _ = wait(null);
        } else if (what == @as(i32, 20)) {
            var pid: i32 = fork();
            _ = &pid;
            if (pid == @as(i32, 0)) {
                _ = unlink("a");
                _ = mkdir("a");
                _ = chdir("a");
                _ = unlink("../a");
                fd = open("x", @as(i32, 512) | @as(i32, 2));
                _ = unlink("x");
                _ = exit(@as(i32, 0));
            } else if (pid < @as(i32, 0)) {
                printf("grind: fork failed\n");
                _ = exit(@as(i32, 1));
            }
            _ = wait(null);
        } else if (what == @as(i32, 21)) {
            _ = unlink("c");
            var fd1: i32 = open("c", @as(i32, 512) | @as(i32, 2));
            _ = &fd1;
            if (fd1 < @as(i32, 0)) {
                printf("grind: create c failed\n");
                _ = exit(@as(i32, 1));
            }
            if (write(fd1, @as(?*const anyopaque, @ptrCast("x")), @as(i32, 1)) != @as(i32, 1)) {
                printf("grind: write c failed\n");
                _ = exit(@as(i32, 1));
            }
            var st: struct_stat = undefined;
            _ = &st;
            if (fstat(fd1, &st) != @as(i32, 0)) {
                printf("grind: fstat failed\n");
                _ = exit(@as(i32, 1));
            }
            if (st.size != @as(uint64, @bitCast(@as(i64, @as(i32, 1))))) {
                printf("grind: fstat reports wrong size %d\n", @as(i32, @bitCast(@as(u32, @truncate(st.size)))));
                _ = exit(@as(i32, 1));
            }
            if (st.ino > @as(uint, @bitCast(@as(i32, 200)))) {
                printf("grind: fstat reports crazy i-number %d\n", st.ino);
                _ = exit(@as(i32, 1));
            }
            _ = close(fd1);
            _ = unlink("c");
        } else if (what == @as(i32, 22)) {
            var aa: [2]i32 = undefined;
            _ = &aa;
            var bb: [2]i32 = undefined;
            _ = &bb;
            if (pipe(@as([*c]i32, @ptrCast(@alignCast(&aa[@as(u64, @intCast(0))])))) < @as(i32, 0)) {
                fprintf(@as(i32, 2), "grind: pipe failed\n");
                _ = exit(@as(i32, 1));
            }
            if (pipe(@as([*c]i32, @ptrCast(@alignCast(&bb[@as(u64, @intCast(0))])))) < @as(i32, 0)) {
                fprintf(@as(i32, 2), "grind: pipe failed\n");
                _ = exit(@as(i32, 1));
            }
            var pid1: i32 = fork();
            _ = &pid1;
            if (pid1 == @as(i32, 0)) {
                _ = close(bb[@as(u32, @intCast(@as(i32, 0)))]);
                _ = close(bb[@as(u32, @intCast(@as(i32, 1)))]);
                _ = close(aa[@as(u32, @intCast(@as(i32, 0)))]);
                _ = close(@as(i32, 1));
                if (dup(aa[@as(u32, @intCast(@as(i32, 1)))]) != @as(i32, 1)) {
                    fprintf(@as(i32, 2), "grind: dup failed\n");
                    _ = exit(@as(i32, 1));
                }
                _ = close(aa[@as(u32, @intCast(@as(i32, 1)))]);
                var args: [3][*c]u8 = [3][*c]u8{
                    @constCast("echo"),
                    @constCast("hi"),
                    null,
                };
                _ = &args;
                _ = exec("grindir/../echo", @as([*c][*c]u8, @ptrCast(@alignCast(&args[@as(u64, @intCast(0))]))));
                fprintf(@as(i32, 2), "grind: echo: not found\n");
                _ = exit(@as(i32, 2));
            } else if (pid1 < @as(i32, 0)) {
                fprintf(@as(i32, 2), "grind: fork failed\n");
                _ = exit(@as(i32, 3));
            }
            var pid2: i32 = fork();
            _ = &pid2;
            if (pid2 == @as(i32, 0)) {
                _ = close(aa[@as(u32, @intCast(@as(i32, 1)))]);
                _ = close(bb[@as(u32, @intCast(@as(i32, 0)))]);
                _ = close(@as(i32, 0));
                if (dup(aa[@as(u32, @intCast(@as(i32, 0)))]) != @as(i32, 0)) {
                    fprintf(@as(i32, 2), "grind: dup failed\n");
                    _ = exit(@as(i32, 4));
                }
                _ = close(aa[@as(u32, @intCast(@as(i32, 0)))]);
                _ = close(@as(i32, 1));
                if (dup(bb[@as(u32, @intCast(@as(i32, 1)))]) != @as(i32, 1)) {
                    fprintf(@as(i32, 2), "grind: dup failed\n");
                    _ = exit(@as(i32, 5));
                }
                _ = close(bb[@as(u32, @intCast(@as(i32, 1)))]);
                var args: [2][*c]u8 = [2][*c]u8{
                    @constCast("cat"),
                    null,
                };
                _ = &args;
                _ = exec("/cat", @as([*c][*c]u8, @ptrCast(@alignCast(&args[@as(u64, @intCast(0))]))));
                fprintf(@as(i32, 2), "grind: cat: not found\n");
                _ = exit(@as(i32, 6));
            } else if (pid2 < @as(i32, 0)) {
                fprintf(@as(i32, 2), "grind: fork failed\n");
                _ = exit(@as(i32, 7));
            }
            _ = close(aa[@as(u32, @intCast(@as(i32, 0)))]);
            _ = close(aa[@as(u32, @intCast(@as(i32, 1)))]);
            _ = close(bb[@as(u32, @intCast(@as(i32, 1)))]);
            var buf_1: [4]u8 = [4]u8{
                0,
                0,
                0,
                0,
            };
            _ = &buf_1;
            _ = read(bb[@as(u32, @intCast(@as(i32, 0)))], @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))) + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 0))))))), @as(i32, 1));
            _ = read(bb[@as(u32, @intCast(@as(i32, 0)))], @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))) + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 1))))))), @as(i32, 1));
            _ = read(bb[@as(u32, @intCast(@as(i32, 0)))], @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))) + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 2))))))), @as(i32, 1));
            _ = close(bb[@as(u32, @intCast(@as(i32, 0)))]);
            var st1: i32 = undefined;
            _ = &st1;
            var st2: i32 = undefined;
            _ = &st2;
            _ = wait(&st1);
            _ = wait(&st2);
            if (((st1 != @as(i32, 0)) or (st2 != @as(i32, 0))) or (strcmp(@as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))), "hi\n") != @as(i32, 0))) {
                printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, @as([*c]u8, @ptrCast(@alignCast(&buf_1[@as(u64, @intCast(0))]))));
                _ = exit(@as(i32, 1));
            }
        }
    }
}
pub export fn iter() void {
    _ = unlink("a");
    _ = unlink("b");
    var pid1: i32 = fork();
    _ = &pid1;
    if (pid1 < @as(i32, 0)) {
        printf("grind: fork failed\n");
        _ = exit(@as(i32, 1));
    }
    if (pid1 == @as(i32, 0)) {
        rand_next ^= @as(u64, @bitCast(@as(i64, @as(i32, 31))));
        go(@as(i32, 0));
        _ = exit(@as(i32, 0));
    }
    var pid2: i32 = fork();
    _ = &pid2;
    if (pid2 < @as(i32, 0)) {
        printf("grind: fork failed\n");
        _ = exit(@as(i32, 1));
    }
    if (pid2 == @as(i32, 0)) {
        rand_next ^= @as(u64, @bitCast(@as(i64, @as(i32, 7177))));
        go(@as(i32, 1));
        _ = exit(@as(i32, 0));
    }
    var st1: i32 = -@as(i32, 1);
    _ = &st1;
    _ = wait(&st1);
    if (st1 != @as(i32, 0)) {
        _ = kill(pid1);
        _ = kill(pid2);
    }
    var st2: i32 = -@as(i32, 1);
    _ = &st2;
    _ = wait(&st2);
    _ = exit(@as(i32, 0));
}
pub export fn main() i32 {
    while (true) {
        var pid: i32 = fork();
        _ = &pid;
        if (pid == @as(i32, 0)) {
            iter();
            _ = exit(@as(i32, 0));
        }
        if (pid > @as(i32, 0)) {
            _ = wait(null);
        }
        _ = pause(@as(i32, 20));
        rand_next +%= @as(u64, @bitCast(@as(i64, @as(i32, 1))));
    }
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
pub const superblock = struct_superblock;
pub const dinode = struct_dinode;
pub const dirent = struct_dirent;
