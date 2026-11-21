cmake_minimum_required(VERSION 3.21)
project(onsyuri LANGUAGES C CXX)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "onsyuri only supports Linux targets in ntp")
endif()

option(ONSYURI_STATIC "Link onsyuri statically" OFF)
if(ONSYURI_STATIC)
    set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    find_package(SDL2 CONFIG REQUIRED COMPONENTS SDL2-static)
    find_package(SDL2_image CONFIG REQUIRED)
    find_package(SDL2_ttf CONFIG REQUIRED)
    find_package(SDL2_mixer CONFIG REQUIRED)
else()
    find_package(SDL2 CONFIG REQUIRED COMPONENTS SDL2)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(SDL2_EXT REQUIRED IMPORTED_TARGET SDL2_image SDL2_ttf SDL2_mixer)
endif()
find_path(LUA_INCLUDE_DIR NAMES lua.hpp REQUIRED)
find_library(LUA_LIBRARY NAMES lua REQUIRED)
find_package(BZip2 REQUIRED)
find_package(Threads REQUIRED)

add_executable(onsyuri
    src/AnimationInfo.cpp
    src/coding2utf16.cpp
    src/DirectReader.cpp
    src/DirtyRect.cpp
    src/FontInfo.cpp
    src/gbk2utf16.cpp
    src/LUAHandler.cpp
    src/NsaReader.cpp
    src/ONScripter.cpp
    src/ONScripter_animation.cpp
    src/ONScripter_command.cpp
    src/ONScripter_effect.cpp
    src/ONScripter_effect_breakup.cpp
    src/ONScripter_event.cpp
    src/ONScripter_file.cpp
    src/ONScripter_file2.cpp
    src/ONScripter_image.cpp
    src/ONScripter_lut.cpp
    src/onscripter_main.cpp
    src/ONScripter_rmenu.cpp
    src/ONScripter_sound.cpp
    src/ONScripter_text.cpp
    src/Parallel.cpp
    src/resize_image.cpp
    src/SarReader.cpp
    src/ScriptHandler.cpp
    src/ScriptParser.cpp
    src/ScriptParser_command.cpp
    src/sjis2utf16.cpp
    src/builtin_dll/layer_oldmovie.cpp
    src/builtin_dll/layer_snow.cpp
    src/builtin_dll/ONScripter_effect_cascade.cpp
    src/builtin_dll/ONScripter_effect_trig.cpp
)
set_target_properties(onsyuri PROPERTIES CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON)
target_compile_definitions(onsyuri PRIVATE
    LINUX
    USE_PARALLEL
    USE_FILELOG
    USE_LUA
    USE_BUILTIN_LAYER_EFFECTS
    ENABLE_1BYTE_CHAR
)
target_include_directories(onsyuri PRIVATE ${LUA_INCLUDE_DIR})
if(ONSYURI_STATIC)
    target_link_options(onsyuri PRIVATE -static)
    target_link_libraries(onsyuri PRIVATE
        SDL2_image::SDL2_image-static
        SDL2_ttf::SDL2_ttf-static
        SDL2_mixer::SDL2_mixer-static
        SDL2::SDL2-static
    )
else()
    target_link_libraries(onsyuri PRIVATE SDL2::SDL2 PkgConfig::SDL2_EXT)
endif()
target_link_libraries(onsyuri PRIVATE
    ${LUA_LIBRARY}
    m
    BZip2::BZip2
    Threads::Threads
)
install(TARGETS onsyuri RUNTIME DESTINATION bin)
