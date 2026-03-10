get_blis() {
    cd "$1" || exit 1
    git clone https://github.com/amd/blis.git  --jobs 24
    cd blis || exit 1
    git checkout 9734fc18cc51abd06b99862820d7ebc3e1c35e51
    git submodule update --init --recursive --jobs 24
    bash configure "$3"  --prefix="$2"
    make -j32
    make install
    cd "$1" || exit 1
}
get_zendnn() {
    cd "$1" || exit 1
    git clone https://github.com/amd/ZenDNN.git --jobs 24
    cd ZenDNN || exit 1
    git submodule update --init --recursive --jobs 24
    cmake .
    cmake --build . --parallel 32
    cmake --install . --prefix "$2"
    cd "$1" || exit 1
}
get_magma() {
    cd "$1" || exit 1
    git clone https://github.com/icl-utk-edu/magma.git --jobs 5
    cd magma || exit 1
    git submodule update --init --recursive --jobs 5
    mkdir build
    cd build || exit 1
    cmake ..
    cmake --build . --parallel 32
    cmake --install . --prefix "$2"
    cd "$1" || exit 1
}
get_pyzendnn() {
    cd "$1" || exit 1
    git clone https://github.com/amd/ZenDNN-pytorch-plugin.git --jobs 5
    cd ZenDNN-pytorch-plugin || exit 1
    git submodule update --init --recursive --jobs 5
    cd "$1" || exit 1
}