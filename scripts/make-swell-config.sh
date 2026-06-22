#!/bin/sh -e
#
# Helper: extract Swell config changes relative to defconfig
# Usage: ./scripts/make-swell-config.sh diff
#        ./scripts/make-swell-config.sh apply
#

ARCH=x86_64
CONFIG_FILE="config/x86_64/config-6.x-swell"
SCRIPT_DIR="$(dirname "$0")"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
LINUX_SRC="${LINUX_SRC:-/usr/src/linux}"

case "${1:-}" in
    diff)
        # Show what differs from the upstream defconfig
        cp "$REPO_DIR/$CONFIG_FILE" "$LINUX_SRC/.config-swell"
        make -C "$LINUX_SRC" defconfig
        diff -u "$LINUX_SRC/.config" "$LINUX_SRC/.config-swell" || true
        ;;
    apply)
        cp "$REPO_DIR/$CONFIG_FILE" "$LINUX_SRC/.config"
        make -C "$LINUX_SRC" olddefconfig
        echo "Applied Swell config. Run 'make -j\$(nproc) bzImage' to build."
        ;;
    *)
        echo "Usage: $0 {diff|apply}"
        exit 1
        ;;
esac
