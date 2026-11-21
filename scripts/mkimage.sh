#!/usr/bin/env bash
set -euo pipefail

usage()
{
    printf '%s\n' \
        "Usage: $0 [--output=FILE] [--install-busybox] [--install-onsyuri]" \
        'Create a new ext2 root filesystem image (default: rootfs.ext2.img in ntp).' \
        'Install options use existing RISC-V builds. Existing images are kept as-is.'
}

ntp_dir=$(cd -- "$(dirname -- "$0")/.." && pwd)
image="$ntp_dir/rootfs.ext2.img"
install_busybox=0
install_onsyuri=0
for arg in "$@"; do
    case $arg in
        --output=?*) image=${arg#*=} ;;
        --install-busybox) install_busybox=1 ;;
        --install-onsyuri) install_onsyuri=1 ;;
        --help) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done

[[ $image = /* ]] || image="$PWD/$image"
if [[ -e $image || -L $image ]]; then
    printf 'Image already exists: %s\n' "$image" >&2
    exit 1
fi

busybox_build="$ntp_dir/build/busybox"
onsyuri="$ntp_dir/build/onsyuri/onsyuri"
if (( install_busybox )) && [[ ! -x $busybox_build/busybox || ! -s $busybox_build/busybox.links ||
                              ! -f $busybox_build/applets/install.sh ]]; then
    printf 'Run make ARCH=riscv busybox first.\n' >&2
    exit 1
fi
if (( install_onsyuri )) && [[ ! -x $onsyuri ]]; then
    printf 'Run make ARCH=riscv onsyuri first.\n' >&2
    exit 1
fi

umask 022
work=$(mktemp -d "$(dirname -- "$image")/.mkimage.XXXXXXXX")
trap 'rm -rf -- "$work"' EXIT
root="$work/root"
mkdir -p "$root"/{bin,dev,etc,proc,root,sbin,usr/bin,usr/sbin}
install -d -m 1777 "$root/tmp"
printf '%s\n' '::respawn:/bin/sh' > "$root/etc/inittab"

if (( install_busybox )); then
    ( cd "$busybox_build" && sh applets/install.sh "$root" --symlinks )
fi
if (( install_onsyuri )); then
    install -m 755 "$onsyuri" "$root/root/onsyuri"
fi

tmp_image="$work/rootfs.img"
mke2fs -q -t ext2 -b 4096 -d "$root" "$tmp_image" 524288
LC_ALL=C debugfs -w -f /dev/stdin "$tmp_image" > /dev/null 2> "$work/debugfs.log" <<'EOF'
cd /dev
mknod console c 5 1
mknod input c 242 0
mknod gpu c 241 0
mknod audio c 240 0
EOF
if grep -v '^debugfs [0-9]' "$work/debugfs.log" >&2; then
    exit 1
fi
ln -T -- "$tmp_image" "$image"
printf 'Created %s\n' "$image"
