
const NOFILE: u64 = 16;
const NDEV: i32 = 10;
const MAXARG: u64 = 32;
const MAXPATH: i32 = 128;
const PGSIZE: i32 = 4096;
const DIRSIZ: u64 = 14;

const T_DIR: i16 = 1;
const T_FILE: i16 = 2;
const T_DEVICE: i16 = 3;

const O_RDONLY: i32 = 0x000;
const O_WRONLY: i32 = 0x001;
const O_RDWR: i32 = 0x002;
const O_CREATE: i32 = 0x200;
const O_TRUNC: i32 = 0x400;

const FD_DEVICE: i32 = 3;
const FD_INODE: i32 = 2;

const NDIRECT: u64 = 12;

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

const Inode = extern struct {
    dev: u32,
    inum: u32,
    ref: i32,
    lock: Sleeplock,
    valid: i32,
    type: i16,
    major: i16,
    minor: i16,
    nlink: i16,
    size: u32,
    addrs: [NDIRECT + 1]u32,
};

const File = extern struct {
    type: i32,
    ref: i32,
    readable: u8,
    writable: u8,
    pipe: ?*anyopaque,
    ip: ?*Inode,
    off: u32,
    major: i16,
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
    state: i32,
    chan: ?*anyopaque,
    killed: i32,
    xstate: i32,
    pid: i32,
    parent: ?*Proc,
    kstack: u64,
    sz: u64,
    pagetable: ?*anyopaque,
    trapframe: ?*anyopaque,
    context: Context,
    ofile: [NOFILE]?*File,
    cwd: ?*Inode,
    name: [16]u8,
};

const Dirent = extern struct {
    inum: u16,
    name: [DIRSIZ]u8,
};

extern fn argint(n: i32, ip: *i32) void;
extern fn argaddr(n: i32, ip: *u64) void;
extern fn argstr(n: i32, buf: [*c]u8, max: i32) i32;
extern fn fetchaddr(addr: u64, ip: *u64) i32;
extern fn fetchstr(addr: u64, buf: [*c]u8, max: i32) i32;

extern fn myproc() *Proc;

extern fn filedup(f: *File) *File;
extern fn fileread(f: *File, addr: u64, n: i32) i32;
extern fn filewrite(f: *File, addr: u64, n: i32) i32;
extern fn fileclose(f: *File) void;
extern fn filestat(f: *File, addr: u64) i32;
extern fn filealloc() ?*File;
extern fn pipealloc(f0: *?*File, f1: *?*File) i32;

extern fn begin_op() void;
extern fn end_op() void;
extern fn namei(path: [*c]u8) ?*Inode;
extern fn nameiparent(path: [*c]u8, name: [*c]u8) ?*Inode;
extern fn ilock(ip: *Inode) void;
extern fn iunlock(ip: *Inode) void;
extern fn iunlockput(ip: *Inode) void;
extern fn iput(ip: *Inode) void;
extern fn iupdate(ip: *Inode) void;
extern fn dirlookup(dp: *Inode, name: [*c]u8, poff: ?*u32) ?*Inode;
extern fn dirlink(dp: *Inode, name: [*c]u8, inum: u32) i32;
extern fn readi(ip: *Inode, user_dst: i32, dst: u64, off: u32, n: u32) i32;
extern fn writei(ip: *Inode, user_src: i32, src: u64, off: u32, n: u32) i32;
extern fn ialloc(dev: u32, type_: i16) ?*Inode;
extern fn itrunc(ip: *Inode) void;

extern fn namecmp(s: [*c]u8, t: [*c]const u8) i32;
extern fn panic(s: [*c]const u8) noreturn;
extern fn memset(dst: ?*anyopaque, c: i32, n: u32) ?*anyopaque;

extern fn kalloc() ?*anyopaque;
extern fn kfree(pa: ?*anyopaque) void;
extern fn kexec(path: [*c]u8, argv: [*c][*c]u8) i32;
extern fn copyout(pagetable: ?*anyopaque, dstva: u64, src: [*c]u8, len: u64) i32;

inline fn uerr() u64 {
    return ~@as(u64, 0);
}

fn argfd(n: i32, pfd: ?*i32, pf: ?*?*File) i32 {
    var fd: i32 = 0;
    argint(n, &fd);

    const p = myproc();
    if (fd < 0 or fd >= @as(i32, @intCast(NOFILE)) or p.ofile[@intCast(fd)] == null) {
        return -1;
    }

    if (pfd) |out_fd| {
        out_fd.* = fd;
    }
    if (pf) |out_f| {
        out_f.* = p.ofile[@intCast(fd)];
    }
    return 0;
}

fn fdalloc(f: *File) i32 {
    const p = myproc();
    var fd: u64 = 0;
    while (fd < NOFILE) : (fd += 1) {
        if (p.ofile[fd] == null) {
            p.ofile[fd] = f;
            return @intCast(fd);
        }
    }
    return -1;
}

pub export fn sys_dup() u64 {
    var f: ?*File = null;
    if (argfd(0, null, &f) < 0) {
        return uerr();
    }
    const fd = fdalloc(f.?);
    if (fd < 0) {
        return uerr();
    }
    _ = filedup(f.?);
    return @intCast(@as(u32, @intCast(fd)));
}

pub export fn sys_read() u64 {
    var f: ?*File = null;
    var n: i32 = 0;
    var p: u64 = 0;

    argaddr(1, &p);
    argint(2, &n);
    if (argfd(0, null, &f) < 0) {
        return uerr();
    }
    return @intCast(fileread(f.?, p, n));
}

pub export fn sys_write() u64 {
    var f: ?*File = null;
    var n: i32 = 0;
    var p: u64 = 0;

    argaddr(1, &p);
    argint(2, &n);
    if (argfd(0, null, &f) < 0) {
        return uerr();
    }
    return @intCast(filewrite(f.?, p, n));
}

pub export fn sys_close() u64 {
    var fd: i32 = 0;
    var f: ?*File = null;

    if (argfd(0, &fd, &f) < 0) {
        return uerr();
    }
    myproc().ofile[@intCast(fd)] = null;
    fileclose(f.?);
    return 0;
}

pub export fn sys_fstat() u64 {
    var f: ?*File = null;
    var st: u64 = 0;

    argaddr(1, &st);
    if (argfd(0, null, &f) < 0) {
        return uerr();
    }
    return @intCast(filestat(f.?, st));
}

pub export fn sys_link() u64 {
    var name: [DIRSIZ]u8 = undefined;
    var new: [@as(u64, @intCast(MAXPATH))]u8 = undefined;
    var old: [@as(u64, @intCast(MAXPATH))]u8 = undefined;
    var dp: ?*Inode = null;
    var ip: ?*Inode = null;

    if (argstr(0, @ptrCast(&old), MAXPATH) < 0 or argstr(1, @ptrCast(&new), MAXPATH) < 0) {
        return uerr();
    }

    begin_op();
    ip = namei(@ptrCast(&old));
    if (ip == null) {
        end_op();
        return uerr();
    }

    ilock(ip.?);
    if (ip.?.type == T_DIR) {
        iunlockput(ip.?);
        end_op();
        return uerr();
    }

    ip.?.nlink += 1;
    iupdate(ip.?);
    iunlock(ip.?);

    dp = nameiparent(@ptrCast(&new), @ptrCast(&name));
    if (dp == null) {
        ilock(ip.?);
        ip.?.nlink -= 1;
        iupdate(ip.?);
        iunlockput(ip.?);
        end_op();
        return uerr();
    }

    ilock(dp.?);
    if (dp.?.dev != ip.?.dev or dirlink(dp.?, @ptrCast(&name), ip.?.inum) < 0) {
        iunlockput(dp.?);
        ilock(ip.?);
        ip.?.nlink -= 1;
        iupdate(ip.?);
        iunlockput(ip.?);
        end_op();
        return uerr();
    }
    iunlockput(dp.?);
    iput(ip.?);
    end_op();
    return 0;
}

fn isdirempty(dp: *Inode) i32 {
    var off: u32 = @intCast(2 * @sizeOf(Dirent));
    var de: Dirent = undefined;
    while (off < dp.size) : (off +%= @intCast(@sizeOf(Dirent))) {
        if (readi(dp, 0, @intFromPtr(&de), off, @intCast(@sizeOf(Dirent))) != @as(i32, @intCast(@sizeOf(Dirent)))) {
            panic("isdirempty: readi");
        }
        if (de.inum != 0) {
            return 0;
        }
    }
    return 1;
}

pub export fn sys_unlink() u64 {
    var ip: ?*Inode = null;
    var dp: ?*Inode = null;
    var de: Dirent = undefined;
    var name: [DIRSIZ]u8 = undefined;
    var path: [@as(u64, @intCast(MAXPATH))]u8 = undefined;
    var off: u32 = 0;

    if (argstr(0, @ptrCast(&path), MAXPATH) < 0) {
        return uerr();
    }

    begin_op();
    dp = nameiparent(@ptrCast(&path), @ptrCast(&name));
    if (dp == null) {
        end_op();
        return uerr();
    }

    ilock(dp.?);

    if (namecmp(@ptrCast(&name), ".") == 0 or namecmp(@ptrCast(&name), "..") == 0) {
        iunlockput(dp.?);
        end_op();
        return uerr();
    }

    ip = dirlookup(dp.?, @ptrCast(&name), &off);
    if (ip == null) {
        iunlockput(dp.?);
        end_op();
        return uerr();
    }
    ilock(ip.?);

    if (ip.?.nlink < 1) {
        panic("unlink: nlink < 1");
    }
    if (ip.?.type == T_DIR and isdirempty(ip.?) == 0) {
        iunlockput(ip.?);
        iunlockput(dp.?);
        end_op();
        return uerr();
    }

    _ = memset(&de, 0, @intCast(@sizeOf(Dirent)));
    if (writei(dp.?, 0, @intFromPtr(&de), off, @intCast(@sizeOf(Dirent))) != @as(i32, @intCast(@sizeOf(Dirent)))) {
        panic("unlink: writei");
    }
    if (ip.?.type == T_DIR) {
        dp.?.nlink -= 1;
        iupdate(dp.?);
    }
    iunlockput(dp.?);

    ip.?.nlink -= 1;
    iupdate(ip.?);
    iunlockput(ip.?);
    end_op();
    return 0;
}

fn create(path: [*c]u8, type_: i16, major: i16, minor: i16) ?*Inode {
    var name: [DIRSIZ]u8 = undefined;
    var dp = nameiparent(path, @ptrCast(&name));
    if (dp == null) {
        return null;
    }

    ilock(dp.?);

    var ip = dirlookup(dp.?, @ptrCast(&name), null);
    if (ip != null) {
        iunlockput(dp.?);
        ilock(ip.?);
        if (type_ == T_FILE and (ip.?.type == T_FILE or ip.?.type == T_DEVICE)) {
            return ip;
        }
        iunlockput(ip.?);
        return null;
    }

    ip = ialloc(dp.?.dev, type_);
    if (ip == null) {
        iunlockput(dp.?);
        return null;
    }

    ilock(ip.?);
    ip.?.major = major;
    ip.?.minor = minor;
    ip.?.nlink = 1;
    iupdate(ip.?);

    if (type_ == T_DIR) {
        if (dirlink(ip.?, @constCast("."), ip.?.inum) < 0 or dirlink(ip.?, @constCast(".."), dp.?.inum) < 0) {
            ip.?.nlink = 0;
            iupdate(ip.?);
            iunlockput(ip.?);
            iunlockput(dp.?);
            return null;
        }
    }

    if (dirlink(dp.?, @ptrCast(&name), ip.?.inum) < 0) {
        ip.?.nlink = 0;
        iupdate(ip.?);
        iunlockput(ip.?);
        iunlockput(dp.?);
        return null;
    }

    if (type_ == T_DIR) {
        dp.?.nlink += 1;
        iupdate(dp.?);
    }

    iunlockput(dp.?);
    return ip;
}

pub export fn sys_open() u64 {
    var path: [@as(u64, @intCast(MAXPATH))]u8 = undefined;
    var omode: i32 = 0;
    var f: ?*File = null;
    var ip: ?*Inode = null;

    argint(1, &omode);
    if (argstr(0, @ptrCast(&path), MAXPATH) < 0) {
        return uerr();
    }

    begin_op();

    if ((omode & O_CREATE) != 0) {
        ip = create(@ptrCast(&path), T_FILE, 0, 0);
        if (ip == null) {
            end_op();
            return uerr();
        }
    } else {
        ip = namei(@ptrCast(&path));
        if (ip == null) {
            end_op();
            return uerr();
        }
        ilock(ip.?);
        if (ip.?.type == T_DIR and omode != O_RDONLY) {
            iunlockput(ip.?);
            end_op();
            return uerr();
        }
    }

    if (ip.?.type == T_DEVICE and (ip.?.major < 0 or ip.?.major >= NDEV)) {
        iunlockput(ip.?);
        end_op();
        return uerr();
    }

    f = filealloc();
    const fd = if (f != null) fdalloc(f.?) else -1;
    if (f == null or fd < 0) {
        if (f != null) {
            fileclose(f.?);
        }
        iunlockput(ip.?);
        end_op();
        return uerr();
    }

    if (ip.?.type == T_DEVICE) {
        f.?.type = FD_DEVICE;
        f.?.major = ip.?.major;
    } else {
        f.?.type = FD_INODE;
        f.?.off = 0;
    }
    f.?.ip = ip;
    f.?.readable = if ((omode & O_WRONLY) == 0) 1 else 0;
    f.?.writable = if (((omode & O_WRONLY) != 0) or ((omode & O_RDWR) != 0)) 1 else 0;

    if (((omode & O_TRUNC) != 0) and ip.?.type == T_FILE) {
        itrunc(ip.?);
    }

    iunlock(ip.?);
    end_op();
    return @intCast(@as(u32, @intCast(fd)));
}

pub export fn sys_mkdir() u64 {
    var path: [@as(u64, @intCast(MAXPATH))]u8 = undefined;
    var ip: ?*Inode = null;

    begin_op();
    if (argstr(0, @ptrCast(&path), MAXPATH) < 0) {
        end_op();
        return uerr();
    }
    ip = create(@ptrCast(&path), T_DIR, 0, 0);
    if (ip == null) {
        end_op();
        return uerr();
    }
    iunlockput(ip.?);
    end_op();
    return 0;
}

pub export fn sys_mknod() u64 {
    var path: [@as(u64, @intCast(MAXPATH))]u8 = undefined;
    var major: i32 = 0;
    var minor: i32 = 0;

    begin_op();
    argint(1, &major);
    argint(2, &minor);
    const ip = if (argstr(0, @ptrCast(&path), MAXPATH) < 0) null else create(@ptrCast(&path), T_DEVICE, @intCast(major), @intCast(minor));
    if (ip == null) {
        end_op();
        return uerr();
    }
    iunlockput(ip.?);
    end_op();
    return 0;
}

pub export fn sys_chdir() u64 {
    var path: [@as(u64, @intCast(MAXPATH))]u8 = undefined;
    const p = myproc();

    begin_op();
    const ip = if (argstr(0, @ptrCast(&path), MAXPATH) < 0) null else namei(@ptrCast(&path));
    if (ip == null) {
        end_op();
        return uerr();
    }
    ilock(ip.?);
    if (ip.?.type != T_DIR) {
        iunlockput(ip.?);
        end_op();
        return uerr();
    }
    iunlock(ip.?);
    iput(p.cwd.?);
    end_op();
    p.cwd = ip;
    return 0;
}

pub export fn sys_exec() u64 {
    var path: [@as(u64, @intCast(MAXPATH))]u8 = undefined;
    var argv: [MAXARG][*c]u8 = undefined;
    var uargv: u64 = 0;
    var uarg: u64 = 0;

    argaddr(1, &uargv);
    if (argstr(0, @ptrCast(&path), MAXPATH) < 0) {
        return uerr();
    }

    _ = memset(@ptrCast(&argv), 0, @intCast(@sizeOf(@TypeOf(argv))));

    var i: u64 = 0;
    while (true) : (i += 1) {
        if (i >= argv.len) {
            var j: u64 = 0;
            while (j < argv.len and argv[j] != null) : (j += 1) {
                kfree(argv[j]);
            }
            return uerr();
        }

        if (fetchaddr(uargv + @as(u64, @intCast(@sizeOf(u64) * i)), &uarg) < 0) {
            var j: u64 = 0;
            while (j < argv.len and argv[j] != null) : (j += 1) {
                kfree(argv[j]);
            }
            return uerr();
        }

        if (uarg == 0) {
            argv[i] = null;
            break;
        }

        const mem = kalloc();
        if (mem == null) {
            var j: u64 = 0;
            while (j < argv.len and argv[j] != null) : (j += 1) {
                kfree(argv[j]);
            }
            return uerr();
        }

        argv[i] = @ptrCast(mem.?);
        if (fetchstr(uarg, argv[i], PGSIZE) < 0) {
            var j: u64 = 0;
            while (j < argv.len and argv[j] != null) : (j += 1) {
                kfree(argv[j]);
            }
            return uerr();
        }
    }

    const ret = kexec(@ptrCast(&path), @ptrCast(&argv));

    i = 0;
    while (i < argv.len and argv[i] != null) : (i += 1) {
        kfree(argv[i]);
    }

    return @intCast(ret);
}

pub export fn sys_pipe() u64 {
    var fdarray: u64 = 0;
    var rf: ?*File = null;
    var wf: ?*File = null;
    var fd0: i32 = -1;
    var fd1: i32 = -1;
    const p = myproc();

    argaddr(0, &fdarray);
    if (pipealloc(&rf, &wf) < 0) {
        return uerr();
    }

    fd0 = fdalloc(rf.?);
    if (fd0 >= 0) {
        fd1 = fdalloc(wf.?);
    }
    if (fd0 < 0 or fd1 < 0) {
        if (fd0 >= 0) {
            p.ofile[@intCast(fd0)] = null;
        }
        fileclose(rf.?);
        fileclose(wf.?);
        return uerr();
    }

    if (copyout(p.pagetable, fdarray, @ptrCast(&fd0), @sizeOf(i32)) < 0 or
        copyout(p.pagetable, fdarray + @as(u64, @intCast(@sizeOf(i32))), @ptrCast(&fd1), @sizeOf(i32)) < 0)
    {
        p.ofile[@intCast(fd0)] = null;
        p.ofile[@intCast(fd1)] = null;
        fileclose(rf.?);
        fileclose(wf.?);
        return uerr();
    }

    return 0;
}
