# Stable Diffusion WebUI Apple Silicon
If you your computer has an Apple silicon chip (M1, M2, etc.), you need to do special things to use [stable diffusion](https://github.com/CompVis/stable-diffusion). Here, I want to use it via [AUTOMATIC1111's web UI](https://github.com/AUTOMATIC1111/stable-diffusion-apple-silicon). In the wiki in that codebase, there's [some tips](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Installation-on-Apple-Silicon) about how to do this, and someone even did wrote [a script](https://github.com/dylancl/stable-diffusion-webui-mps/blob/master/setup_mac.sh) to automate this setup. This codebase is my attempt to improve upon this automation.

## Installation
1. Install [direnv](https://github.com/direnv/direnv).
1. Because this repository uses git submodules, clone it recusively.
   ```
   git clone --recurse-submodules https://github.com/johnnymo87/stable-diffusion-webui-apple-silicon.git
   ```
1. Move into the cloned directory.
   ```
   cd stable-diffusion-webui-apple-silicon
   ```
1. Initialize the file for environment variables and then fill it out.
   ```
   cp .envrc.sample .envrc
   ```
   * Optionally, skip this step, and the first time setup script will prompt you for the necessary information.
1. Run the first time setup script.
   ```
   ./first_time_setup.sh
   ```
1. Run the every time script.
   ```
   ./run_webui_mac.sh
   ```

## Special Thanks
* [Stable diffusion](https://github.com/CompVis/stable-diffusion).
* [AUTOMATIC1111's stable diffusion web UI](https://github.com/AUTOMATIC1111/stable-diffusion-webui/).
* [dylancl's scripts for running both on Apple silicon](https://github.com/dylancl/stable-diffusion-webui-mps).
* [ctawong's efforts to merge Apple silicon automation efforts into AUTOMATIC1111's repository](https://github.com/AUTOMATIC1111/stable-diffusion-webui/pull/4990).
* [brkirch's suggestions for improvement and heads up about future changes](https://github.com/AUTOMATIC1111/stable-diffusion-webui/pull/4990#issuecomment-1326042975).
