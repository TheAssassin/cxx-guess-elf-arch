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

trap cleanup EXIT

# store repo root as variable
REPO_ROOT="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")"/..)"
OLD_CWD="$(readlink -f .)"

pushd "$BUILD_DIR"

cmake "$REPO_ROOT" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo

ninja

mv src/gea .

arch="$(./gea gea)"
mv gea gea-"$arch"

mv gea-"$arch" "$OLD_CWD"
