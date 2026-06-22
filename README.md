# Swell Kernel

A monolithic, performance-patched Linux kernel fork for SwellOS.

## Design

- **Monolithic** — no loadable kernel module support. All drivers compiled in.
- **Performance-patched** — preemptible, tickless, 1000 Hz, custom tuning.
- **All common x86_64 drivers baked in:** GPU (Intel/AMD/Nvidia), NVMe, SATA,
  wired/wireless networking, USB 3.x, Ext4/Btrfs/FAT/NTFS, input, audio.
- **No legacy hardware** — no IDE, floppy, ISA, 32-bit, OhCI/UHCI, ancient
  drivers.
- **~4–6 MB uncompressed** (~2–3 MB gzip).
- **Every config option is documented** with rationale in `Documentation/swell/`.

## Quick Start

```bash
# Clone kernel source
git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git /usr/src/linux

# Apply Swell config
make -C /usr/src/linux defconfig
cp config/x86_64/config-6.x-swell /usr/src/linux/.config
make -C /usr/src/linux olddefconfig

# Build
make -C /usr/src/linux -j$(nproc) bzImage

# Install
cp /usr/src/linux/arch/x86/boot/bzImage /boot/vmlinuz-swell
```

Or use the build script:

```bash
./scripts/build.sh          # build with current .config
./scripts/build.sh config   # install Swell .config
./scripts/build.sh clean    # clean build artifacts
```

## Config

The kernel configuration is maintained at:

- `config/x86_64/config-6.x-swell` — the full `.config` file.
- `Documentation/swell/config-rationale.md` — rationale for every
  non-default option.

To apply the Swell config to a fresh kernel tree:

```bash
./scripts/make-swell-config.sh apply
```

To see what Swell changes relative to upstream defconfig:

```bash
./scripts/make-swell-config.sh diff
```

## Patches

SwellOS-specific patches are in `scripts/patches/`. These are applied
on top of the upstream Linux kernel. Current patches:

| Patch | Description |
|-------|-------------|
| `0001-swell-tuning.patch` | Aggressive `-O3 -march=x86-64-v3`, scheduling, MWAIT |

## Building for the Live ISO

Kernel is built as part of `swell-build world`. The resulting `bzImage`
is bundled into the ISO at `/boot/vmlinuz-swell`.

## Versioning

The Swell kernel tracks upstream Linux stable. Each release is prefixed
with the upstream version, e.g. `6.12-swell-1`.

## License

GNU General Public License v2.0 (inherited from Linux).
