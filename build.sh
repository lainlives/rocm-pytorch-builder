#!/usr/bin/bash

#
#
# There are a lot of git calls in this its probably best to be signed into github
#
#
pyver=$1
if [ -z "$1" ]; then
    pyver=$(python3 --version | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
fi
############### Fedora packages
sudo dnf install -y gmake zlib xz python3-devel gcc14* cmake git python$pyver 
sudo rpm -e --nodeps gcc  ## For a lot of projects around ROCm at the moment this simply existing on the system is a nogo.
ln -s /usr/bin/gcc-14 /usr/bin/gcc
ln -s /usr/bin/gcc-14 /usr/bin/cc
ln -s /usr/bin/g++-14 /usr/bin/g++
ln -s /usr/bin/g++-14 /usr/bin/c++
############### Keep it readable
thisdir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
scriptdir="$thisdir/scripts"
source "$scriptdir/get_files.sh"  || source ./scripts/get_files.sh
source "$scriptdir/venv.sh"  || source ./scripts/venv.sh
source "$scriptdir/build_zen.sh"  || source ./scripts/build_zen.sh
source "$scriptdir/config.sh"  || source ./scripts/config.sh
echo "$buildroot"

mkdir -p "$buildroot"
mkdir -p "$wheeldir"
cd "$buildroot" || exit 1
mkdir -p "$rocmdir" || true

############### Setup venv
mkvenv "$pyver" "$buildroot"
activatevenv "$pyver" "$buildroot"



############### Get ROCM and PyTorch then hipify and patch for gfx1010 build
get_known_working_rocm "$rocmdir"
# get_latest_nightly_rocm "$rocmdir"
get_pyzendnn "$buildroot" # Stuff for zendnn, AMD CPU stuff you can skip it
get_torchaudio "$torchrelease" "$buildroot"
get_torchvision "$visionrelease" "$buildroot"
get_torch "$torchrelease" "$buildroot"
cd pytorch || exit 1
python tools/amd_build/build_amd.py
cd "$buildroot" || exit 1
source "$scriptdir/config.sh"
source "$scriptdir/env.sh"


############### Build Zen CPU compute libs

# Stuff for Zen CPUs realistically you can skip this or change the CPU its optimizing for, these libs are most optimized for AMD though
# If you have an Intel install MKL, IPEX, and intel-extension-for-pytorch
# By default they will be skipped if they fail to build
get_blis "$buildroot" "$prefix" zen2 || true
get_zendnn "$buildroot" "$prefix" || true
get_magma "$buildroot" "$prefix" || true
# 

############### Build
unset CMAKE_INSTALL_PREFIX
set_rocm_env "$rocmdir"
validate_rocm_env

cd pytorch || exit 1
python -m build -w || exit 1
python -m pip install dist/*.whl
mv dist/* "$wheeldir/$pyver" || exit 1
cd "$buildroot" || exit 1

cd audio || exit 1
python -m build -w || exit 1
mv dist/* "$wheeldir/$pyver" || exit 1
cd "$buildroot" || exit 1

cd vision || exit 1
python -m build -w || exit 1
mv dist/* "$wheeldir/$pyver" || exit 1
cd "$buildroot" || exit 1

cd ZenDNN-pytorch-plugin || exit 0
python -m build -w || exit 0
mv dist/* "$wheeldir/$pyver" || exit 0
cd "$buildroot" || exit 0
