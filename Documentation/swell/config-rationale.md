# Swell Kernel Config Rationale

Every non-default kernel config option in SwellOS is documented here.

## Design Principles

1. **Monolithic** — no loadable kernel modules. All drivers compiled in.
2. **No legacy** — no IDE, floppy, ISA, 32-bit, or ancient hardware support.
3. **Performance-first** — preemptible kernel, tickless idle, 1000 Hz timer.
4. **Modern x86_64 only** — requires at least x86-64-v2 (2010+), targets v3 (2015+).
5. **Security hardened** — PTI, retpoline, KASLR, hardened usercopy, IMA.
6. **All common hardware baked in** — GPU (Intel/AMD/Nvidia), NVMe, SATA, USB 3.x,
   Ethernet (1G/2.5G/10G), Wi-Fi (Intel/MediaTek/Broadcom), audio (HD-Audio/USB/SOF).

## Section-by-Section

### General Setup
- **`CONFIG_SWAP=y`** — swap is still useful for zram/zswap.
- **`CONFIG_AUDIT=y`** — needed for modern userspace auditing.
- **`# CONFIG_SYSVIPC is not set`** — System V IPC is obsolete; modern systems use
  memfd, signalfd, and D-Bus. Removing it saves memory and reduces attack surface.

### Preemption Model
- **`CONFIG_PREEMPT=y`** — fully preemptible kernel. Lowest scheduling latency.
  Essential for desktop responsiveness, audio work, and gaming.
  Not using RT (real-time) preemption because the latency improvements are marginal
  for desktop use and come with a throughput penalty.

### Timer Frequency
- **`CONFIG_HZ_1000=y`** — 1000 Hz timer for desktop responsiveness.
  Lower values (100/250/300 Hz) are better for servers and battery life,
  but SwellOS prioritises interactivity.

### CPU Frequency Scaling
- **`# CONFIG_CPU_FREQ is not set`** — the kernel does not manage CPU frequency.
  The CPU runs at its maximum performance level. Users who want power management
  can use userspace tools (e.g. `cpupower`). This reduces kernel complexity and
  eliminates a source of scheduling latency.

### Memory Management
- **`CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y`** — always use transparent hugepages
  (rather than `madvise`). This provides a performance improvement for most
  workloads at the cost of slightly more memory. On a desktop system the trade-off
  is always worth it.
- **`CONFIG_ZSWAP=y`** / **`CONFIG_ZRAM=y`** — compressed in-memory swap.
  zswap caches swap pages in compressed memory; zram provides a compressed
  RAM-backed block device. Together they reduce I/O and improve responsiveness
  under memory pressure.
- **`CONFIG_LRU_GEN=y`** / **`CONFIG_LRU_GEN_ENABLED=y`** — multi-generational LRU.
  A significantly improved page reclaim algorithm that reduces kswapd CPU usage
  and provides better performance under memory pressure.

### Scheduler
- **`CONFIG_CFS_BANDWIDTH=y`** — enables CPU bandwidth control for cgroups.
  Required for container and Flatpak-style sandboxing.
- **`CONFIG_SCHED_SMT=y`** — SMT (Hyper-Threading) awareness. The scheduler
  understands which CPUs share execution units and schedules accordingly.

### Kernel Security
- **`CONFIG_MITIGATION_*`** — all CPU speculation mitigations enabled.
  SwellOS targets modern hardware with microcode updates; mitigations are
  essential.
- **`CONFIG_RANDOMIZE_BASE=y`** (KASLR) — randomizes the kernel base address
  at boot.
- **`CONFIG_RANDOMIZE_MEMORY=y`** — randomizes kernel memory layout (KASLR for
  physical memory).
- **`CONFIG_HARDENED_USERCOPY=y`** — hardens copy_to_user/copy_from_user
  against buffer overflows.
- **`CONFIG_FORTIFY_SOURCE=y`** — compile-time and run-time buffer overflow
  detection in string/memory functions.
- **`CONFIG_STATIC_USERMODEHELPER=y`** — restricts usermode helper paths to
  a single configured binary, preventing privilege escalation via usermode
  helper hijacking.
- **`CONFIG_SECURITY_YAMA=y`** — ptrace scope restrictions. Prevents
  non-privileged processes from attaching to processes they don't own.
- **`CONFIG_SECURITY_LOADPIN=y`** — restricts module/kernel loading to a
  single filesystem (typically the root filesystem).
- **`CONFIG_IMA=y`** — Integrity Measurement Architecture. Measures file
  hashes before access, providing integrity guarantees.

### Storage
- **`CONFIG_BLK_DEV_NVME=y`** — NVMe built-in. Essential for modern SSDs.
- **`CONFIG_SATA_AHCI=y`** — AHCI SATA for SATA SSDs and HDDs.
- **`# CONFIG_IDE is not set`** — IDE is completely disabled. No PATA/IDE
  controllers have been common since ~2008.
- **`CONFIG_DM_CRYPT=y`** / **`CONFIG_DM_VERITY=y`** — device-mapper crypto
  and integrity for LUKS encryption.

### Filesystems
- **`CONFIG_EXT4_FS=y`** — primary filesystem. Stable, well-tested, performant.
- **`CONFIG_BTRFS_FS=y`** — optional advanced filesystem (snapshots, checksums,
  RAID, compression).
- **`CONFIG_SQUASHFS=y`** — for the live ISO environment.
- **`CONFIG_OVERLAY_FS=y`** — OverlayFS for container images and live session
  overlays.
- **`# CONFIG_MODULES is not set`** — no kernel module support. This is the
  defining feature of SwellOS. All drivers are baked into the kernel.

### Networking
- **`CONFIG_NF_TABLES=y`** — modern firewall (nftables). iptables compatibility
  (`CONFIG_NETFILTER_XTABLES`) also built in for migration.
- **`CONFIG_CFG80211=y`** / **`CONFIG_MAC80211=y`** — wireless stack.
  Common Wi-Fi chipsets (Intel IWLWIFI, MediaTek MT76, Broadcom BRCMFMAC)
  are compiled in.
- **`CONFIG_TCP_CONG_BBR=y`** — BBR congestion control available alongside
  default CUBIC.

### Graphics
- **`CONFIG_DRM_I915=y`** — Intel integrated graphics (gen3 through modern).
- **`CONFIG_DRM_AMDGPU=y`** — AMD/ATI GPUs (GCN 1+).
- **`CONFIG_DRM_NOUVEAU=y`** — NVIDIA open-source driver. For full NVIDIA
  performance, users can install the proprietary nvidia driver.
- **`CONFIG_FB_EFI=y`** / **`CONFIG_FB_VESA=y`** — fallback framebuffers
  for early boot and compatibility.

### Audio
- **`CONFIG_SND_HDA_INTEL=y`** — Intel HD Audio (most common onboard audio).
- **`CONFIG_SND_HDA_CODEC_REALTEK=y`** — Realtek codecs (most common).
- **`CONFIG_SND_USB_AUDIO=y`** — USB audio class devices.
- **`CONFIG_SND_SOC_INTEL_SKYLAKE=y`** — Intel Smart Sound Technology (DSP
  audio for Skylake and newer).
- **`CONFIG_SND_SOC_SOF_PCI=y`** / **`CONFIG_SND_SOC_SOF_ACPI=y`** — Sound
  Open Firmware for newer Intel platforms (cAVS 2.5+).

### Input
- **`CONFIG_HID_MULTITOUCH=y`** — multitouch touchpads and touchscreens.
- **`CONFIG_HID_RMI=y`** — Synaptics RMI4 touchpads.
- **`CONFIG_HID_ALPS=y`** — Alps touchpads.
- **`CONFIG_HID_WACOM=y`** — Wacom tablets.
- **`CONFIG_MOUSE_PS2_TRACKPOINT=y`** — ThinkPad TrackPoint.
- **`CONFIG_JOYSTICK_XPAD=y`** — Xbox game controllers.

### USB
- **`CONFIG_USB_XHCI_HCD=y`** — USB 3.x (xHCI).
- **`CONFIG_USB_EHCI_HCD=y`** — USB 2.0 (EHCI).
- **`# CONFIG_USB_OHCI_HCD is not set`** — no OHCI (legacy USB 1.1).
- **`# CONFIG_USB_UHCI_HCD is not set`** — no UHCI (legacy USB 1.1).

### Virtualization
- **`CONFIG_KVM_INTEL=y`** / **`CONFIG_KVM_AMD=y`** — KVM hardware
  virtualization support for running VMs.
- **`CONFIG_VIRTIO_PCI=y`** — virtio devices for VM guests.

## Config Size Target

The kernel image (`arch/x86/boot/bzImage`) should be 4–6 MB uncompressed
and approximately 2–3 MB after gzip compression.

## Updating the Config

When a new kernel version is released:

1. Copy the new defconfig: `make defconfig`
2. Copy Swell config overlay: `cp config/x86_64/config-6.x-swell .config`
3. Run `make olddefconfig` to absorb new defaults
4. Review new options with `make listnewconfig`
5. Update the config file in this repo
