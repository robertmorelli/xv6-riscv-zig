
var started: i32 = 0;

extern fn cpuid() i32;
extern fn consoleinit() void;
extern fn printfinit() void;
extern fn kinit() void;
extern fn kvminit() void;
extern fn kvminithart() void;
extern fn procinit() void;
extern fn trapinit() void;
extern fn trapinithart() void;
extern fn plicinit() void;
extern fn plicinithart() void;
extern fn binit() void;
extern fn iinit() void;
extern fn fileinit() void;
extern fn virtio_disk_init() void;
extern fn userinit() void;
extern fn scheduler() noreturn;

pub export fn main() noreturn {
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
        @atomicStore(i32, &started, 1, .seq_cst);
    } else {
        while (@atomicLoad(i32, &started, .seq_cst) == 0) {}
        kvminithart();
        trapinithart();
        plicinithart();
    }

    scheduler();
}
