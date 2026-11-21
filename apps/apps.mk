BUSYBOX_SRC := $(BUILD)/busybox
BUSYBOX_MAKE = $(MAKE) -C "$(BUSYBOX_SRC)" ARCH="$(BUSYBOX_ARCH)" CROSS_COMPILE="$(BUSYBOX_CROSS_COMPILE)" CC="$(CC)"
ONSYURI_ENV := CC="$(CC)" CXX="$(CXX)"

ifeq ($(ARCH),riscv)
BUSYBOX_ARCH := riscv
BUSYBOX_CROSS_COMPILE := $(CROSS_COMPILE)
ONSYURI_SCRIPT := riscv-linux.sh
ONSYURI_ENV += AR="$(AR)" RANLIB="$(RANLIB)" SDL2_PREFIX="$(SDL2_PREFIX)"
else
BUSYBOX_ARCH := $(shell uname -m)
BUSYBOX_CROSS_COMPILE :=
ONSYURI_SCRIPT := native-linux.sh
endif

.PHONY: onsyuri busybox
onsyuri:
	$(Q)cd apps/onsyuri/script && $(ONSYURI_ENV) BUILD_TYPE=Release bash $(ONSYURI_SCRIPT)

busybox: $(BUSYBOX_SRC)/.config
	$(BUSYBOX_MAKE) busybox
	$(BUSYBOX_MAKE) busybox.links

$(BUSYBOX_SRC)/.config: apps/nuvix-busybox.config $(BUSYBOX_SRC)/.git
	$(Q)cp -- "$<" "$@"

$(BUSYBOX_SRC)/.git:
	$(Q)set -e; mkdir -p "$(BUILD)"; \
	work=$$(mktemp -d "$(BUILD)/.busybox.XXXXXXXX"); \
	trap 'rm -rf -- "$$work"' EXIT; \
	git -c advice.detachedHead=false clone --depth 1 --branch 1_38_0 \
		https://git.busybox.net/busybox "$$work/src"; \
	rm -rf -- "$(BUSYBOX_SRC)"; \
	mv -- "$$work/src" "$(BUSYBOX_SRC)"
