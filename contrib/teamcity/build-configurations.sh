#!/usr/bin/env bash

export LC_ALL=C

set -euxo pipefail

if [ -z "$ABC_BUILD_NAME" ]; then
  echo "Error: Environment variable ABC_BUILD_NAME must be set"
  exit 1
fi

echo "Running build configuration '${ABC_BUILD_NAME}'..."

TOPLEVEL=$(git rev-parse --show-toplevel)
cd "${TOPLEVEL}/contrib/teamcity"

case "$ABC_BUILD_NAME" in
  build-asan)
    export CONFIGURE_FLAGS="--enable-debug --with-sanitizers=address --disable-ccache"
    ./build.sh
    ;;

  build-ubsan)
    export CONFIGURE_FLAGS="--enable-debug --with-sanitizers=undefined --disable-ccache CC=clang CXX=clang++"
    ./build.sh
    ;;

  build-default)
    ./build.sh
    ./build-secp256k1.sh
    ;;

  build-without-wallet)
    export DISABLE_WALLET=1
    ./build.sh
    ;;

  build-ibd)
    export DISABLE_TESTS=1
    ./build.sh
    ./ibd.sh -disablewallet
    ;;

  build-ibd-no-assumevalid-checkpoint)
    export DISABLE_TESTS=1
    ./build.sh
    ./ibd.sh -disablewallet -assumevalid=0 -checkpoints=0
    ;;

  *)
    echo "Error: Invalid build name '${ABC_BUILD_NAME}'"
    exit 2
    ;;
esac
