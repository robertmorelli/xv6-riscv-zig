# xv6-riscv (Zig-Only Build)

This repository is a Zig-based port of xv6 for RISC-V:

- Kernel and user-space programs are written in Zig (with required low-level assembly where appropriate).
- Build orchestration is handled by `zig build` (`build.zig`), not `make`.
- Syscall stub generation is done by Zig (`gen_usys.zig`), not Perl.
- `mkfs` is implemented in Zig.
- Release mode for target artifacts is `ReleaseSmall`.

## Requirements

- [Zig](https://ziglang.org/) (0.15.x recommended)
- `qemu-system-riscv64`
- Python 3 (for the existing test harness scripts)

If your environment restricts Zig's default global cache location, set:

```bash
export ZIG_LOCAL_CACHE_DIR=.zig-cache-local
export ZIG_GLOBAL_CACHE_DIR=.zig-global-cache
```

## Build

Build kernel + user programs + `fs.img`:

```bash
zig build
```

Build only the kernel:

```bash
zig build kernel
```

Build only the file-system image:

```bash
zig build fsimg
```

Clean build outputs:

```bash
zig build clean
```

## Run in QEMU

Boot xv6 with the Zig build artifacts:

```bash
zig build qemu
```

Optional: choose a different QEMU binary or CPU count:

```bash
zig build qemu -Dqemu=/path/to/qemu-system-riscv64 -Dcpus=3
```

## Testing

Quick profile:

```bash
python3 tools/run_tests.py --profile quick
```

Full profile:

```bash
python3 tools/run_tests.py --profile full
```

You can also run legacy-style targeted tests:

```bash
python3 test-xv6.py -q usertests
python3 test-xv6.py crash
```

## Notes

- The `crash` suite can be timing-sensitive under QEMU and may occasionally require a retry.
- Low-level assembly (`.S`) and linker scripts (`.ld`) are intentionally retained for trap/boot/link correctness on RISC-V.
