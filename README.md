# Swell Kernel

A heavily forked and tuned Linux kernel for SwellOS.

## Design

- **Monolithic** — no loadable kernel module support. All drivers compiled in.
- **Performance-patched** — custom scheduler tuning, preemptible, tickless.
- **All common x86_64 drivers baked in:** GPU (Intel/AMD/Nvidia), NVMe, SATA, wired/wireless networking, USB, Ext4/Btrfs/FAT/NTFS, input, audio.
- **No legacy hardware** — no IDE, floppy, ISA, 32-bit, ancient drivers.
- **~4–6 MB uncompressed.**
- **Every config option documented** with rationale comments.

## Building

```bash
make defconfig
make -j$(nproc)
```

## Config

The kernel config is maintained in-tree with detailed comments explaining each option. See `Documentation/swell/` for the config rationale guide.
