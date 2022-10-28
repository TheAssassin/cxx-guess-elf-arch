cmake_minimum_required(VERSION 3.16)

project(cxx-guess-elf-arch)

set(CMAKE_CXX_VERSION 17)
set(CMAKE_CXX_VERSION_REQUIRED ON)

include(CheckIncludeFileCXX)

# this dependency does not come with a pkg-config file or CMake config, so we try to compile a file instead
check_include_file_cxx(argagg/argagg.hpp HAVE_ARGAGG)
if(NOT HAVE_ARGAGG)
    message(FATAL_ERROR "${ARGAGG_OUT} argagg header not found on system, please install")
endif()

add_subdirectory(src)
