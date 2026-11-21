ARCH ?= riscv
V ?= 0

.DEFAULT_GOAL := all

BUILD := $(CURDIR)/build
SDL2_PREFIX := $(BUILD)/sdl2
CMAKE_POLICY := -DCMAKE_POLICY_VERSION_MINIMUM=3.5

ifeq ($(V),1)
Q :=
CMAKE_VERBOSE := --verbose
else
Q := @
endif

ifeq ($(ARCH),riscv)
include scripts/riscv.mk
else ifeq ($(ARCH),native)
include scripts/native.mk
else
$(error Unsupported ARCH=$(ARCH); use native or riscv)
endif

include libs/sdl2.mk
include apps/apps.mk

.PHONY: all clean
all: onsyuri

clean:
	$(Q)rm -rf -- "$(BUILD)"
