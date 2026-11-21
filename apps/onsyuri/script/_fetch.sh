# The ntp entry sets PORT_SOURCE_DIR; older Linux scripts use thirdparty/port.
PORT_SOURCE_DIR=${PORT_SOURCE_DIR:-"$CMAKELISTS_PATH/thirdparty/port"}

fetch_port()
{
    local name=$1 url=$2
    local archive="$PORT_SOURCE_DIR/$name.tar.gz" unpack="$PORT_SOURCE_DIR/.$name"
    if [[ -d $PORT_SOURCE_DIR/$name ]]; then
        return
    fi
    mkdir -p "$unpack" || return
    if [[ ! -f $archive ]]; then
        curl -fsSL --retry 2 -o "$archive.part" "$url" || return
        mv -- "$archive.part" "$archive" || return
    fi
    tar -xzf "$archive" --strip-components=1 -C "$unpack" || return
    mv -- "$unpack" "$PORT_SOURCE_DIR/$name"
}

fetch_lua()
{
    LUA_SRC="$PORT_SOURCE_DIR/lua-5.4.4"
    fetch_port "${LUA_SRC##*/}" https://www.lua.org/ftp/lua-5.4.4.tar.gz
}

fetch_jpeg()
{
    JPEG_SRC="$PORT_SOURCE_DIR/jpeg-9"
    fetch_port "${JPEG_SRC##*/}" http://www.ijg.org/files/jpegsrc.v9.tar.gz
}

fetch_bz2()
{
    BZ2_SRC="$PORT_SOURCE_DIR/bzip2-1.0.8"
    fetch_port "${BZ2_SRC##*/}" https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
}

fetch_freetype()
{
    FREETYPE_SRC="$PORT_SOURCE_DIR/freetype-2.13.3"
    fetch_port "${FREETYPE_SRC##*/}" https://codeload.github.com/freetype/freetype/tar.gz/refs/tags/VER-2-13-3
}

fetch_sdl2()
{
    SDL2_SRC="$PORT_SOURCE_DIR/SDL2-2.26.3"
    fetch_port "${SDL2_SRC##*/}" https://github.com/libsdl-org/SDL/releases/download/release-2.26.3/SDL2-2.26.3.tar.gz
}

fetch_sdl2_image()
{
    SDL2_IMAGE_SRC="$PORT_SOURCE_DIR/SDL2_image-2.6.3"
    fetch_port "${SDL2_IMAGE_SRC##*/}" https://codeload.github.com/libsdl-org/SDL_image/tar.gz/refs/tags/release-2.6.3
}

fetch_sdl2_ttf()
{
    SDL2_TTF_SRC="$PORT_SOURCE_DIR/SDL2_ttf-2.20.2"
    fetch_port "${SDL2_TTF_SRC##*/}" https://github.com/libsdl-org/SDL_ttf/releases/download/release-2.20.2/SDL2_ttf-2.20.2.tar.gz
}

fetch_sdl2_mixer()
{
    SDL2_MIXER_SRC="$PORT_SOURCE_DIR/SDL2_mixer-2.6.3"
    fetch_port "${SDL2_MIXER_SRC##*/}" https://codeload.github.com/libsdl-org/SDL_mixer/tar.gz/refs/tags/release-2.6.3
}
