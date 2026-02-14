const cushort = u16;

const MAXARG: u64 = 32;
const USERSTACK: u64 = 1;
const PGSIZE: u64 = 4096;
const PTE_W: i32 = 1 << 2;
const PTE_X: i32 = 1 << 3;
const ELF_MAGIC: u32 = 0x464C457F;
const ELF_PROG_LOAD: u32 = 1;

const Spinlock = extern struct {
    locked: u32,
    name: [*c]u8,
    cpu: ?*anyopaque,
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
    pagetable: [*c]u64,
    trapframe: ?*Trapframe,
    context: Context,
    ofile: [16]?*anyopaque,
    cwd: ?*anyopaque,
    name: [16]u8,
};

const Elfhdr = extern struct {
    magic: u32,
    elf: [12]u8,
    type: cushort,
    machine: cushort,
    version: u32,
    entry: u64,
    phoff: u64,
    shoff: u64,
    flags: u32,
    ehsize: cushort,
    phentsize: cushort,
    phnum: cushort,
    shentsize: cushort,
    shnum: cushort,
    shstrndx: cushort,
};

const Proghdr = extern struct {
    type: u32,
    flags: u32,
    off: u64,
    vaddr: u64,
    paddr: u64,
    filesz: u64,
    memsz: u64,
    @"align": u64,
};

inline fn pgroundup(sz: u64) u64 {
    return (sz + PGSIZE - 1) & ~(PGSIZE - 1);
}

extern fn begin_op() void;
extern fn end_op() void;
extern fn namei(path: [*c]u8) ?*anyopaque;
extern fn ilock(ip: ?*anyopaque) void;
extern fn readi(ip: ?*anyopaque, user_dst: i32, dst: u64, off: u32, n: u32) i32;
extern fn iunlockput(ip: ?*anyopaque) void;
extern fn proc_pagetable(p: *Proc) [*c]u64;
extern fn uvmalloc(pagetable: [*c]u64, oldsz: u64, newsz: u64, xperm: i32) u64;
extern fn uvmclear(pagetable: [*c]u64, va: u64) void;
extern fn copyout(pagetable: [*c]u64, dstva: u64, src: [*c]u8, len: u64) i32;
extern fn strlen(s: [*c]u8) i32;
extern fn safestrcpy(dst: [*c]u8, src: [*c]u8, n: i32) [*c]u8;
extern fn proc_freepagetable(pagetable: [*c]u64, sz: u64) void;
extern fn walkaddr(pagetable: [*c]u64, va: u64) u64;
extern fn panic(s: [*c]const u8) noreturn;
extern fn myproc() *Proc;

pub export fn flags2perm(flags: i32) i32 {
    var perm: i32 = 0;
    if ((flags & 0x1) != 0) {
        perm = PTE_X;
    }
    if ((flags & 0x2) != 0) {
        perm |= PTE_W;
    }
    return perm;
}

fn loadseg(pagetable: [*c]u64, va: u64, ip: ?*anyopaque, offset: u32, sz: u32) i32 {
    var i: u32 = 0;
    while (i < sz) : (i += @intCast(PGSIZE)) {
        const pa = walkaddr(pagetable, va + i);
        if (pa == 0) {
            panic("loadseg: address should exist");
        }
        const n: u32 = if (sz - i < PGSIZE) sz - i else @intCast(PGSIZE);
        if (readi(ip, 0, pa, offset + i, n) != @as(i32, @intCast(n))) {
            return -1;
        }
    }
    return 0;
}

pub export fn kexec(path: [*c]u8, argv: [*c][*c]u8) i32 {
    var i: i32 = 0;
    var off: u32 = 0;
    var argc: u64 = 0;
    var sz: u64 = 0;
    var sp: u64 = 0;
    var stackbase: u64 = 0;
    var ustack: [MAXARG]u64 = undefined;
    var elf: Elfhdr = undefined;
    var ph: Proghdr = undefined;

    var ip: ?*anyopaque = null;
    var pagetable: [*c]u64 = @ptrFromInt(0);
    var oldpagetable: [*c]u64 = @ptrFromInt(0);

    var p = myproc();

    begin_op();

    ip = namei(path);
    if (ip == null) {
        end_op();
        return -1;
    }
    ilock(ip);

    if (readi(ip, 0, @intFromPtr(&elf), 0, @sizeOf(Elfhdr)) != @as(i32, @intCast(@sizeOf(Elfhdr)))) {
        gotoBad(&pagetable, &ip, sz);
        return -1;
    }

    if (elf.magic != ELF_MAGIC) {
        gotoBad(&pagetable, &ip, sz);
        return -1;
    }

    pagetable = proc_pagetable(p);
    if (pagetable == @as([*c]u64, @ptrFromInt(0))) {
        gotoBad(&pagetable, &ip, sz);
        return -1;
    }

    i = 0;
    off = @intCast(elf.phoff);
    while (i < @as(i32, @intCast(elf.phnum))) : ({
        i += 1;
        off +%= @intCast(@sizeOf(Proghdr));
    }) {
        if (readi(ip, 0, @intFromPtr(&ph), off, @sizeOf(Proghdr)) != @as(i32, @intCast(@sizeOf(Proghdr)))) {
            gotoBad(&pagetable, &ip, sz);
            return -1;
        }
        if (ph.type != ELF_PROG_LOAD) {
            continue;
        }
        if (ph.memsz < ph.filesz) {
            gotoBad(&pagetable, &ip, sz);
            return -1;
        }
        if (ph.vaddr + ph.memsz < ph.vaddr) {
            gotoBad(&pagetable, &ip, sz);
            return -1;
        }
        if ((ph.vaddr % PGSIZE) != 0) {
            gotoBad(&pagetable, &ip, sz);
            return -1;
        }
        const sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(@intCast(ph.flags)));
        if (sz1 == 0) {
            gotoBad(&pagetable, &ip, sz);
            return -1;
        }
        sz = sz1;
        if (loadseg(pagetable, ph.vaddr, ip, @intCast(ph.off), @intCast(ph.filesz)) < 0) {
            gotoBad(&pagetable, &ip, sz);
            return -1;
        }
    }
    iunlockput(ip);
    end_op();
    ip = null;

    p = myproc();
    const oldsz = p.sz;

    sz = pgroundup(sz);
    const sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W);
    if (sz1 == 0) {
        gotoBad(&pagetable, &ip, sz);
        return -1;
    }
    sz = sz1;
    uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    sp = sz;
    stackbase = sp - USERSTACK * PGSIZE;

    argc = 0;
    while (argv[argc] != null) : (argc += 1) {
        if (argc >= MAXARG) {
            gotoBad(&pagetable, &ip, sz);
            return -1;
        }
        const arg = argv[argc];
        const arglen: u64 = @intCast(@as(u32, @intCast(strlen(arg))));
        sp -= arglen + 1;
        sp -= sp % 16;
        if (sp < stackbase) {
            gotoBad(&pagetable, &ip, sz);
            return -1;
        }
        if (copyout(pagetable, sp, arg, arglen + 1) < 0) {
            gotoBad(&pagetable, &ip, sz);
            return -1;
        }
        ustack[argc] = sp;
    }
    ustack[argc] = 0;

    sp -= (argc + 1) * @sizeOf(u64);
    sp -= sp % 16;
    if (sp < stackbase) {
        gotoBad(&pagetable, &ip, sz);
        return -1;
    }
    if (copyout(pagetable, sp, @ptrCast(&ustack), (argc + 1) * @sizeOf(u64)) < 0) {
        gotoBad(&pagetable, &ip, sz);
        return -1;
    }

    p.trapframe.?.a1 = sp;

    var s = path;
    var last = path;
    while (s[0] != 0) : (s += 1) {
        if (s[0] == '/') {
            last = s + 1;
        }
    }
    _ = safestrcpy(@ptrCast(&p.name), last, @intCast(p.name.len));

    oldpagetable = p.pagetable;
    p.pagetable = pagetable;
    p.sz = sz;
    p.trapframe.?.epc = elf.entry;
    p.trapframe.?.sp = sp;
    proc_freepagetable(oldpagetable, oldsz);

    return @intCast(argc);
}

fn gotoBad(pagetable: *[*c]u64, ip: *?*anyopaque, sz: u64) void {
    if (pagetable.* != @as([*c]u64, @ptrFromInt(0))) {
        proc_freepagetable(pagetable.*, sz);
    }
    if (ip.* != null) {
        iunlockput(ip.*);
        end_op();
    }
}
