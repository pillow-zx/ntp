# NTP

NTP provides userspace ports and QEMU boot tools for Nuvix on RISC-V. BusyBox supplies the guest shell; SDL2 and OnsYuri are optional.

## Build and boot

From this directory, use GNU Make, Git, a RISC-V Linux GNU cross-toolchain (`riscv64-linux-gnu-` by default), e2fsprogs, and `qemu-system-riscv64`. Build the Nuvix kernel separately and adjust the kernel path below as needed.

```sh
make ARCH=riscv busybox
./scripts/mkimage.sh --output=guest.img --install-busybox
./scripts/qemu.sh --kernel=../nuvix/nuvix.bin --img=guest.img
```

`mkimage.sh` creates a new ext2 image and leaves existing images untouched. QEMU starts with a serial console, one CPU, and 512 MiB of RAM. See `./scripts/qemu.sh --help` for options.

## Build OnsYuri

Build the Nuvix SDL2 port before OnsYuri. These targets also need CMake, pkg-config, and a RISC-V C++ cross-compiler. The first build fetches third-party sources.

```sh
make ARCH=riscv sdl2
make ARCH=riscv onsyuri
```

Add `--install-onsyuri` when creating a new image to install `/root/onsyuri`. Add `--gui` when launching QEMU for GTK display and input, and `--audio` for sound through PulseAudio.
