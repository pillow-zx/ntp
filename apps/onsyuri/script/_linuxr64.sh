# must use after _fetch.sh from cross_linuxr64.sh

function build_lua()
{
    echo "## LUA_SRC=$LUA_SRC"
    
    make -C "$LUA_SRC/src" clean
    make -C "$LUA_SRC/src" liblua.a CC="$CC" AR="$AR rcu" RANLIB="$RANLIB" MYCFLAGS=-DLUA_USE_POSIX -j"$CORE_NUM"
    install -m644 "$LUA_SRC/src"/{lua.h,lua.hpp,lauxlib.h,luaconf.h,lualib.h} "$PORTBUILD_PATH/include/"
    install -m644 "$LUA_SRC/src/liblua.a" "$PORTBUILD_PATH/lib/"
}

function build_bz2()
{
    echo "## BZ2_SRC=$BZ2_SRC"
    
    make -C "$BZ2_SRC" clean
    make -C "$BZ2_SRC" libbz2.a CC="$CC" AR="$AR" RANLIB="$RANLIB" -j"$CORE_NUM"
    install -m644 "$BZ2_SRC/bzlib.h" "$PORTBUILD_PATH/include/"
    install -m644 "$BZ2_SRC/libbz2.a" "$PORTBUILD_PATH/lib/"
}

# after build_sdl2
function build_sdl2_image() 
{
    if ! [ -d "${SDL2_IMAGE_SRC}/build_${PLATFORM}" ]; then mkdir -p "${SDL2_IMAGE_SRC}/build_${PLATFORM}"; fi
    echo "## SDL2_IMAGE_SRC=$SDL2_IMAGE_SRC"

    pushd "${SDL2_IMAGE_SRC}/build_${PLATFORM}"
    CC="$CC" ../configure --host="$HOST" --with-sdl-prefix="$SDL2_PREFIX" \
        --disable-shared --enable-static \
        --enable-stb-image --disable-save-jpg --disable-save-png \
        --prefix="$PORTBUILD_PATH"
    make -j$CORE_NUM &&  make install
    popd
}

# after build_sdl2
function build_sdl2_ttf() 
{
    if ! [ -d "${SDL2_TTF_SRC}/build_${PLATFORM}" ]; then mkdir -p "${SDL2_TTF_SRC}/build_${PLATFORM}"; fi
    echo "## SDL2_TTF_SRC=$SDL2_TTF_SRC"

    # harfbuzz makes very large 
    pushd "${SDL2_TTF_SRC}/build_${PLATFORM}"
    CC="$CC" ../configure --host="$HOST" --with-sdl-prefix="$SDL2_PREFIX" \
        --disable-shared --enable-static --disable-harfbuzz \
        --prefix="$PORTBUILD_PATH"
    make -j$CORE_NUM && make install 
    popd
}

# after build_sdl2
function build_sdl2_mixer() 
{
    if ! [ -d "${SDL2_MIXER_SRC}/build_${PLATFORM}" ]; then mkdir -p "${SDL2_MIXER_SRC}/build_${PLATFORM}"; fi
    echo "## SDL2_MIXER_SRC=$SDL2_MIXER_SRC"

    pushd "${SDL2_MIXER_SRC}/build_${PLATFORM}"
    CC="$CC" ../configure --host="$HOST" --with-sdl-prefix="$SDL2_PREFIX" \
        --disable-shared --enable-static \
        --disable-music-cmd --disable-music-mod --disable-music-midi --disable-music-opus \
        --prefix="$PORTBUILD_PATH"
    make -j$CORE_NUM && make install 
    popd
}