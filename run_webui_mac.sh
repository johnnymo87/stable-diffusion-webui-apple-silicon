#!/usr/bin/env bash -l

# Pull the latest changes from the repo
git submodule update --init --recursive

# This should not be needed since it's configured during installation, but might as well have it here.
conda env config vars set PYTORCH_ENABLE_MPS_FALLBACK=1

# Activate conda environment
conda activate stable-diffusion-webui

pushd stable-diffusion-webui > /dev/null

# Update the dependencies if needed
pip install -r requirements.txt

# Run the web ui
python webui.py --precision full --no-half --use-cpu Interrogate GFPGAN CodeFormer $@

popd > /dev/null

# Deactivate conda environment
conda deactivate

