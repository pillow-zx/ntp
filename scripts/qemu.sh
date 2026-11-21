#!/usr/bin/env bash
set -euo pipefail

usage()
{
    printf '%s\n' \
        "Usage: $0 --kernel=FILE --img=FILE [OPTIONS]" \
        '  --cpu=N    Number of virtual CPUs (default: 1)' \
        '  --mem=SIZE Memory in MiB, or with an M/G suffix (default: 512M)' \
        '  --gui      Enable GTK display, VirtIO GPU, keyboard, and mouse' \
        '  --audio    Enable VirtIO sound via PulseAudio' \
        '  --help     Show this help'
}

kernel=
image=
cpu=1
mem=512M
gui=0
audio=0
for arg in "$@"; do
    case $arg in
        --kernel=?*) kernel=${arg#*=} ;;
        --img=?*) image=${arg#*=} ;;
        --cpu=?*) cpu=${arg#*=} ;;
        --mem=?*) mem=${arg#*=} ;;
        --gui) gui=1 ;;
        --audio) audio=1 ;;
        --help) usage; exit 0 ;;
        *) printf 'Invalid argument: %s\n' "$arg" >&2; usage >&2; exit 1 ;;
    esac
done

if [[ -z $kernel || -z $image ]]; then
    usage >&2
    exit 1
fi
if [[ ! $cpu =~ ^[1-9][0-9]*$ ]]; then
    printf 'Invalid --cpu: %s (expected a positive integer)\n' "$cpu" >&2
    exit 1
fi
if [[ ! $mem =~ ^[1-9][0-9]*[MG]?$ ]]; then
    printf 'Invalid --mem: %s (use a positive size such as 512M or 1G)\n' "$mem" >&2
    exit 1
fi

args=(
    -machine virt -nodefaults
    -smp "$cpu" -m "$mem"
    -global virtio-mmio.force-legacy=false
    -kernel "$kernel"
    -drive "file=${image//,/,,},format=raw,if=none,id=rootfs"
    -device virtio-blk-device,drive=rootfs
    -serial mon:stdio
)

if (( gui )); then
    args+=(-display gtk -device virtio-gpu-device
           -device virtio-keyboard-device -device virtio-mouse-device)
else
    args+=(-nographic)
fi
if (( audio )); then
    args+=(-audiodev pa,id=snd0 -device virtio-sound-device,audiodev=snd0)
fi

exec qemu-system-riscv64 "${args[@]}"
