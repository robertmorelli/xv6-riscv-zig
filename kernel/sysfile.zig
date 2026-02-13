const cint = i32;
const cuint = u32;

const NOFILE: usize = 16;
const NDEV: cint = 10;
const MAXARG: usize = 32;
const MAXPATH: cint = 128;
const PGSIZE: cint = 4096;
const DIRSIZ: usize = 14;

const T_DIR: i16 = 1;
const T_FILE: i16 = 2;
const T_DEVICE: i16 = 3;

const O_RDONLY: cint = 0x000;
const O_WRONLY: cint = 0x001;
const O_RDWR: cint = 0x002;
const O_CREATE: cint = 0x200;
const O_TRUNC: cint = 0x400;

const FD_DEVICE: cint = 3;
const FD_INODE: cint = 2;

const NDIRECT: usize = 12;

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

const File = extern struct {
    type: cint,
    ref: cint,
    readable: u8,
    writable: u8,
    pipe: ?*anyopaque,
    ip: ?*Inode,
    off: cuint,
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
    ofile: [NOFILE]?*File,
    cwd: ?*Inode,
    name: [16]u8,
};

const Dirent = extern struct {
    inum: u16,
    name: [DIRSIZ]u8,
};

extern fn argint(n: cint, ip: *cint) callconv(.c) void;
extern fn argaddr(n: cint, ip: *u64) callconv(.c) void;
extern fn argstr(n: cint, buf: [*c]u8, max: cint) callconv(.c) cint;
extern fn fetchaddr(addr: u64, ip: *u64) callconv(.c) cint;
extern fn fetchstr(addr: u64, buf: [*c]u8, max: cint) callconv(.c) cint;

extern fn myproc() callconv(.c) *Proc;

extern fn filedup(f: *File) callconv(.c) *File;
extern fn fileread(f: *File, addr: u64, n: cint) callconv(.c) cint;
extern fn filewrite(f: *File, addr: u64, n: cint) callconv(.c) cint;
extern fn fileclose(f: *File) callconv(.c) void;
extern fn filestat(f: *File, addr: u64) callconv(.c) cint;
extern fn filealloc() callconv(.c) ?*File;
extern fn pipealloc(f0: *?*File, f1: *?*File) callconv(.c) cint;

extern fn begin_op() callconv(.c) void;
extern fn end_op() callconv(.c) void;
extern fn namei(path: [*c]u8) callconv(.c) ?*Inode;
extern fn nameiparent(path: [*c]u8, name: [*c]u8) callconv(.c) ?*Inode;
extern fn ilock(ip: *Inode) callconv(.c) void;
extern fn iunlock(ip: *Inode) callconv(.c) void;
extern fn iunlockput(ip: *Inode) callconv(.c) void;
extern fn iput(ip: *Inode) callconv(.c) void;
extern fn iupdate(ip: *Inode) callconv(.c) void;
extern fn dirlookup(dp: *Inode, name: [*c]u8, poff: ?*cuint) callconv(.c) ?*Inode;
extern fn dirlink(dp: *Inode, name: [*c]u8, inum: cuint) callconv(.c) cint;
extern fn readi(ip: *Inode, user_dst: cint, dst: u64, off: cuint, n: cuint) callconv(.c) cint;
extern fn writei(ip: *Inode, user_src: cint, src: u64, off: cuint, n: cuint) callconv(.c) cint;
extern fn ialloc(dev: cuint, type_: i16) callconv(.c) ?*Inode;
extern fn itrunc(ip: *Inode) callconv(.c) void;

extern fn namecmp(s: [*c]u8, t: [*c]const u8) callconv(.c) cint;
extern fn panic(s: [*c]const u8) callconv(.c) noreturn;
extern fn memset(dst: ?*anyopaque, c: cint, n: cuint) callconv(.c) ?*anyopaque;

extern fn kalloc() callconv(.c) ?*anyopaque;
extern fn kfree(pa: ?*anyopaque) callconv(.c) void;
extern fn kexec(path: [*c]u8, argv: [*c][*c]u8) callconv(.c) cint;
extern fn copyout(pagetable: ?*anyopaque, dstva: u64, src: [*c]u8, len: u64) callconv(.c) cint;

inline fn uerr() u64 {
    return ~@as(u64, 0);
}

fn argfd(n: cint, pfd: ?*cint, pf: ?*?*File) cint {
    var fd: cint = 0;
    argint(n, &fd);

    const p = myproc();
    if (fd < 0 or fd >= @as(cint, @intCast(NOFILE)) or p.ofile[@intCast(fd)] == null) {
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

fn fdalloc(f: *File) cint {
    const p = myproc();
    var fd: usize = 0;
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
    return @intCast(@as(cuint, @intCast(fd)));
}

pub export fn sys_read() u64 {
    var f: ?*File = null;
    var n: cint = 0;
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
    var n: cint = 0;
    var p: u64 = 0;

    argaddr(1, &p);
    argint(2, &n);
    if (argfd(0, null, &f) < 0) {
        return uerr();
    }
    return @intCast(filewrite(f.?, p, n));
}

pub export fn sys_close() u64 {
    var fd: cint = 0;
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
    var new: [@as(usize, @intCast(MAXPATH))]u8 = undefined;
    var old: [@as(usize, @intCast(MAXPATH))]u8 = undefined;
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

fn isdirempty(dp: *Inode) cint {
    var off: cuint = @intCast(2 * @sizeOf(Dirent));
    var de: Dirent = undefined;
    while (off < dp.size) : (off +%= @intCast(@sizeOf(Dirent))) {
        if (readi(dp, 0, @intFromPtr(&de), off, @intCast(@sizeOf(Dirent))) != @as(cint, @intCast(@sizeOf(Dirent)))) {
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
    var path: [@as(usize, @intCast(MAXPATH))]u8 = undefined;
    var off: cuint = 0;

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
    if (writei(dp.?, 0, @intFromPtr(&de), off, @intCast(@sizeOf(Dirent))) != @as(cint, @intCast(@sizeOf(Dirent)))) {
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
    var path: [@as(usize, @intCast(MAXPATH))]u8 = undefined;
    var omode: cint = 0;
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
    return @intCast(@as(cuint, @intCast(fd)));
}

pub export fn sys_mkdir() u64 {
    var path: [@as(usize, @intCast(MAXPATH))]u8 = undefined;
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
    var path: [@as(usize, @intCast(MAXPATH))]u8 = undefined;
    var major: cint = 0;
    var minor: cint = 0;

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
    var path: [@as(usize, @intCast(MAXPATH))]u8 = undefined;
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
    var path: [@as(usize, @intCast(MAXPATH))]u8 = undefined;
    var argv: [MAXARG][*c]u8 = undefined;
    var uargv: u64 = 0;
    var uarg: u64 = 0;

    argaddr(1, &uargv);
    if (argstr(0, @ptrCast(&path), MAXPATH) < 0) {
        return uerr();
    }

    _ = memset(@ptrCast(&argv), 0, @intCast(@sizeOf(@TypeOf(argv))));

    var i: usize = 0;
    while (true) : (i += 1) {
        if (i >= argv.len) {
            var j: usize = 0;
            while (j < argv.len and argv[j] != null) : (j += 1) {
                kfree(argv[j]);
            }
            return uerr();
        }

        if (fetchaddr(uargv + @as(u64, @intCast(@sizeOf(u64) * i)), &uarg) < 0) {
            var j: usize = 0;
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
            var j: usize = 0;
            while (j < argv.len and argv[j] != null) : (j += 1) {
                kfree(argv[j]);
            }
            return uerr();
        }

        argv[i] = @ptrCast(mem.?);
        if (fetchstr(uarg, argv[i], PGSIZE) < 0) {
            var j: usize = 0;
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
    var fd0: cint = -1;
    var fd1: cint = -1;
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

    if (copyout(p.pagetable, fdarray, @ptrCast(&fd0), @sizeOf(cint)) < 0 or
        copyout(p.pagetable, fdarray + @as(u64, @intCast(@sizeOf(cint))), @ptrCast(&fd1), @sizeOf(cint)) < 0)
    {
        p.ofile[@intCast(fd0)] = null;
        p.ofile[@intCast(fd1)] = null;
        fileclose(rf.?);
        fileclose(wf.?);
        return uerr();
    }

    return 0;
}
