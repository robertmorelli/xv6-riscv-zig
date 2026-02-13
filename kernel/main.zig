const cint = i32;

var started: cint = 0;

extern fn cpuid() callconv(.c) cint;
extern fn consoleinit() callconv(.c) void;
extern fn printfinit() callconv(.c) void;
extern fn kinit() callconv(.c) void;
extern fn kvminit() callconv(.c) void;
extern fn kvminithart() callconv(.c) void;
extern fn procinit() callconv(.c) void;
extern fn trapinit() callconv(.c) void;
extern fn trapinithart() callconv(.c) void;
extern fn plicinit() callconv(.c) void;
extern fn plicinithart() callconv(.c) void;
extern fn binit() callconv(.c) void;
extern fn iinit() callconv(.c) void;
extern fn fileinit() callconv(.c) void;
extern fn virtio_disk_init() callconv(.c) void;
extern fn userinit() callconv(.c) void;
extern fn scheduler() callconv(.c) noreturn;

pub export fn main() callconv(.c) noreturn {
    if (cpuid() == 0) {
        consoleinit();
        printfinit();
        kinit();
        kvminit();
        kvminithart();
        procinit();
        trapinit();
        trapinithart();
        plicinit();
        plicinithart();
        binit();
        iinit();
        fileinit();
        virtio_disk_init();
        userinit();
        @atomicStore(cint, &started, 1, .seq_cst);
    } else {
        while (@atomicLoad(cint, &started, .seq_cst) == 0) {}
        kvminithart();
        trapinithart();
        plicinithart();
    }

    scheduler();
}
