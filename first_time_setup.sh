#!/usr/bin/env bash -l

# Check for updates in any submodules.
git submodule update --init --recursive

# Link all the extra repositories to the place that stable-diffusion-webui
# expects to find them.
ln -sf $(pwd)/repositories $(pwd)/stable-diffusion-webui/repositories

# Navigate into the stable-diffusion-webui git repository.
pushd stable-diffusion-webui > /dev/null

# Check if conda is installed
if ! command -v conda > /dev/null
then
    echo "Conda is not installed. Installing conda."
    brew install miniconda
fi

# Check if we need to initialize conda
if ! type -t conda | grep function > /dev/null
then
    echo "Initializing conda."
    conda init
fi

# Check if a conda environment named stable-diffusion-webui already exists
if conda env list | grep stable-diffusion-webui > /dev/null
then
    while true; do
        echo "A conda environment named stable-diffusion-webui already exists."
        read -p "Remove it for a fresh install? (y/n) " yn
        case $yn in
            [Yy]* )
                echo "Removing the conda environment named stable-diffusion-webui."
                conda remove -n stable-diffusion-webui --all
                break
                ;;
            [Nn]* )
                echo "Leaving the conda environment named stable-diffusion-webui untouched."
                break
                ;;
            * ) echo "Please answer yes or no.";;
        esac
    done
else
    echo "No conda environment found named stable-diffusion-webui."
fi

if ! conda env list | grep stable-diffusion-webui > /dev/null
then
    echo "Creating a conda environment named stable-diffusion-webui."
    conda create -n stable-diffusion-webui python=3.10
fi

# Activate the conda environment
conda activate stable-diffusion-webui

# Check if we've already downloaded any model checkpoint
if ! compgen -G models/Stable-diffusion/*.ckpt > /dev/null
then
    echo "Your models/Stable-diffusion/ directory doesn't have a .ckpt file."
    while true; do
        read -p "Would you like to download a model checkpoint now? (y/n) " yn
        case $yn in
            [Yy]* )
            # If not already provided by an environment variable, prompt the
            # user for their hugging face token.
            if [ -z "$HUGGING_FACE_ACCESS_TOKEN" ]
            then
                echo "If you haven't already, register an account on huggingface.co and then create a token (read) on https://huggingface.co/settings/tokens"
                read -p "Please enter your hugging face token: " HUGGING_FACE_ACCESS_TOKEN
            fi
            # If not already provided by an environment variable, prompt the
            # user for the URL to download the model checkpoint.
            if [ -z "$MODEL_CHECKPOINT_DOWNLOAD_URL" ]
            then
                read -p "Please enter the URL to download the .ckpt file for the model checkpoint: " MODEL_CHECKPOINT_DOWNLOAD_URL
            fi
            pushd models/Stable-diffusion/ > /dev/null
            # Download the requested model
            echo "Downloading model found at $MODEL_CHECKPOINT_DOWNLOAD_URL"
            headertoken="Authorization: Bearer $HUGGING_FACE_ACCESS_TOKEN"
            curl --remote-name --location --header "$headertoken" $MODEL_CHECKPOINT_DOWNLOAD_URL
            popd > /dev/null
            break
            ;;
            [Nn]* ) echo "Skipping model download"; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

# Install dependencies
pip install -r requirements.txt

pip install git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1

pip install git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379

pip install torch==1.12.1 torchvision==0.13.1

pip install torchsde

# Missing dependencie(s)
pip install gdown fastapi psutil

# Patch the bug that prevents torch from working (see https://github.com/Birch-san/stable-diffusion#patch), rather than try to use a nightly build
echo "--- a/functional.py	2022-10-14 05:28:39.000000000 -0400
+++ b/functional.py	2022-10-14 05:39:25.000000000 -0400
@@ -2500,7 +2500,7 @@
         return handle_torch_function(
             layer_norm, (input, weight, bias), input, normalized_shape, weight=weight, bias=bias, eps=eps
         )
-    return torch.layer_norm(input, normalized_shape, weight, bias, eps, torch.backends.cudnn.enabled)
+    return torch.layer_norm(input.contiguous(), normalized_shape, weight, bias, eps, torch.backends.cudnn.enabled)


 def group_norm(
" | patch -p1 -d "$(python -c "import torch; import os; print(os.path.dirname(torch.__file__))")"/nn

popd > /dev/null

# Activate the MPS_FALLBACK conda environment variable
conda env config vars set PYTORCH_ENABLE_MPS_FALLBACK=1

# We need to reactivate the conda environment for the variable to take effect
conda deactivate
conda activate stable-diffusion-webui

# Check if the config var is set
if [ -z "$PYTORCH_ENABLE_MPS_FALLBACK" ]; then
    echo "============================================="
    echo "====================ERROR===================="
    echo "============================================="
    echo "The PYTORCH_ENABLE_MPS_FALLBACK variable is not set."
    echo "This means that the script will either fall back to CPU or fail."
    echo "To fix this, please run the following command:"
    echo "conda env config vars set PYTORCH_ENABLE_MPS_FALLBACK=1"
    echo "Or, try running the script again."
    echo "============================================="
    echo "====================ERROR===================="
    echo "============================================="
    exit 1
fi

echo "Done. Now run ./run_webui_mac.sh"
