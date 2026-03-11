#!/bin/bash

get_release() {
    mkdir -p "$1"
    echo "Downloading $3"
    curl -sL "$2" | tar -xz -C "$1" --strip-components=1
    
    if [ $? -eq 0 ]; then
        echo "ROCm installed to $1"
    else
        echo "$2"
        exit 1
    fi
}
get_torch() {
    cd "$2" || exit 1
    git clone --depth 1 --branch $1 --single-branch https://github.com/ROCm/pytorch.git --jobs 24 || true
    cd pytorch || exit 1
    git submodule update --init --recursive --jobs 24 || true
    cd "$2" || exit 1
}
get_torchaudio() {
    cd "$2" || exit 1
    git clone --depth 1 --branch $1 --single-branch https://github.com/pytorch/audio.git --jobs 16 || true
    cd audio || exit 1
    git submodule update --init --recursive --jobs 16 || true
    cd "$2" || exit 1
}
get_torchvision() {
    cd "$2" || exit 1
    git clone --depth 1 --branch $1 --single-branch https://github.com/pytorch/vision.git --jobs 16 || true
    cd vision || exit 1
    git submodule update --init --recursive --jobs 16 || true
}
get_latest_nightly_rocm() {
    PATTERN="therock-dist-linux-gfx101X-dgpu"
    URL="https://rocm.nightlies.amd.com/tarball/"

    LATEST_PACKAGE=$(curl -s "$URL" | \
        grep -oP "$PATTERN"'-[0-9a-z.]+\.tar\.gz' | \
        sort -V | \
        tail -n 1)

    get_release "$1" "$URL$LATEST_PACKAGE" "$LATEST_PACKAGE"
}

get_known_working_rocm() {
    get_release "$1" "https://rocm.nightlies.amd.com/tarball/therock-dist-linux-gfx101X-dgpu-7.12.0a20260310.tar.gz" "therock-dist-linux-gfx101X-dgpu-7.12.0a20260310.tar.gz"
}