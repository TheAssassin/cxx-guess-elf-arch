#! /bin/bash

set -exo pipefail

# use RAM disk if possible
if [ -d /dev/shm ] && mount | grep /dev/shm | grep -v -q noexec; then
    TEMP_BASE=/dev/shm
elif [ -d /docker-ramdisk ]; then
    TEMP_BASE=/docker-ramdisk
else
    TEMP_BASE=/tmp
fi

BUILD_DIR="$(mktemp -d -p "$TEMP_BASE" gea-build-XXXXXX)"

cleanup() {
    [[ -d "$BUILD_DIR" ]] && rm -rf "$BUILD_DIR"
}

# store repo root as variable
REPO_ROOT="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")"/..)"
OLD_CWD="$(readlink -f .)"

pushd "$BUILD_DIR"

git clone https://github.com/vietjtnguyen/argagg -b 0.4.6
cd argagg

mkdir build
cd build

cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -GNinja -DARGAGG_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr
ninja -j "$(nproc --ignore=1)" install

popd
