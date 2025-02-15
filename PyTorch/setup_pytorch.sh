#!/bin/bash

# Remove existing PyTorch directory if it exists
rm -rf pytorch

# Clone the PyTorch repository with submodules
git clone --recursive --single-branch --branch aviralgoel-amd-inductor https://github.com/AviralGoelAMD/pytorch.git

# Navigate into the cloned directory
cd pytorch || { echo "Failed to enter pytorch directory"; exit 1; }

# Sync submodules
git submodule sync

# Update and initialize submodules
git submodule update --init --recursive

# Uninstall existing PyTorch packages
pip uninstall -y torch torchvision torchaudio

# Install composable kernel from GitHub
pip install git+https://github.com/rocm/composable_kernel

# Build PyTorch for AMD
python tools/amd_build/build_amd.py

# Set CMAKE_PREFIX_PATH
export CMAKE_PREFIX_PATH="${CONDA_PREFIX:-'$(dirname $(which conda))/../'}:${CMAKE_PREFIX_PATH}"

# Install PyTorch in development mode
python setup.py develop

# Check PyTorch git version
git_hash=$(python -c "import torch; print(torch.version.git_version)")

if [ -z "$git_hash" ]; then
    echo "Error: No git hash found."
    exit 1
else
    echo "PyTorch Git Hash: $git_hash"
fi

# Print success message
echo "PyTorch repository and submodules successfully cloned and updated. PyTorch built, installed, and composable kernel installed."

