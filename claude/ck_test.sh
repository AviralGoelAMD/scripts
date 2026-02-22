#!/usr/bin/env bash
# CK build/run step runner — executed remotely via:
#   ssh ... "bash -s STEP ARCH WORK_DIR BRANCH TARGET [NINJA_JOBS] [TIMEOUT]" < ~/.claude/ck_test.sh
#
# Steps: clone | cmake | ninja | run

set -euo pipefail

STEP=${1:?step required: clone|cmake|ninja|run}
ARCH=${2:?arch required, e.g. gfx950}
WORK_DIR=${3:?work_dir required}
BRANCH=${4:?branch required}
TARGET=${5:?target required}
NINJA_JOBS=${6:-256}
TIMEOUT=${7:-300}

CLONE_DIR=rocm-libraries
CK_SOURCE="$WORK_DIR/$CLONE_DIR/projects/composablekernel"
DOCKER_IMAGE=rocm/composable_kernel:ck_ub24.04_rocm7.1.1
DOCKER_FLAGS=(
  --rm --network host
  --device=/dev/kfd --device=/dev/dri
  --ipc=host --group-add video
  --security-opt seccomp=unconfined
  -w /root/workspace
  -v "$CK_SOURCE":/root/workspace
)

case "$STEP" in
  clone)
    mkdir -p "$WORK_DIR" && cd "$WORK_DIR"
    if [ -d "$CLONE_DIR/.git" ]; then
      cd "$CLONE_DIR"
      git fetch origin
      git checkout "$BRANCH"
      git reset --hard "origin/$BRANCH"
    else
      rm -rf "$CLONE_DIR"
      source ~/.my_docker_bashrc
      clone ck "$BRANCH"
    fi
    ;;

  cmake)
    docker run "${DOCKER_FLAGS[@]}" \
      -v ~/.my_docker_bashrc:/root/.my_docker_bashrc \
      "$DOCKER_IMAGE" \
      /bin/bash -c "set -e && source /root/.my_docker_bashrc && rm -rf build && mkdir -p build && cd build && ninja_build $ARCH"
    ;;

  ninja)
    docker run "${DOCKER_FLAGS[@]}" "$DOCKER_IMAGE" \
      /bin/bash -c "cd build && ninja -j$NINJA_JOBS $TARGET"
    ;;

  run)
    docker run "${DOCKER_FLAGS[@]}" "$DOCKER_IMAGE" \
      /bin/bash -c "cd build && timeout $TIMEOUT ./bin/$TARGET"
    ;;

  *)
    echo "Unknown step: $STEP" >&2
    exit 1
    ;;
esac
