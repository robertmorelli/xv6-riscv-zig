pub const O_RDONLY: i32 = 0x000;
pub const O_WRONLY: i32 = 0x001;
pub const O_RDWR: i32 = 0x002;
pub const O_CREATE: i32 = 0x200;
pub const O_TRUNC: i32 = 0x400;

pub const T_DIR: i16 = 1;
pub const T_FILE: i16 = 2;
pub const T_DEVICE: i16 = 3;
pub const CONSOLE: i16 = 1;
pub const SBRK_EAGER: i32 = 1;
pub const SBRK_LAZY: i32 = 2;

pub const DIRSIZ: u64 = 14;

pub const Stat = extern struct {
    dev: i32,
    ino: u32,
    type: i16,
    nlink: i16,
    size: u64,
};

pub const Dirent = extern struct {
    inum: u16,
    name: [DIRSIZ]u8,
};

pub extern fn fork() i32;
pub extern fn exit(status: i32) noreturn;
pub extern fn wait(status: ?*i32) i32;
pub extern fn write(fd: i32, buf: [*]const u8, n: i32) i32;
pub extern fn read(fd: i32, buf: [*]u8, n: i32) i32;
pub extern fn close(fd: i32) i32;
pub extern fn kill(pid: i32) i32;
pub extern fn exec(path: [*:0]const u8, argv: [*]const ?[*:0]const u8) i32;
pub extern fn open(path: [*:0]const u8, mode: i32) i32;
pub extern fn mknod(path: [*:0]const u8, major: i16, minor: i16) i32;
pub extern fn unlink(path: [*:0]const u8) i32;
pub extern fn fstat(fd: i32, st: *Stat) i32;
pub extern fn link(old: [*:0]const u8, new: [*:0]const u8) i32;
pub extern fn mkdir(path: [*:0]const u8) i32;
pub extern fn chdir(path: [*:0]const u8) i32;
pub extern fn dup(fd: i32) i32;
pub extern fn sys_sbrk(n: i32, mode: i32) [*]u8;
pub extern fn pause(ticks: i32) i32;
pub extern fn stat(path: [*:0]const u8, st: *Stat) i32;
pub extern fn strcpy(dst: [*]u8, src: [*:0]const u8) [*:0]u8;
pub extern fn memmove(dst: [*]u8, src: [*]const u8, n: i32) ?*anyopaque;
pub extern fn strchr(s: [*:0]const u8, c: u8) ?[*:0]u8;
pub extern fn strlen(s: [*:0]const u8) u32;
pub extern fn memset(dst: [*]u8, c: i32, n: u32) ?*anyopaque;
pub extern fn atoi(s: [*:0]const u8) i32;
pub extern fn fprintf(fd: i32, fmt: [*:0]const u8, ...) void;
pub extern fn printf(fmt: [*:0]const u8, ...) void;
pub extern fn sbrk(n: i32) [*]u8;
pub extern fn sbrklazy(n: i32) [*]u8;

pub fn strlen_i32(s: [*:0]const u8) i32 {
    return @intCast(strlen(s));
}
