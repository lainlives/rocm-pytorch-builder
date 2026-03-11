### **I have only tested this on Fedora**

# Build Script Documentation

This document outlines the usage and configuration for the `build.sh` automation script. This script is designed to build PyTorch and TorchVision wheels with specific ROCm and Python version support.

## Usage

To execute the build, run the `build.sh` script from the root directory. You must pass the desired Python version as an argument.

**Syntax:**
```bash
./build.sh [python_version]
```

**Examples:**
```bash
# Build for Python 3.13
./build.sh 3.13

# Build for Python 3.10
./build.sh 3.12
```

---

## Configuration

Before running the script, review and adjust the settings in the configuration file located at:

`scripts/config.sh`


### Environment Variables

The following variables control the build environment, source versions, and output locations.

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `torchrelease` | `release/2.10` | The Git branch or tag for the **PyTorch** source code. |
| `visionrelease` | `release/0.26` | The Git branch or tag for **TorchVision**. <br>*(Note: Must match the PyTorch version, e.g., 0.26 matches PT 2.10)* |
| `rocmdir` | `$HOME/.local/rocm` | The installation directory for the **ROCm** tarball. |
| `wheeldir` | `$PWD/output` | The destination directory where the **built wheel files** (`.whl`) will be saved. |
| `prefix` | `$rocmdir` | The installation prefix for **ZEN libs**. <br>*(Defaults to the same location as ROCm)* |
| `buildroot` | `$PWD/build` | The working directory where the script performs compilation and temporary operations. |

---

## Directory Layout

Based on the configuration above, the build process utilizes the following structure:

```text
.
├── build.sh                 # Main script
├── scripts/
│   ├── config.sh            # Configuration variables
│   ├── build_zen.sh         # Functions related to Zen CPU libs
│   ├── env.sh               # Build env variables
│   ├── get_files.sh         # Functions for downloading files
│   └── venv.sh              # Functions for virtualenv
├── build/                   # (buildroot) Temporary build workspace
└── output/                  # (wheeldir) Final wheel artifacts
```

## Important Notes
**Version Compatibility:** Ensure `visionrelease` is compatible with `torchrelease`. Mismatched versions may cause compilation errors.
**Permissions:** The script may require write permissions to `rocmdir` and `buildroot`.
**Cleanup:** The `buildroot` directory contains temporary source code and object files. It can be safely deleted after a successful build to save space, provided you have copied the wheels from `wheeldir`.