# bash -c "export BUILD_TYPE=Debug && export SKIP_PORTS=1 && ./cross_linuxr64.sh"
PLATFORM=linuxr64
CMAKELISTS_PATH=$(pwd)/..
BUILD_PATH=$CMAKELISTS_PATH/../../build/onsyuri
PORTBUILD_PATH=$CMAKELISTS_PATH/thirdparty/build/arch_$PLATFORM
CORE_NUM=$(cat /proc/cpuinfo | grep -c ^processor)
TARGETS=$@

CC=${CC:-riscv64-linux-gnu-gcc}
CXX=${CXX:-riscv64-linux-gnu-g++}
AR=${AR:-riscv64-linux-gnu-ar}
RANLIB=${RANLIB:-riscv64-linux-gnu-ranlib}
HOST=$($CC -dumpmachine)
SDL2_PREFIX=${SDL2_PREFIX:-$CMAKELISTS_PATH/../../build/sdl2}
export PKG_CONFIG_LIBDIR="$PORTBUILD_PATH/lib/pkgconfig:$SDL2_PREFIX/lib/pkgconfig"

# SKIP_PORTS="yes"
# sdl2 has too many bindings to system, 
# so just compile these libs in the target machine and link the build cache
echo "## PORTBUILD_PATH=$PORTBUILD_PATH"
if [ -z "$SKIP_PORTS" ]; then
    source _fetch.sh
    source _$PLATFORM.sh
    # https://swarminglogic.com/article/2014_11_crosscompile2
    mkdir -p "$PORTBUILD_PATH/include" "$PORTBUILD_PATH/lib"
    fetch_bz2 && build_bz2
    fetch_lua && build_lua
    fetch_sdl2_image && build_sdl2_image 
    fetch_sdl2_ttf && build_sdl2_ttf
    fetch_sdl2_mixer && build_sdl2_mixer
fi

# config and build project
if [ -z "$BUILD_TYPE" ]; then BUILD_TYPE=MinSizeRel; fi
if [ -z "$TARGETS" ]; then TARGETS=all; fi
echo "BUILD_TYPE=$BUILD_TYPE"
cmake -B "$BUILD_PATH" -S "$CMAKELISTS_PATH" \
    -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" \
    -DCMAKE_SYSTEM_NAME=Linux -DONSYURI_STATIC=ON \
    -DCMAKE_PREFIX_PATH="$PORTBUILD_PATH;$SDL2_PREFIX" \
    -DSDL2_DIR="$SDL2_PREFIX/lib/cmake/SDL2"
make -C $BUILD_PATH $TARGETS -j$CORE_NUM
