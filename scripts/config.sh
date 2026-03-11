torchrelease="release/2.10"
visionrelease="release/0.26"  # Matches PyTorch 2.10
rocmdir="$HOME/.local/rocm"   ## where to install the rocm tarball
wheeldir="$PWD/output" ## Built wheels go here
prefix=$rocmdir # This is for the zen libs install location
buildroot="$PWD" #"$(mktemp -d -p "$PWD" build.XXXXXX)"

