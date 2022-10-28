#! /bin/bash

set -exo pipefail

REPO_ROOT="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")"/..)"

docker run --rm -i -v "$REPO_ROOT":/ws -w /ws "$DOCKER_ARCH_PREFIX"alpine:latest <<\EOF

apk add g++ cmake ninja bash git

bash ci/install-argagg.sh

bash ci/build.sh
EOF
