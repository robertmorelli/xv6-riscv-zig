pub const uint = u32;
pub const ushort = u16;
pub const uchar = u8;
pub const uint8 = u8;
pub const uint16 = u16;
pub const uint32 = u32;
pub const uint64 = u64;
pub const pde_t = uint64;
pub const struct_stat = opaque {};
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
pub extern fn fstat(fd: i32, ?*struct_stat) i32;
pub extern fn link([*c]const u8, [*c]const u8) i32;
pub extern fn mkdir([*c]const u8) i32;
pub extern fn chdir([*c]const u8) i32;
pub extern fn dup(i32) i32;
pub extern fn getpid() i32;
pub extern fn sys_sbrk(i32, i32) [*c]u8;
pub extern fn pause(i32) i32;
pub extern fn uptime() i32;
pub extern fn stat([*c]const u8, ?*struct_stat) i32;
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
pub const struct_cmd = extern struct {
    type: i32 = @import("std").mem.zeroes(i32),
};
pub const struct_execcmd = extern struct {
    type: i32 = @import("std").mem.zeroes(i32),
    argv: [10][*c]u8 = @import("std").mem.zeroes([10][*c]u8),
    eargv: [10][*c]u8 = @import("std").mem.zeroes([10][*c]u8),
};
pub const struct_redircmd = extern struct {
    type: i32 = @import("std").mem.zeroes(i32),
    cmd: [*c]struct_cmd = @import("std").mem.zeroes([*c]struct_cmd),
    file: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    efile: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    mode: i32 = @import("std").mem.zeroes(i32),
    fd: i32 = @import("std").mem.zeroes(i32),
};
pub const struct_pipecmd = extern struct {
    type: i32 = @import("std").mem.zeroes(i32),
    left: [*c]struct_cmd = @import("std").mem.zeroes([*c]struct_cmd),
    right: [*c]struct_cmd = @import("std").mem.zeroes([*c]struct_cmd),
};
pub const struct_listcmd = extern struct {
    type: i32 = @import("std").mem.zeroes(i32),
    left: [*c]struct_cmd = @import("std").mem.zeroes([*c]struct_cmd),
    right: [*c]struct_cmd = @import("std").mem.zeroes([*c]struct_cmd),
};
pub const struct_backcmd = extern struct {
    type: i32 = @import("std").mem.zeroes(i32),
    cmd: [*c]struct_cmd = @import("std").mem.zeroes([*c]struct_cmd),
};
pub export fn fork1() i32 {
    var pid: i32 = undefined;
    _ = &pid;
    pid = fork();
    if (pid == -@as(i32, 1)) {
        panic(@as([*c]u8, @ptrCast(@constCast(@volatileCast("fork")))));
    }
    return pid;
}
pub export fn panic(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    fprintf(@as(i32, 2), "%s\n", s);
    _ = exit(@as(i32, 1));
}
pub export fn parsecmd(arg_s: [*c]u8) [*c]struct_cmd {
    var s = arg_s;
    _ = &s;
    var es: [*c]u8 = undefined;
    _ = &es;
    var cmd_1: [*c]struct_cmd = undefined;
    _ = &cmd_1;
    es = s + strlen(s);
    cmd_1 = parseline(&s, es);
    _ = peek(&s, es, @as([*c]u8, @ptrCast(@constCast(@volatileCast("")))));
    if (s != es) {
        fprintf(@as(i32, 2), "leftovers: %s\n", s);
        panic(@as([*c]u8, @ptrCast(@constCast(@volatileCast("syntax")))));
    }
    _ = nulterminate(cmd_1);
    return cmd_1;
}
pub export fn runcmd(arg_cmd_1: [*c]struct_cmd) noreturn {
    var cmd_1 = arg_cmd_1;
    _ = &cmd_1;
    var p: [2]i32 = undefined;
    _ = &p;
    var bcmd: [*c]struct_backcmd = undefined;
    _ = &bcmd;
    var ecmd: [*c]struct_execcmd = undefined;
    _ = &ecmd;
    var lcmd: [*c]struct_listcmd = undefined;
    _ = &lcmd;
    var pcmd: [*c]struct_pipecmd = undefined;
    _ = &pcmd;
    var rcmd: [*c]struct_redircmd = undefined;
    _ = &rcmd;
    if (cmd_1 == null) {
        _ = exit(@as(i32, 1));
    }
    while (true) {
        switch (cmd_1.*.type) {
            else => {
                panic(@as([*c]u8, @ptrCast(@constCast(@volatileCast("runcmd")))));
                ecmd = @as([*c]struct_execcmd, @ptrCast(@alignCast(cmd_1)));
                if (ecmd.*.argv[@as(u32, @intCast(@as(i32, 0)))] == null) {
                    _ = exit(@as(i32, 1));
                }
                _ = exec(ecmd.*.argv[@as(u32, @intCast(@as(i32, 0)))], @as([*c][*c]u8, @ptrCast(@alignCast(&ecmd.*.argv[@as(u64, @intCast(0))]))));
                fprintf(@as(i32, 2), "exec %s failed\n", ecmd.*.argv[@as(u32, @intCast(@as(i32, 0)))]);
                break;
            },
            @as(i32, 1) => {
                ecmd = @as([*c]struct_execcmd, @ptrCast(@alignCast(cmd_1)));
                if (ecmd.*.argv[@as(u32, @intCast(@as(i32, 0)))] == null) {
                    _ = exit(@as(i32, 1));
                }
                _ = exec(ecmd.*.argv[@as(u32, @intCast(@as(i32, 0)))], @as([*c][*c]u8, @ptrCast(@alignCast(&ecmd.*.argv[@as(u64, @intCast(0))]))));
                fprintf(@as(i32, 2), "exec %s failed\n", ecmd.*.argv[@as(u32, @intCast(@as(i32, 0)))]);
                break;
            },
            @as(i32, 2) => {
                rcmd = @as([*c]struct_redircmd, @ptrCast(@alignCast(cmd_1)));
                _ = close(rcmd.*.fd);
                if (open(rcmd.*.file, rcmd.*.mode) < @as(i32, 0)) {
                    fprintf(@as(i32, 2), "open %s failed\n", rcmd.*.file);
                    _ = exit(@as(i32, 1));
                }
                runcmd(rcmd.*.cmd);
                break;
            },
            @as(i32, 4) => {
                lcmd = @as([*c]struct_listcmd, @ptrCast(@alignCast(cmd_1)));
                if (fork1() == @as(i32, 0)) {
                    runcmd(lcmd.*.left);
                }
                _ = wait(null);
                runcmd(lcmd.*.right);
                break;
            },
            @as(i32, 3) => {
                pcmd = @as([*c]struct_pipecmd, @ptrCast(@alignCast(cmd_1)));
                if (pipe(@as([*c]i32, @ptrCast(@alignCast(&p[@as(u64, @intCast(0))])))) < @as(i32, 0)) {
                    panic(@as([*c]u8, @ptrCast(@constCast(@volatileCast("pipe")))));
                }
                if (fork1() == @as(i32, 0)) {
                    _ = close(@as(i32, 1));
                    _ = dup(p[@as(u32, @intCast(@as(i32, 1)))]);
                    _ = close(p[@as(u32, @intCast(@as(i32, 0)))]);
                    _ = close(p[@as(u32, @intCast(@as(i32, 1)))]);
                    runcmd(pcmd.*.left);
                }
                if (fork1() == @as(i32, 0)) {
                    _ = close(@as(i32, 0));
                    _ = dup(p[@as(u32, @intCast(@as(i32, 0)))]);
                    _ = close(p[@as(u32, @intCast(@as(i32, 0)))]);
                    _ = close(p[@as(u32, @intCast(@as(i32, 1)))]);
                    runcmd(pcmd.*.right);
                }
                _ = close(p[@as(u32, @intCast(@as(i32, 0)))]);
                _ = close(p[@as(u32, @intCast(@as(i32, 1)))]);
                _ = wait(null);
                _ = wait(null);
                break;
            },
            @as(i32, 5) => {
                bcmd = @as([*c]struct_backcmd, @ptrCast(@alignCast(cmd_1)));
                if (fork1() == @as(i32, 0)) {
                    runcmd(bcmd.*.cmd);
                }
                break;
            },
        }
        break;
    }
    _ = exit(@as(i32, 0));
}
pub export fn getcmd(arg_buf: [*c]u8, arg_nbuf: i32) i32 {
    var buf = arg_buf;
    _ = &buf;
    var nbuf = arg_nbuf;
    _ = &nbuf;
    _ = write(@as(i32, 2), @as(?*const anyopaque, @ptrCast("$ ")), @as(i32, 2));
    _ = memset(@as(?*anyopaque, @ptrCast(buf)), @as(i32, 0), @as(uint, @bitCast(nbuf)));
    _ = gets(buf, nbuf);
    if (@as(i32, @bitCast(@as(u32, buf[@as(u32, @intCast(@as(i32, 0)))]))) == @as(i32, 0)) return -@as(i32, 1);
    return 0;
}
pub export fn main() i32 {
    const buf = struct {
        var static: [100]u8 = @import("std").mem.zeroes([100]u8);
    };
    _ = &buf;
    var fd: i32 = undefined;
    _ = &fd;
    while ((blk: {
        const tmp = open("console", @as(i32, 2));
        fd = tmp;
        break :blk tmp;
    }) >= @as(i32, 0)) {
        if (fd >= @as(i32, 3)) {
            _ = close(fd);
            break;
        }
    }
    while (getcmd(@as([*c]u8, @ptrCast(@alignCast(&buf.static[@as(u64, @intCast(0))]))), @as(i32, @bitCast(@as(u32, @truncate(@sizeOf([100]u8)))))) >= @as(i32, 0)) {
        var cmd_1: [*c]u8 = @as([*c]u8, @ptrCast(@alignCast(&buf.static[@as(u64, @intCast(0))])));
        _ = &cmd_1;
        while ((@as(i32, @bitCast(@as(u32, cmd_1.*))) == @as(i32, ' ')) or (@as(i32, @bitCast(@as(u32, cmd_1.*))) == @as(i32, '\t'))) {
            cmd_1 += 1;
        }
        if (@as(i32, @bitCast(@as(u32, cmd_1.*))) == @as(i32, '\n')) continue;
        if (((@as(i32, @bitCast(@as(u32, cmd_1[@as(u32, @intCast(@as(i32, 0)))]))) == @as(i32, 'c')) and (@as(i32, @bitCast(@as(u32, cmd_1[@as(u32, @intCast(@as(i32, 1)))]))) == @as(i32, 'd'))) and (@as(i32, @bitCast(@as(u32, cmd_1[@as(u32, @intCast(@as(i32, 2)))]))) == @as(i32, ' '))) {
            cmd_1[strlen(cmd_1) -% @as(uint, @bitCast(@as(i32, 1)))] = 0;
            if (chdir(cmd_1 + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 3)))))) < @as(i32, 0)) {
                fprintf(@as(i32, 2), "cannot cd %s\n", cmd_1 + @as(u64, @bitCast(@as(i64, @intCast(@as(i32, 3))))));
            }
        } else {
            if (fork1() == @as(i32, 0)) {
                runcmd(parsecmd(cmd_1));
            }
            _ = wait(null);
        }
    }
    _ = exit(@as(i32, 0));
    return 0;
}
pub export fn execcmd() [*c]struct_cmd {
    var cmd_1: [*c]struct_execcmd = undefined;
    _ = &cmd_1;
    cmd_1 = @as([*c]struct_execcmd, @ptrCast(@alignCast(malloc(@as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_execcmd)))))))));
    _ = memset(@as(?*anyopaque, @ptrCast(cmd_1)), @as(i32, 0), @as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_execcmd))))));
    cmd_1.*.type = 1;
    return @as([*c]struct_cmd, @ptrCast(@alignCast(cmd_1)));
}
pub export fn redircmd(arg_subcmd: [*c]struct_cmd, arg_file: [*c]u8, arg_efile: [*c]u8, arg_mode: i32, arg_fd: i32) [*c]struct_cmd {
    var subcmd = arg_subcmd;
    _ = &subcmd;
    var file = arg_file;
    _ = &file;
    var efile = arg_efile;
    _ = &efile;
    var mode = arg_mode;
    _ = &mode;
    var fd = arg_fd;
    _ = &fd;
    var cmd_1: [*c]struct_redircmd = undefined;
    _ = &cmd_1;
    cmd_1 = @as([*c]struct_redircmd, @ptrCast(@alignCast(malloc(@as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_redircmd)))))))));
    _ = memset(@as(?*anyopaque, @ptrCast(cmd_1)), @as(i32, 0), @as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_redircmd))))));
    cmd_1.*.type = 2;
    cmd_1.*.cmd = subcmd;
    cmd_1.*.file = file;
    cmd_1.*.efile = efile;
    cmd_1.*.mode = mode;
    cmd_1.*.fd = fd;
    return @as([*c]struct_cmd, @ptrCast(@alignCast(cmd_1)));
}
pub export fn pipecmd(arg_left: [*c]struct_cmd, arg_right: [*c]struct_cmd) [*c]struct_cmd {
    var left = arg_left;
    _ = &left;
    var right = arg_right;
    _ = &right;
    var cmd_1: [*c]struct_pipecmd = undefined;
    _ = &cmd_1;
    cmd_1 = @as([*c]struct_pipecmd, @ptrCast(@alignCast(malloc(@as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_pipecmd)))))))));
    _ = memset(@as(?*anyopaque, @ptrCast(cmd_1)), @as(i32, 0), @as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_pipecmd))))));
    cmd_1.*.type = 3;
    cmd_1.*.left = left;
    cmd_1.*.right = right;
    return @as([*c]struct_cmd, @ptrCast(@alignCast(cmd_1)));
}
pub export fn listcmd(arg_left: [*c]struct_cmd, arg_right: [*c]struct_cmd) [*c]struct_cmd {
    var left = arg_left;
    _ = &left;
    var right = arg_right;
    _ = &right;
    var cmd_1: [*c]struct_listcmd = undefined;
    _ = &cmd_1;
    cmd_1 = @as([*c]struct_listcmd, @ptrCast(@alignCast(malloc(@as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_listcmd)))))))));
    _ = memset(@as(?*anyopaque, @ptrCast(cmd_1)), @as(i32, 0), @as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_listcmd))))));
    cmd_1.*.type = 4;
    cmd_1.*.left = left;
    cmd_1.*.right = right;
    return @as([*c]struct_cmd, @ptrCast(@alignCast(cmd_1)));
}
pub export fn backcmd(arg_subcmd: [*c]struct_cmd) [*c]struct_cmd {
    var subcmd = arg_subcmd;
    _ = &subcmd;
    var cmd_1: [*c]struct_backcmd = undefined;
    _ = &cmd_1;
    cmd_1 = @as([*c]struct_backcmd, @ptrCast(@alignCast(malloc(@as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_backcmd)))))))));
    _ = memset(@as(?*anyopaque, @ptrCast(cmd_1)), @as(i32, 0), @as(uint, @bitCast(@as(u32, @truncate(@sizeOf(struct_backcmd))))));
    cmd_1.*.type = 5;
    cmd_1.*.cmd = subcmd;
    return @as([*c]struct_cmd, @ptrCast(@alignCast(cmd_1)));
}
pub export var whitespace: [5:0]u8 = " \t\r\n\x0b".*;
pub export var symbols: [7:0]u8 = "<|>&;()".*;
pub export fn gettoken(arg_ps: [*c][*c]u8, arg_es: [*c]u8, arg_q: [*c][*c]u8, arg_eq: [*c][*c]u8) i32 {
    var ps = arg_ps;
    _ = &ps;
    var es = arg_es;
    _ = &es;
    var q = arg_q;
    _ = &q;
    var eq = arg_eq;
    _ = &eq;
    var s: [*c]u8 = undefined;
    _ = &s;
    var ret: i32 = undefined;
    _ = &ret;
    s = ps.*;
    while ((s < es) and (strchr(@as([*c]u8, @ptrCast(@alignCast(&whitespace[@as(u64, @intCast(0))]))), s.*) != null)) {
        s += 1;
    }
    if (q != null) {
        q.* = s;
    }
    ret = @as(i32, @bitCast(@as(u32, s.*)));
    while (true) {
        switch (@as(i32, @bitCast(@as(u32, s.*)))) {
            @as(i32, 0) => break,
            @as(i32, 124), @as(i32, 40), @as(i32, 41), @as(i32, 59), @as(i32, 38), @as(i32, 60) => {
                s += 1;
                break;
            },
            @as(i32, 62) => {
                s += 1;
                if (@as(i32, @bitCast(@as(u32, s.*))) == @as(i32, '>')) {
                    ret = '+';
                    s += 1;
                }
                break;
            },
            else => {
                ret = 'a';
                while (((s < es) and !(strchr(@as([*c]u8, @ptrCast(@alignCast(&whitespace[@as(u64, @intCast(0))]))), s.*) != null)) and !(strchr(@as([*c]u8, @ptrCast(@alignCast(&symbols[@as(u64, @intCast(0))]))), s.*) != null)) {
                    s += 1;
                }
                break;
            },
        }
        break;
    }
    if (eq != null) {
        eq.* = s;
    }
    while ((s < es) and (strchr(@as([*c]u8, @ptrCast(@alignCast(&whitespace[@as(u64, @intCast(0))]))), s.*) != null)) {
        s += 1;
    }
    ps.* = s;
    return ret;
}
pub export fn peek(arg_ps: [*c][*c]u8, arg_es: [*c]u8, arg_toks: [*c]u8) i32 {
    var ps = arg_ps;
    _ = &ps;
    var es = arg_es;
    _ = &es;
    var toks = arg_toks;
    _ = &toks;
    var s: [*c]u8 = undefined;
    _ = &s;
    s = ps.*;
    while ((s < es) and (strchr(@as([*c]u8, @ptrCast(@alignCast(&whitespace[@as(u64, @intCast(0))]))), s.*) != null)) {
        s += 1;
    }
    ps.* = s;
    return @intFromBool((@as(i32, @bitCast(@as(u32, s.*))) != 0) and (strchr(toks, s.*) != null));
}
pub export fn parseline(arg_ps: [*c][*c]u8, arg_es: [*c]u8) [*c]struct_cmd {
    var ps = arg_ps;
    _ = &ps;
    var es = arg_es;
    _ = &es;
    var cmd_1: [*c]struct_cmd = undefined;
    _ = &cmd_1;
    cmd_1 = parsepipe(ps, es);
    while (peek(ps, es, @as([*c]u8, @ptrCast(@constCast(@volatileCast("&"))))) != 0) {
        _ = gettoken(ps, es, null, null);
        cmd_1 = backcmd(cmd_1);
    }
    if (peek(ps, es, @as([*c]u8, @ptrCast(@constCast(@volatileCast(";"))))) != 0) {
        _ = gettoken(ps, es, null, null);
        cmd_1 = listcmd(cmd_1, parseline(ps, es));
    }
    return cmd_1;
}
pub export fn parsepipe(arg_ps: [*c][*c]u8, arg_es: [*c]u8) [*c]struct_cmd {
    var ps = arg_ps;
    _ = &ps;
    var es = arg_es;
    _ = &es;
    var cmd_1: [*c]struct_cmd = undefined;
    _ = &cmd_1;
    cmd_1 = parseexec(ps, es);
    if (peek(ps, es, @as([*c]u8, @ptrCast(@constCast(@volatileCast("|"))))) != 0) {
        _ = gettoken(ps, es, null, null);
        cmd_1 = pipecmd(cmd_1, parsepipe(ps, es));
    }
    return cmd_1;
}
pub export fn parseexec(arg_ps: [*c][*c]u8, arg_es: [*c]u8) [*c]struct_cmd {
    var ps = arg_ps;
    _ = &ps;
    var es = arg_es;
    _ = &es;
    var q: [*c]u8 = undefined;
    _ = &q;
    var eq: [*c]u8 = undefined;
    _ = &eq;
    var tok: i32 = undefined;
    _ = &tok;
    var argc: i32 = undefined;
    _ = &argc;
    var cmd_1: [*c]struct_execcmd = undefined;
    _ = &cmd_1;
    var ret: [*c]struct_cmd = undefined;
    _ = &ret;
    if (peek(ps, es, @as([*c]u8, @ptrCast(@constCast(@volatileCast("("))))) != 0) return parseblock(ps, es);
    ret = execcmd();
    cmd_1 = @as([*c]struct_execcmd, @ptrCast(@alignCast(ret)));
    argc = 0;
    ret = parseredirs(ret, ps, es);
    while (!(peek(ps, es, @as([*c]u8, @ptrCast(@constCast(@volatileCast("|)&;"))))) != 0)) {
        if ((blk: {
            const tmp = gettoken(ps, es, &q, &eq);
            tok = tmp;
            break :blk tmp;
        }) == @as(i32, 0)) break;
        if (tok != @as(i32, 'a')) {
            panic(@as([*c]u8, @ptrCast(@constCast(@volatileCast("syntax")))));
        }
        cmd_1.*.argv[@as(u32, @intCast(argc))] = q;
        cmd_1.*.eargv[@as(u32, @intCast(argc))] = eq;
        argc += 1;
        if (argc >= @as(i32, 10)) {
            panic(@as([*c]u8, @ptrCast(@constCast(@volatileCast("too many args")))));
        }
        ret = parseredirs(ret, ps, es);
    }
    cmd_1.*.argv[@as(u32, @intCast(argc))] = null;
    cmd_1.*.eargv[@as(u32, @intCast(argc))] = null;
    return ret;
}
pub export fn nulterminate(arg_cmd_1: [*c]struct_cmd) [*c]struct_cmd {
    var cmd_1 = arg_cmd_1;
    _ = &cmd_1;
    var i: i32 = undefined;
    _ = &i;
    var bcmd: [*c]struct_backcmd = undefined;
    _ = &bcmd;
    var ecmd: [*c]struct_execcmd = undefined;
    _ = &ecmd;
    var lcmd: [*c]struct_listcmd = undefined;
    _ = &lcmd;
    var pcmd: [*c]struct_pipecmd = undefined;
    _ = &pcmd;
    var rcmd: [*c]struct_redircmd = undefined;
    _ = &rcmd;
    if (cmd_1 == null) return null;
    while (true) {
        switch (cmd_1.*.type) {
            @as(i32, 1) => {
                ecmd = @as([*c]struct_execcmd, @ptrCast(@alignCast(cmd_1)));
                {
                    i = 0;
                    while (ecmd.*.argv[@as(u32, @intCast(i))] != null) : (i += 1) {
                        ecmd.*.eargv[@as(u32, @intCast(i))].* = 0;
                    }
                }
                break;
            },
            @as(i32, 2) => {
                rcmd = @as([*c]struct_redircmd, @ptrCast(@alignCast(cmd_1)));
                _ = nulterminate(rcmd.*.cmd);
                rcmd.*.efile.* = 0;
                break;
            },
            @as(i32, 3) => {
                pcmd = @as([*c]struct_pipecmd, @ptrCast(@alignCast(cmd_1)));
                _ = nulterminate(pcmd.*.left);
                _ = nulterminate(pcmd.*.right);
                break;
            },
            @as(i32, 4) => {
                lcmd = @as([*c]struct_listcmd, @ptrCast(@alignCast(cmd_1)));
                _ = nulterminate(lcmd.*.left);
                _ = nulterminate(lcmd.*.right);
                break;
            },
            @as(i32, 5) => {
                bcmd = @as([*c]struct_backcmd, @ptrCast(@alignCast(cmd_1)));
                _ = nulterminate(bcmd.*.cmd);
                break;
            },
            else => {},
        }
        break;
    }
    return cmd_1;
}
pub export fn parseredirs(arg_cmd_1: [*c]struct_cmd, arg_ps: [*c][*c]u8, arg_es: [*c]u8) [*c]struct_cmd {
    var cmd_1 = arg_cmd_1;
    _ = &cmd_1;
    var ps = arg_ps;
    _ = &ps;
    var es = arg_es;
    _ = &es;
    var tok: i32 = undefined;
    _ = &tok;
    var q: [*c]u8 = undefined;
    _ = &q;
    var eq: [*c]u8 = undefined;
    _ = &eq;
    while (peek(ps, es, @as([*c]u8, @ptrCast(@constCast(@volatileCast("<>"))))) != 0) {
        tok = gettoken(ps, es, null, null);
        if (gettoken(ps, es, &q, &eq) != @as(i32, 'a')) {
            panic(@as([*c]u8, @ptrCast(@constCast(@volatileCast("missing file for redirection")))));
        }
        while (true) {
            switch (tok) {
                @as(i32, 60) => {
                    cmd_1 = redircmd(cmd_1, q, eq, @as(i32, 0), @as(i32, 0));
                    break;
                },
                @as(i32, 62) => {
                    cmd_1 = redircmd(cmd_1, q, eq, (@as(i32, 1) | @as(i32, 512)) | @as(i32, 1024), @as(i32, 1));
                    break;
                },
                @as(i32, 43) => {
                    cmd_1 = redircmd(cmd_1, q, eq, @as(i32, 1) | @as(i32, 512), @as(i32, 1));
                    break;
                },
                else => {},
            }
            break;
        }
    }
    return cmd_1;
}
pub export fn parseblock(arg_ps: [*c][*c]u8, arg_es: [*c]u8) [*c]struct_cmd {
    var ps = arg_ps;
    _ = &ps;
    var es = arg_es;
    _ = &es;
    var cmd_1: [*c]struct_cmd = undefined;
    _ = &cmd_1;
    if (!(peek(ps, es, @as([*c]u8, @ptrCast(@constCast(@volatileCast("("))))) != 0)) {
        panic(@as([*c]u8, @ptrCast(@constCast(@volatileCast("parseblock")))));
    }
    _ = gettoken(ps, es, null, null);
    cmd_1 = parseline(ps, es);
    if (!(peek(ps, es, @as([*c]u8, @ptrCast(@constCast(@volatileCast(")"))))) != 0)) {
        panic(@as([*c]u8, @ptrCast(@constCast(@volatileCast("syntax - missing )")))));
    }
    _ = gettoken(ps, es, null, null);
    cmd_1 = parseredirs(cmd_1, ps, es);
    return cmd_1;
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
pub const SBRK_ERROR = @import("std").zig.c_translation.cast([*c]u8, -@as(i32, 1));
pub const O_RDONLY = @as(i32, 0x000);
pub const O_WRONLY = @as(i32, 0x001);
pub const O_RDWR = @as(i32, 0x002);
pub const O_CREATE = @as(i32, 0x200);
pub const O_TRUNC = @as(i32, 0x400);
pub const EXEC = @as(i32, 1);
pub const REDIR = @as(i32, 2);
pub const PIPE = @as(i32, 3);
pub const LIST = @as(i32, 4);
pub const BACK = @as(i32, 5);
pub const MAXARGS = @as(i32, 10);
pub const cmd = struct_cmd;
