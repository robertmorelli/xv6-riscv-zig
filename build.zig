const std = @import("std");

const rv_target = "riscv64-freestanding-none";
const optimize = "ReleaseSmall";

fn addAsmObj(b: *std.Build, src: []const u8, out: []const u8) *std.Build.Step.Run {
    return b.addSystemCommand(&[_][]const u8{
        "zig", "cc",
        "-target", rv_target,
        "-g",
        "-c",
        "-o", out,
        src,
    });
}

fn addZigObj(b: *std.Build, src: []const u8, out: []const u8) *std.Build.Step.Run {
    return b.addSystemCommand(&[_][]const u8{
        "zig", "build-obj",
        "-target", rv_target,
        "-mcmodel=medany",
        "-O", optimize,
        b.fmt("-femit-bin={s}", .{out}),
        src,
    });
}

pub fn build(b: *std.Build) void {
    const qemu_bin = b.option([]const u8, "qemu", "QEMU executable path") orelse "qemu-system-riscv64";
    const cpus = b.option(u8, "cpus", "QEMU SMP count") orelse 3;
    const cpus_arg = b.fmt("{d}", .{cpus});

    const kernel_obj_rules = [_]struct {
        src: []const u8,
        out: []const u8,
        is_asm: bool,
    }{
        .{ .src = "kernel/entry.S", .out = "kernel/entry.o", .is_asm = true },
        .{ .src = "kernel/start.zig", .out = "kernel/start.o", .is_asm = false },
        .{ .src = "kernel/console.zig", .out = "kernel/console.o", .is_asm = false },
        .{ .src = "kernel/printf.zig", .out = "kernel/printf.o", .is_asm = false },
        .{ .src = "kernel/uart.zig", .out = "kernel/uart.o", .is_asm = false },
        .{ .src = "kernel/kalloc.zig", .out = "kernel/kalloc.o", .is_asm = false },
        .{ .src = "kernel/spinlock.zig", .out = "kernel/spinlock.o", .is_asm = false },
        .{ .src = "kernel/string.zig", .out = "kernel/string.o", .is_asm = false },
        .{ .src = "kernel/main.zig", .out = "kernel/main.o", .is_asm = false },
        .{ .src = "kernel/vm.zig", .out = "kernel/vm.o", .is_asm = false },
        .{ .src = "kernel/proc.zig", .out = "kernel/proc.o", .is_asm = false },
        .{ .src = "kernel/swtch.S", .out = "kernel/swtch.o", .is_asm = true },
        .{ .src = "kernel/trampoline.S", .out = "kernel/trampoline.o", .is_asm = true },
        .{ .src = "kernel/trap.zig", .out = "kernel/trap.o", .is_asm = false },
        .{ .src = "kernel/syscall.zig", .out = "kernel/syscall.o", .is_asm = false },
        .{ .src = "kernel/sysproc.zig", .out = "kernel/sysproc.o", .is_asm = false },
        .{ .src = "kernel/bio.zig", .out = "kernel/bio.o", .is_asm = false },
        .{ .src = "kernel/fs.zig", .out = "kernel/fs.o", .is_asm = false },
        .{ .src = "kernel/log.zig", .out = "kernel/log.o", .is_asm = false },
        .{ .src = "kernel/sleeplock.zig", .out = "kernel/sleeplock.o", .is_asm = false },
        .{ .src = "kernel/file.zig", .out = "kernel/file.o", .is_asm = false },
        .{ .src = "kernel/pipe.zig", .out = "kernel/pipe.o", .is_asm = false },
        .{ .src = "kernel/exec.zig", .out = "kernel/exec.o", .is_asm = false },
        .{ .src = "kernel/sysfile.zig", .out = "kernel/sysfile.o", .is_asm = false },
        .{ .src = "kernel/kernelvec.S", .out = "kernel/kernelvec.o", .is_asm = true },
        .{ .src = "kernel/plic.zig", .out = "kernel/plic.o", .is_asm = false },
        .{ .src = "kernel/virtio_disk.zig", .out = "kernel/virtio_disk.o", .is_asm = false },
    };

    const kernel_objs_step = b.step("kernel-objs", "Compile kernel objects");
    for (kernel_obj_rules) |r| {
        const cmd = if (r.is_asm) addAsmObj(b, r.src, r.out) else addZigObj(b, r.src, r.out);
        kernel_objs_step.dependOn(&cmd.step);
    }

    const link_kernel = b.addSystemCommand(&[_][]const u8{
        "zig", "ld.lld",
        "-z", "max-page-size=4096",
        "-T", "kernel/kernel.ld",
        "-o", "kernel/kernel",
    });
    for (kernel_obj_rules) |r| {
        link_kernel.addArg(r.out);
    }
    link_kernel.step.dependOn(kernel_objs_step);

    const kernel_step = b.step("kernel", "Build kernel/kernel");
    kernel_step.dependOn(&link_kernel.step);

    const gen_usys = b.addSystemCommand(&[_][]const u8{
        "zig", "run", "./gen_usys.zig", "--", "user/usys.S",
    });

    const user_obj_names = [_][]const u8{
        "ulib",
        "printf",
        "umalloc",
        "cat",
        "echo",
        "forktest",
        "grep",
        "init",
        "kill",
        "ln",
        "ls",
        "mkdir",
        "rm",
        "sh",
        "stressfs",
        "usertests",
        "grind",
        "wc",
        "zombie",
        "logstress",
        "forphan",
        "dorphan",
    };

    const user_objs_step = b.step("user-objs", "Compile user objects");
    const usys_obj = b.addSystemCommand(&[_][]const u8{
        "zig", "cc",
        "-target", rv_target,
        "-c",
        "-o", "user/usys.o",
        "user/usys.S",
    });
    usys_obj.step.dependOn(&gen_usys.step);
    user_objs_step.dependOn(&usys_obj.step);

    for (user_obj_names) |name| {
        const src = b.fmt("user/{s}.zig", .{name});
        const out = b.fmt("user/{s}.o", .{name});
        const cmd = addZigObj(b, src, out);
        user_objs_step.dependOn(&cmd.step);
    }

    const ulib_objs = [_][]const u8{
        "user/ulib.o",
        "user/usys.o",
        "user/printf.o",
        "user/umalloc.o",
    };

    const normal_user_bins = [_][]const u8{
        "cat",
        "echo",
        "grep",
        "init",
        "kill",
        "ln",
        "ls",
        "mkdir",
        "rm",
        "sh",
        "stressfs",
        "usertests",
        "grind",
        "wc",
        "zombie",
        "logstress",
        "forphan",
        "dorphan",
    };

    const user_bins_step = b.step("user-bins", "Link user programs");
    for (normal_user_bins) |name| {
        const out = b.fmt("user/_{s}", .{name});
        const obj = b.fmt("user/{s}.o", .{name});
        const link = b.addSystemCommand(&[_][]const u8{
            "zig", "ld.lld",
            "-z", "max-page-size=4096",
            "-e", "main",
            "-T", "user/user.ld",
            "-o", out,
            obj,
        });
        for (ulib_objs) |lib| {
            link.addArg(lib);
        }
        link.step.dependOn(user_objs_step);
        user_bins_step.dependOn(&link.step);
    }

    const link_forktest = b.addSystemCommand(&[_][]const u8{
        "zig", "ld.lld",
        "-z", "max-page-size=4096",
        "-N",
        "-e", "main",
        "-Ttext", "0",
        "-o", "user/_forktest",
        "user/forktest.o",
        "user/ulib.o",
        "user/usys.o",
    });
    link_forktest.step.dependOn(user_objs_step);
    user_bins_step.dependOn(&link_forktest.step);

    const mkfs_bin = b.addSystemCommand(&[_][]const u8{
        "zig", "build-exe",
        "-O", optimize,
        "-femit-bin=mkfs/mkfs",
        "mkfs/mkfs.zig",
    });

    const fsimg = b.addSystemCommand(&[_][]const u8{
        "mkfs/mkfs",
        "fs.img",
        "README",
    });
    const uprog_order = [_][]const u8{
        "user/_cat",
        "user/_echo",
        "user/_forktest",
        "user/_grep",
        "user/_init",
        "user/_kill",
        "user/_ln",
        "user/_ls",
        "user/_mkdir",
        "user/_rm",
        "user/_sh",
        "user/_stressfs",
        "user/_usertests",
        "user/_grind",
        "user/_wc",
        "user/_zombie",
        "user/_logstress",
        "user/_forphan",
        "user/_dorphan",
    };
    for (uprog_order) |prog| {
        fsimg.addArg(prog);
    }
    fsimg.step.dependOn(&mkfs_bin.step);
    fsimg.step.dependOn(user_bins_step);

    const fsimg_step = b.step("fsimg", "Build fs.img");
    fsimg_step.dependOn(&fsimg.step);

    b.default_step.dependOn(&link_kernel.step);
    b.default_step.dependOn(&fsimg.step);

    const qemu_cmd = b.addSystemCommand(&[_][]const u8{
        qemu_bin,
        "-machine", "virt",
        "-bios", "none",
        "-kernel", "kernel/kernel",
        "-m", "128M",
        "-smp", cpus_arg,
        "-nographic",
        "-global", "virtio-mmio.force-legacy=false",
        "-drive", "file=fs.img,if=none,format=raw,id=x0",
        "-device", "virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0",
    });
    qemu_cmd.step.dependOn(&link_kernel.step);
    qemu_cmd.step.dependOn(&fsimg.step);

    const qemu_step = b.step("qemu", "Run xv6 under qemu-system-riscv64");
    qemu_step.dependOn(&qemu_cmd.step);

    const clean_cmd = b.addSystemCommand(&[_][]const u8{
        "bash",
        "-lc",
        "rm -f kernel/*.o kernel/*.d kernel/kernel user/*.o user/*.d user/_* user/usys.S mkfs/mkfs fs.img .gdbinit",
    });
    const clean_step = b.step("clean", "Remove build artifacts");
    clean_step.dependOn(&clean_cmd.step);
}
