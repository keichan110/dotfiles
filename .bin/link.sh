#!/bin/zsh
stow alacritty emacs tmux vscode wezterm zsh claude starship nvim herdr scripts -t ${HOME} -v --no-folding

# alacritty-theme
target_dir=".config/alacritty/themes"
rm -rf "${HOME}/${target_dir}"
mkdir -p "${HOME}/${target_dir}"
git clone https://github.com/alacritty/alacritty-theme "${HOME}/${target_dir}"
# tmux-plugin-manager
target_dir=".config/tmux/plugins/tpm"
rm -rf "${HOME}/${target_dir}"
mkdir -p "${HOME}/${target_dir}"
git clone https://github.com/tmux-plugins/tpm "${HOME}/${target_dir}"
