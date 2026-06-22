#!/bin/sh -e
#
# Build the Swell kernel
#
# Usage: ./scripts/build.sh [config|menuconfig|clean|distclean]
#

ARCH=x86_64
KERNEL_SRC="${KERNEL_SRC:-/usr/src/linux}"
OUTPUT="${OUTPUT:-/boot}"
CONFIG_SRC="$(dirname "$0")/../config/x86_64/config-6.x-swell"
NPROC="$(nproc)"

case "${1:-}" in
    config)
        cp "$CONFIG_SRC" "$KERNEL_SRC/.config"
        echo "Installed Swell config to $KERNEL_SRC/.config"
        ;;
    menuconfig)
        make -C "$KERNEL_SRC" O="$KERNEL_SRC" menuconfig
        ;;
    clean)
        make -C "$KERNEL_SRC" clean
        ;;
    distclean)
        make -C "$KERNEL_SRC" distclean
        ;;
    *)
        # Default: build
        if [ ! -f "$KERNEL_SRC/.config" ]; then
            cp "$CONFIG_SRC" "$KERNEL_SRC/.config"
            echo "Installed Swell config"
        fi

        echo "Building kernel with $NPROC threads..."

        make -C "$KERNEL_SRC" \
            -j"$NPROC" \
            bzImage

        echo "Installing kernel to $OUTPUT..."
        cp "$KERNEL_SRC/arch/x86/boot/bzImage" "$OUTPUT/vmlinuz-swell"

        # Build and install kernel headers
        make -C "$KERNEL_SRC" \
            -j"$NPROC" \
            headers_install \
            INSTALL_HDR_PATH="${OUTPUT%/*}/usr"

        echo "Kernel built and installed."
        echo "  Image:  $OUTPUT/vmlinuz-swell"
        ;;
esac
