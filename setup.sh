#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/Projects/dotfiles"

link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%s)"
    echo "  backed up: $dest"
  fi
  ln -sf "$src" "$dest"
  echo "  linked: $dest"
}

echo "Linking dotfiles..."

link "$DOTFILES/.bashrc"        "$HOME/.bashrc"
link "$DOTFILES/.bash_profile"  "$HOME/.bash_profile"
link "$DOTFILES/.gitconfig"     "$HOME/.gitconfig"

link "$DOTFILES/.config/hypr"           "$HOME/.config/hypr"
link "$DOTFILES/.config/waybar"         "$HOME/.config/waybar"
link "$DOTFILES/.config/alacritty"      "$HOME/.config/alacritty"
link "$DOTFILES/.config/mako"           "$HOME/.config/mako"
link "$DOTFILES/.config/btop"           "$HOME/.config/btop"
link "$DOTFILES/.config/nvim"           "$HOME/.config/nvim"
link "$DOTFILES/.config/snappy-switcher" "$HOME/.config/snappy-switcher"
link "$DOTFILES/.config/gtk-3.0"        "$HOME/.config/gtk-3.0"
link "$DOTFILES/.config/gtk-4.0"        "$HOME/.config/gtk-4.0"
link "$DOTFILES/.config/environment.d"  "$HOME/.config/environment.d"
link "$DOTFILES/.config/dolphinrc"      "$HOME/.config/dolphinrc"
link "$DOTFILES/.config/mimeapps.list"  "$HOME/.config/mimeapps.list"

mkdir -p "$HOME/bin"
for f in "$DOTFILES/bin"/*; do
  link "$f" "$HOME/bin/$(basename "$f")"
done

echo "Done! Log out and back in for changes to take effect."
