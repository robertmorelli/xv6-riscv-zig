const cint = i32;
const cuint = u32;

const PGSIZE: u64 = 4096;
const MAXVA: u64 = (@as(u64, 1) << 38);
const SATP_SV39: u64 = (@as(u64, 8) << 60);

const UART0: u64 = 0x10000000;
const VIRTIO0: u64 = 0x10001000;
const PLIC: u64 = 0x0c000000;
const KERNBASE: u64 = 0x80000000;
const PHYSTOP: u64 = KERNBASE + 128 * 1024 * 1024;
const TRAMPOLINE: u64 = MAXVA - PGSIZE;

const PTE_V: u64 = 0x001;
const PTE_R: u64 = 0x002;
const PTE_W: u64 = 0x004;
const PTE_X: u64 = 0x008;
const PTE_U: u64 = 0x010;

const NOFILE: usize = 16;

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

const Spinlock = extern struct {
    locked: cuint,
    name: [*c]u8,
    cpu: ?*anyopaque,
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
    pagetable: [*c]u64,
    trapframe: ?*anyopaque,
    context: Context,
    ofile: [NOFILE]?*anyopaque,
    cwd: ?*anyopaque,
    name: [16]u8,
};

pub export var kernel_pagetable: [*c]u64 = @ptrFromInt(0);

extern var etext: u8;
extern var trampoline: u8;

extern fn kalloc() callconv(.c) ?*anyopaque;
extern fn kfree(pa: ?*anyopaque) callconv(.c) void;
extern fn memset(dst: ?*anyopaque, c: cint, n: cuint) callconv(.c) ?*anyopaque;
extern fn memmove(dst: ?*anyopaque, src: ?*const anyopaque, n: cuint) callconv(.c) ?*anyopaque;
extern fn panic(s: [*c]const u8) callconv(.c) noreturn;
extern fn proc_mapstacks(kpgtbl: [*c]u64) callconv(.c) void;
extern fn myproc() callconv(.c) ?*Proc;

inline fn makeSatp(pagetable: [*c]u64) u64 {
    return SATP_SV39 | (@as(u64, @intCast(@intFromPtr(pagetable))) >> 12);
}

inline fn w_satp(x: u64) void {
    asm volatile ("csrw satp, %[value]"
        :
        : [value] "r" (x),
    );
}

inline fn sfence_vma() void {
    asm volatile ("sfence.vma zero, zero");
}

inline fn pa2pte(pa: u64) u64 {
    return ((pa >> 12) << 10);
}

inline fn pte2pa(pte: u64) u64 {
    return ((pte >> 10) << 12);
}

inline fn pte_flags(pte: u64) u64 {
    return pte & 0x3ff;
}

inline fn px(level: u64, va: u64) usize {
    const shift: u6 = @intCast(12 + 9 * level);
    return @intCast((va >> shift) & 0x1ff);
}

inline fn pgroundup(sz: u64) u64 {
    return (sz + PGSIZE - 1) & ~(PGSIZE - 1);
}

inline fn pgrounddown(a: u64) u64 {
    return a & ~(PGSIZE - 1);
}

fn kvmmake() [*c]u64 {
    const kpgtbl: [*c]u64 = @ptrCast(@alignCast(kalloc().?));
    _ = memset(kpgtbl, 0, @intCast(PGSIZE));

    kvmmap(kpgtbl, UART0, UART0, PGSIZE, @intCast(PTE_R | PTE_W));
    kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, @intCast(PTE_R | PTE_W));
    kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, @intCast(PTE_R | PTE_W));

    const etext_addr = @as(u64, @intCast(@intFromPtr(&etext)));
    kvmmap(kpgtbl, KERNBASE, KERNBASE, etext_addr - KERNBASE, @intCast(PTE_R | PTE_X));
    kvmmap(kpgtbl, etext_addr, etext_addr, PHYSTOP - etext_addr, @intCast(PTE_R | PTE_W));

    kvmmap(kpgtbl, TRAMPOLINE, @intFromPtr(&trampoline), PGSIZE, @intCast(PTE_R | PTE_X));

    proc_mapstacks(kpgtbl);

    return kpgtbl;
}

pub export fn kvmmap(kpgtbl: [*c]u64, va: u64, pa: u64, sz: u64, perm: cint) void {
    if (mappages(kpgtbl, va, sz, pa, perm) != 0) {
        panic("kvmmap");
    }
}

pub export fn kvminit() void {
    kernel_pagetable = kvmmake();
}

pub export fn kvminithart() void {
    sfence_vma();
    w_satp(makeSatp(kernel_pagetable));
    sfence_vma();
}

pub export fn walk(pagetable: [*c]u64, va: u64, alloc: cint) [*c]u64 {
    var pt = pagetable;

    if (va >= MAXVA) {
        panic("walk");
    }

    var level: cint = 2;
    while (level > 0) : (level -= 1) {
        const pte = &pt[px(@intCast(@as(cuint, @intCast(level))), va)];
        if ((pte.* & PTE_V) != 0) {
            pt = @ptrFromInt(pte2pa(pte.*));
        } else {
            if (alloc == 0) {
                return @ptrFromInt(0);
            }
            const new_pt = kalloc();
            if (new_pt == null) {
                return @ptrFromInt(0);
            }
            pt = @ptrCast(@alignCast(new_pt.?));
            _ = memset(pt, 0, @intCast(PGSIZE));
            pte.* = pa2pte(@intFromPtr(pt)) | PTE_V;
        }
    }
    return &pt[px(0, va)];
}

pub export fn walkaddr(pagetable: [*c]u64, va: u64) u64 {
    if (va >= MAXVA) {
        return 0;
    }

    const pte = walk(pagetable, va, 0);
    if (pte == @as([*c]u64, @ptrFromInt(0))) {
        return 0;
    }
    if ((pte.* & PTE_V) == 0) {
        return 0;
    }
    if ((pte.* & PTE_U) == 0) {
        return 0;
    }
    return pte2pa(pte.*);
}

pub export fn mappages(pagetable: [*c]u64, va: u64, size: u64, pa: u64, perm: cint) cint {
    var a = va;
    var p = pa;
    var pte: [*c]u64 = @ptrFromInt(0);

    if ((va % PGSIZE) != 0) {
        panic("mappages: va not aligned");
    }
    if ((size % PGSIZE) != 0) {
        panic("mappages: size not aligned");
    }
    if (size == 0) {
        panic("mappages: size");
    }

    const last = va + size - PGSIZE;
    while (true) {
        pte = walk(pagetable, a, 1);
        if (pte == @as([*c]u64, @ptrFromInt(0))) {
            return -1;
        }
        if ((pte.* & PTE_V) != 0) {
            panic("mappages: remap");
        }
        const perm_u: u64 = @intCast(@as(cuint, @intCast(perm)));
        pte.* = pa2pte(p) | perm_u | PTE_V;
        if (a == last) {
            break;
        }
        a += PGSIZE;
        p += PGSIZE;
    }
    return 0;
}

pub export fn uvmcreate() [*c]u64 {
    const pagetable_mem = kalloc();
    if (pagetable_mem == null) {
        return @ptrFromInt(0);
    }
    const pagetable: [*c]u64 = @ptrCast(@alignCast(pagetable_mem.?));
    _ = memset(pagetable, 0, @intCast(PGSIZE));
    return pagetable;
}

pub export fn uvmunmap(pagetable: [*c]u64, va: u64, npages: u64, do_free: cint) void {
    if ((va % PGSIZE) != 0) {
        panic("uvmunmap: not aligned");
    }

    var a = va;
    while (a < va + npages * PGSIZE) : (a += PGSIZE) {
        const pte = walk(pagetable, a, 0);
        if (pte == @as([*c]u64, @ptrFromInt(0))) {
            continue;
        }
        if ((pte.* & PTE_V) == 0) {
            continue;
        }
        if (do_free != 0) {
            const pa = pte2pa(pte.*);
            kfree(@ptrFromInt(pa));
        }
        pte.* = 0;
    }
}

pub export fn uvmalloc(pagetable: [*c]u64, oldsz: u64, newsz: u64, xperm: cint) u64 {
    var oldsz_mut = oldsz;
    if (newsz < oldsz_mut) {
        return oldsz_mut;
    }

    oldsz_mut = pgroundup(oldsz_mut);
    var a = oldsz_mut;
    while (a < newsz) : (a += PGSIZE) {
        const mem = kalloc();
        if (mem == null) {
            _ = uvmdealloc(pagetable, a, oldsz_mut);
            return 0;
        }
        _ = memset(mem, 0, @intCast(PGSIZE));
        const perm: cint = @intCast(PTE_R | PTE_U | @as(u64, @intCast(@as(cuint, @intCast(xperm)))));
        if (mappages(pagetable, a, PGSIZE, @intFromPtr(mem.?), perm) != 0) {
            kfree(mem);
            _ = uvmdealloc(pagetable, a, oldsz_mut);
            return 0;
        }
    }
    return newsz;
}

pub export fn uvmdealloc(pagetable: [*c]u64, oldsz: u64, newsz: u64) u64 {
    if (newsz >= oldsz) {
        return oldsz;
    }

    if (pgroundup(newsz) < pgroundup(oldsz)) {
        const npages = (pgroundup(oldsz) - pgroundup(newsz)) / PGSIZE;
        uvmunmap(pagetable, pgroundup(newsz), npages, 1);
    }

    return newsz;
}

pub export fn freewalk(pagetable: [*c]u64) void {
    var i: usize = 0;
    while (i < 512) : (i += 1) {
        const pte = pagetable[i];
        if ((pte & PTE_V) != 0 and (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
            const child = pte2pa(pte);
            freewalk(@ptrFromInt(child));
            pagetable[i] = 0;
        } else if ((pte & PTE_V) != 0) {
            panic("freewalk: leaf");
        }
    }
    kfree(pagetable);
}

pub export fn uvmfree(pagetable: [*c]u64, sz: u64) void {
    if (sz > 0) {
        uvmunmap(pagetable, 0, pgroundup(sz) / PGSIZE, 1);
    }
    freewalk(pagetable);
}

pub export fn uvmcopy(old: [*c]u64, new: [*c]u64, sz: u64) cint {
    var i: u64 = 0;
    while (i < sz) : (i += PGSIZE) {
        const pte = walk(old, i, 0);
        if (pte == @as([*c]u64, @ptrFromInt(0))) {
            continue;
        }
        if ((pte.* & PTE_V) == 0) {
            continue;
        }

        const pa = pte2pa(pte.*);
        const flags = pte_flags(pte.*);
        const mem = kalloc();
        if (mem == null) {
            uvmunmap(new, 0, i / PGSIZE, 1);
            return -1;
        }

        _ = memmove(mem, @ptrFromInt(pa), @intCast(PGSIZE));
        if (mappages(new, i, PGSIZE, @intFromPtr(mem.?), @intCast(flags)) != 0) {
            kfree(mem);
            uvmunmap(new, 0, i / PGSIZE, 1);
            return -1;
        }
    }
    return 0;
}

pub export fn uvmclear(pagetable: [*c]u64, va: u64) void {
    const pte = walk(pagetable, va, 0);
    if (pte == @as([*c]u64, @ptrFromInt(0))) {
        panic("uvmclear");
    }
    pte.* &= ~PTE_U;
}

pub export fn copyout(pagetable: [*c]u64, dstva: u64, src: [*c]u8, len: u64) cint {
    var len_left = len;
    var dst = dstva;
    var src_addr = @as(u64, @intCast(@intFromPtr(src)));

    while (len_left > 0) {
        const va0 = pgrounddown(dst);
        if (va0 >= MAXVA) {
            return -1;
        }

        var pa0 = walkaddr(pagetable, va0);
        if (pa0 == 0) {
            pa0 = vmfault(pagetable, va0, 0);
            if (pa0 == 0) {
                return -1;
            }
        }

        const pte = walk(pagetable, va0, 0);
        if ((pte.* & PTE_W) == 0) {
            return -1;
        }

        var n = PGSIZE - (dst - va0);
        if (n > len_left) {
            n = len_left;
        }
        _ = memmove(@ptrFromInt(pa0 + (dst - va0)), @ptrFromInt(src_addr), @intCast(n));

        len_left -= n;
        src_addr += n;
        dst = va0 + PGSIZE;
    }
    return 0;
}

pub export fn copyin(pagetable: [*c]u64, dst: [*c]u8, srcva: u64, len: u64) cint {
    var len_left = len;
    var src = srcva;
    var dst_addr = @as(u64, @intCast(@intFromPtr(dst)));

    while (len_left > 0) {
        const va0 = pgrounddown(src);
        var pa0 = walkaddr(pagetable, va0);
        if (pa0 == 0) {
            pa0 = vmfault(pagetable, va0, 0);
            if (pa0 == 0) {
                return -1;
            }
        }

        var n = PGSIZE - (src - va0);
        if (n > len_left) {
            n = len_left;
        }
        _ = memmove(@ptrFromInt(dst_addr), @ptrFromInt(pa0 + (src - va0)), @intCast(n));

        len_left -= n;
        dst_addr += n;
        src = va0 + PGSIZE;
    }
    return 0;
}

pub export fn copyinstr(pagetable: [*c]u64, dst: [*c]u8, srcva: u64, max: u64) cint {
    var got_null: cint = 0;
    var src = srcva;
    var max_left = max;
    var dst_addr = @as(u64, @intCast(@intFromPtr(dst)));

    while (got_null == 0 and max_left > 0) {
        const va0 = pgrounddown(src);
        const pa0 = walkaddr(pagetable, va0);
        if (pa0 == 0) {
            return -1;
        }

        var n = PGSIZE - (src - va0);
        if (n > max_left) {
            n = max_left;
        }

        var p_addr = pa0 + (src - va0);
        while (n > 0) {
            const ch = @as(*u8, @ptrFromInt(p_addr)).*;
            if (ch == 0) {
                @as(*u8, @ptrFromInt(dst_addr)).* = 0;
                got_null = 1;
                break;
            } else {
                @as(*u8, @ptrFromInt(dst_addr)).* = ch;
            }
            n -= 1;
            max_left -= 1;
            p_addr += 1;
            dst_addr += 1;
        }

        src = va0 + PGSIZE;
    }

    return if (got_null != 0) 0 else -1;
}

pub export fn vmfault(pagetable: [*c]u64, va: u64, read: cint) u64 {
    _ = read;

    const p = myproc().?;
    if (va >= p.sz) {
        return 0;
    }

    const va0 = pgrounddown(va);
    if (ismapped(pagetable, va0) != 0) {
        return 0;
    }

    const mem = kalloc();
    if (mem == null) {
        return 0;
    }

    const mem_addr = @as(u64, @intCast(@intFromPtr(mem.?)));
    _ = memset(mem, 0, @intCast(PGSIZE));
    if (mappages(p.pagetable, va0, PGSIZE, mem_addr, @intCast(PTE_W | PTE_U | PTE_R)) != 0) {
        kfree(mem);
        return 0;
    }

    return mem_addr;
}

pub export fn ismapped(pagetable: [*c]u64, va: u64) cint {
    const pte = walk(pagetable, va, 0);
    if (pte == @as([*c]u64, @ptrFromInt(0))) {
        return 0;
    }
    if ((pte.* & PTE_V) != 0) {
        return 1;
    }
    return 0;
}
