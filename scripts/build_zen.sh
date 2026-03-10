get_blis() {
    cd "$1" || exit 1
    git clone https://github.com/amd/blis.git  --jobs 24
    cd blis || exit 1
    git submodule update --init --recursive --jobs 24
    bash configure "$3"  --prefix="$2"
    make -j32
    sudo make install
    cd "$1" || exit 1
}
get_zendnn() {
    cd "$1" || exit 1
    git clone https://github.com/amd/ZenDNN.git --jobs 24
    cd ZenDNN || exit 1
    git submodule update --init --recursive --jobs 24
    cmake .
    cmake --build . --parallel 32
    sudo cmake --install . --prefix "$2"
    cd "$1" || exit 1
}

get_pyzendnn() {
    cd "$1" || exit 1
    git clone https://github.com/amd/ZenDNN-pytorch-plugin.git --jobs 5
    cd ZenDNN-pytorch-plugin || exit 1
    git submodule update --init --recursive --jobs 5
    cd "$1" || exit 1
}