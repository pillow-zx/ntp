SDL2_TAG := release-2.32.10
SDL2_SRC := $(BUILD)/sdl2/src
SDL2_BUILD := $(BUILD)/sdl2/cmake
SDL2_PATCH := $(CURDIR)/libs/sdl2-nuvix.patch
SDL2_READY := $(SDL2_SRC)/.nuvix-patched

# Some SDL2 sources read the dynapi switch before including SDL_config.h.
SDL2_FLAGS := \
	-DCMAKE_C_FLAGS="$(CFLAGS) -DDYNAPI_NEEDS_DLOPEN=1" \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_BUILD_TYPE=Release \
	-DSDL_SHARED=OFF \
	-DSDL_STATIC=ON \
	-DSDL_TEST=OFF \
	-DSDL_DUMMYVIDEO=OFF \
	-DSDL_OFFSCREEN=OFF \
	-DSDL_OPENGL=OFF \
	-DSDL_OPENGLES=OFF \
	-DSDL_VULKAN=OFF \
	-DSDL_RPI=OFF \
	-DSDL_KMSDRM=OFF \
	-DSDL_DUMMYAUDIO=OFF \
	-DSDL_ALSA=OFF \
	-DSDL_OSS=OFF \
	-DSDL_PULSEAUDIO=OFF \
	-DSDL_PIPEWIRE=OFF \
	-DSDL_JACK=OFF \
	-DSDL_SNDIO=OFF \
	-DSDL_ESD=OFF \
	-DSDL_ARTS=OFF \
	-DSDL_NAS=OFF \
	-DSDL_LIBSAMPLERATE=OFF \
	-DSDL_DBUS=OFF \
	-DSDL_IBUS=OFF \
	-DSDL_LIBUDEV=OFF \
	-DSDL_HIDAPI=OFF \
	-DSDL_JOYSTICK=OFF \
	-DSDL_HAPTIC=OFF \
	-DSDL_LOADSO=OFF \
	-DHAVE_DLOPEN_IN_LIBC=OFF \
	-DHAVE_DLOPEN_IN_LIBDL=OFF

$(SDL2_READY): $(SDL2_PATCH) libs/sdl2.mk
	$(Q)set -e; mkdir -p "$(BUILD)/sdl2"; \
	work=$$(mktemp -d "$(BUILD)/sdl2/.fetch.XXXXXXXX"); \
	trap 'rm -rf -- "$$work"' EXIT; \
	git -c advice.detachedHead=false clone --depth 1 --branch "$(SDL2_TAG)" \
		https://github.com/libsdl-org/SDL.git "$$work/src"; \
	git -C "$$work/src" apply "$(SDL2_PATCH)"; \
	rm -rf -- "$(SDL2_SRC)"; \
	mv -- "$$work/src" "$(SDL2_SRC)"; \
	touch "$@"

.PHONY: sdl2
sdl2: $(SDL2_READY)
	$(Q)set -e; ar=$$(command -v "$(AR)"); ranlib=$$(command -v "$(RANLIB)"); \
	$(SDL2_CONFIG_ENV) cmake -S "$(SDL2_SRC)" -B "$(SDL2_BUILD)" $(CMAKE_POLICY) \
		-DCMAKE_C_COMPILER="$(CC)" -DCMAKE_AR="$$ar" -DCMAKE_RANLIB="$$ranlib" \
		-DCMAKE_INSTALL_PREFIX="$(SDL2_PREFIX)" $(SDL2_FLAGS) $(SDL2_PLATFORM_FLAGS)
	$(Q)cmake --build "$(SDL2_BUILD)" --parallel 8 $(CMAKE_VERBOSE)
	$(Q)cmake --install "$(SDL2_BUILD)"
	$(Q)set -e; for driver in $(SDL2_REQUIRED_DRIVERS); do \
		grep -q "^#define $$driver 1$$" "$(SDL2_PREFIX)/include/SDL2/SDL_config.h" || \
			{ printf 'SDL2 required driver was not built: %s\n' "$$driver" >&2; exit 1; }; \
	done
