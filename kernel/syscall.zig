const nums = @import("syscall_numbers.zig");

const NOFILE: u64 = 16;

const SYS_fork: u64 = nums.SYS_fork;
const SYS_exit: u64 = nums.SYS_exit;
const SYS_wait: u64 = nums.SYS_wait;
const SYS_pipe: u64 = nums.SYS_pipe;
const SYS_read: u64 = nums.SYS_read;
const SYS_kill: u64 = nums.SYS_kill;
const SYS_exec: u64 = nums.SYS_exec;
const SYS_fstat: u64 = nums.SYS_fstat;
const SYS_chdir: u64 = nums.SYS_chdir;
const SYS_dup: u64 = nums.SYS_dup;
const SYS_getpid: u64 = nums.SYS_getpid;
const SYS_sbrk: u64 = nums.SYS_sbrk;
const SYS_pause: u64 = nums.SYS_pause;
const SYS_uptime: u64 = nums.SYS_uptime;
const SYS_open: u64 = nums.SYS_open;
const SYS_write: u64 = nums.SYS_write;
const SYS_mknod: u64 = nums.SYS_mknod;
const SYS_unlink: u64 = nums.SYS_unlink;
const SYS_link: u64 = nums.SYS_link;
const SYS_mkdir: u64 = nums.SYS_mkdir;
const SYS_close: u64 = nums.SYS_close;

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

const Trapframe = extern struct {
    kernel_satp: u64,
    kernel_sp: u64,
    kernel_trap: u64,
    epc: u64,
    kernel_hartid: u64,
    ra: u64,
    sp: u64,
    gp: u64,
    tp: u64,
    t0: u64,
    t1: u64,
    t2: u64,
    s0: u64,
    s1: u64,
    a0: u64,
    a1: u64,
    a2: u64,
    a3: u64,
    a4: u64,
    a5: u64,
    a6: u64,
    a7: u64,
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
    t3: u64,
    t4: u64,
    t5: u64,
    t6: u64,
};

const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*anyopaque,
};

const Proc = extern struct {
    lock: Spinlock,
    state: i32,
    chan: ?*anyopaque,
    killed: i32,
    xstate: i32,
    pid: i32,
    parent: ?*Proc,
    kstack: u64,
    sz: u64,
    pagetable: ?*anyopaque,
    trapframe: ?*Trapframe,
    context: Context,
    ofile: [NOFILE]?*anyopaque,
    cwd: ?*anyopaque,
    name: [16]u8,
};

extern fn myproc() *Proc;
extern fn copyin(pagetable: ?*anyopaque, dst: [*c]u8, srcva: u64, len: u64) i32;
extern fn copyinstr(pagetable: ?*anyopaque, dst: [*c]u8, srcva: u64, len: u64) i32;
extern fn strlen(s: [*c]const u8) i32;
extern fn panic(s: [*c]const u8) noreturn;
extern fn printf(fmt: [*c]const u8, ...) i32;

extern fn sys_fork() u64;
extern fn sys_exit() u64;
extern fn sys_wait() u64;
extern fn sys_pipe() u64;
extern fn sys_read() u64;
extern fn sys_kill() u64;
extern fn sys_exec() u64;
extern fn sys_fstat() u64;
extern fn sys_chdir() u64;
extern fn sys_dup() u64;
extern fn sys_getpid() u64;
extern fn sys_sbrk() u64;
extern fn sys_pause() u64;
extern fn sys_uptime() u64;
extern fn sys_open() u64;
extern fn sys_write() u64;
extern fn sys_mknod() u64;
extern fn sys_unlink() u64;
extern fn sys_link() u64;
extern fn sys_mkdir() u64;
extern fn sys_close() u64;

const SysFn = *const fn() callconv(.c) u64;
const syscalls = blk: {
    var t: [22]?SysFn = [_]?SysFn{null} ** 22;
    t[SYS_fork] = &sys_fork;
    t[SYS_exit] = &sys_exit;
    t[SYS_wait] = &sys_wait;
    t[SYS_pipe] = &sys_pipe;
    t[SYS_read] = &sys_read;
    t[SYS_kill] = &sys_kill;
    t[SYS_exec] = &sys_exec;
    t[SYS_fstat] = &sys_fstat;
    t[SYS_chdir] = &sys_chdir;
    t[SYS_dup] = &sys_dup;
    t[SYS_getpid] = &sys_getpid;
    t[SYS_sbrk] = &sys_sbrk;
    t[SYS_pause] = &sys_pause;
    t[SYS_uptime] = &sys_uptime;
    t[SYS_open] = &sys_open;
    t[SYS_write] = &sys_write;
    t[SYS_mknod] = &sys_mknod;
    t[SYS_unlink] = &sys_unlink;
    t[SYS_link] = &sys_link;
    t[SYS_mkdir] = &sys_mkdir;
    t[SYS_close] = &sys_close;
    break :blk t;
};

pub export fn fetchaddr(addr: u64, ip: *u64) i32 {
    const p = myproc();
    if (addr >= p.sz or addr + @sizeOf(u64) > p.sz) {
        return -1;
    }
    if (copyin(p.pagetable, @ptrCast(ip), addr, @sizeOf(u64)) != 0) {
        return -1;
    }
    return 0;
}

pub export fn fetchstr(addr: u64, buf: [*c]u8, max: i32) i32 {
    const p = myproc();
    if (copyinstr(p.pagetable, buf, addr, @intCast(@as(u32, @intCast(max)))) < 0) {
        return -1;
    }
    return strlen(buf);
}

fn argraw(n: i32) u64 {
    const tf = myproc().trapframe.?;
    return switch (n) {
        0 => tf.a0,
        1 => tf.a1,
        2 => tf.a2,
        3 => tf.a3,
        4 => tf.a4,
        5 => tf.a5,
        else => {
            panic("argraw");
        },
    };
}

pub export fn argint(n: i32, ip: *i32) void {
    ip.* = @intCast(argraw(n));
}

pub export fn argaddr(n: i32, ip: *u64) void {
    ip.* = argraw(n);
}

pub export fn argstr(n: i32, buf: [*c]u8, max: i32) i32 {
    var addr: u64 = 0;
    argaddr(n, &addr);
    return fetchstr(addr, buf, max);
}

pub export fn syscall() void {
    const p = myproc();
    const tf = p.trapframe.?;
    const num: u64 = @intCast(tf.a7);

    if (num > 0 and num < syscalls.len and syscalls[num] != null) {
        tf.a0 = syscalls[num].?();
    } else {
        _ = printf(
            "%d %s: unknown sys call %d\n",
            p.pid,
            @as([*c]u8, @ptrCast(&p.name)),
            @as(i32, @intCast(tf.a7)),
        );
        tf.a0 = ~@as(u64, 0);
    }
}
