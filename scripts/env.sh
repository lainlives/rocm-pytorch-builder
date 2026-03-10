set_rocm_env() {
    ROCM_PATH="$1"
    
    if [ ! -d "$ROCM_PATH" ]; then
        echo "ERROR: Base ROCM_PATH not found: $ROCM_PATH"
        return 1
    fi

    export ROCM_PATH
    export HIP_PLATFORM=amd
    export HIP_ROOT_DIR="$ROCM_PATH"
    export HIP_PATH="$ROCM_PATH"
    export HIP_CLANG_PATH="$ROCM_PATH/llvm/bin"
    export HIP_INCLUDE_PATH="$ROCM_PATH/include"
    export HIP_LIB_PATH="$ROCM_PATH/lib"
    ROCM_SUBDIRS=$(find "$ROCM_PATH/lib/cmake" "-maxdepth" 1 "-mindepth" 1 "-type" d | paste "-sd" ":" -)
    export CMAKE_PREFIX_PATH="$ROCM_SUBDIRS:$ROCM_PATH/lib/cmake"
    export CMAKE_MODULE_PATH="$CMAKE_PREFIX_PATH"
    export HIP_DEVICE_LIB_PATH="$ROCM_PATH/lib/llvm/amdgcn/bitcode"
    export PATH="$ROCM_PATH/../_rocm_sdk_core/bin:$ROCM_PATH/bin:$HIP_CLANG_PATH:$PATH"
    export LD_LIBRARY_PATH=":$HIP_LIB_PATH:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib:/usr/lib:/usr/lib64"
    export LIBRARY_PATH=":$HIP_LIB_PATH:$ROCM_PATH/lib64:/lib64:/lib:/usr/lib64/ffmpeg:/lib:/etc:/usr/lib:/usr/lib64" 
    export CPATH="$HIP_INCLUDE_PATH:${CPATH:-}"
    export PKG_CONFIG_PATH="$ROCM_PATH/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    

    export PYTORCH_ROCM_ARCH="gfx1010"
    export MAKEFLAGS="-j32"

    export USE_ROCM=1
    export USE_CUDA=0
    export BUILD_TEST=0
    export USE_KINETO=0
    export USE_ROCTRACER=0
    export USE_TENSORPIPE=0
    export USE_FBGEMM_GENAI=0
    export USE_ROCM_CK_SDPA=0
    export USE_ROCM_CK_GEMM=0
    export USE_FLASH_ATTENTION=0
    export USE_MEM_EFF_ATTENTION=0
    export USE_COMPOSABLE_KERNEL=0
    export USE_CK_FLASH_ATTENTION=0
    export CMAKE_POLICY_VERSION_MINIMUM=3.5

}




validate_rocm_env() {
    local vars_to_check=("HIP_CLANG_PATH" "HIP_INCLUDE_PATH" "HIP_LIB_PATH" "HIP_DEVICE_LIB_PATH" "ROCM_CMAKE_PATH")
    for var in "${vars_to_check[@]}"; do
        local dir_path="${!var}"
        if [ ! -d "$dir_path" ]; then
            echo "ERROR: Path in \$$var does not exist: $dir_path"
        fi
    done


    # Validate HIP_DEVICE_LIB_PATH for the specific gfx1010 bitcode
    if [ ! -f "$HIP_DEVICE_LIB_PATH/ocml.amdgcn.bc" ] && [ ! -f "$HIP_DEVICE_LIB_PATH/library.bc" ]; then
         # Generic check for directory existence first
         [ ! -d "$HIP_DEVICE_LIB_PATH" ] && echo "ERROR: HIP_DEVICE_LIB_PATH directory missing."
    fi
    
    if ! ls "$HIP_DEVICE_LIB_PATH"/*gfx1010.bc >/dev/null 2>&1; then
        echo "ERROR: Could not find bitcode file ending in 'gfx1010.bc' in $HIP_DEVICE_LIB_PATH"
    fi

    # Check if LD_LIBRARY_PATH contains at least one directory with binaries
    local found_so=false
    IFS=':' read -ra ADDR <<< "$LD_LIBRARY_PATH"
    for dir in "${ADDR[@]}"; do
        if [ -d "$dir" ] && ls "$dir"/*.so >/dev/null 2>&1; then
            found_so=true
            break
        fi
    done

    if [ "$found_so" = false ]; then
        echo "ERROR: None of the paths in LD_LIBRARY_PATH contain shared library (.so) files."
    fi

    # Check for critical executables
    for cmd in hipcc clang lld; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "WARNING: Executable '$cmd' not found in PATH."
        fi
    done
    echo "--- ROCm Environment Variables ---"
    echo "ROCM_PATH: $ROCM_PATH"
    echo "HIP_PLATFORM: $HIP_PLATFORM"
    echo "CMAKE_PREFIX_PATH: $CMAKE_PREFIX_PATH"
    echo "PYTORCH_ROCM_ARCH: $PYTORCH_ROCM_ARCH"
    echo "USE_ROCM: $USE_ROCM"
    echo "PATH: $PATH"
    echo "---------------------------------"
}