#!/usr/bin/env bash
# =============================================================================
# dotfiles/modules/symlinks.sh — link config files from repo into $HOME
# Sourced by install.sh — helpers and DOTFILES_DIR already set.
# =============================================================================

CONFIGS="$DOTFILES_DIR/configs"

# ── Bash ──────────────────────────────────────────────────────────────────────
safe_symlink "$CONFIGS/bash/.bashrc"       "$HOME/.bashrc"
safe_symlink "$CONFIGS/bash/.bash_profile" "$HOME/.bash_profile"

# ── Git ───────────────────────────────────────────────────────────────────────
safe_symlink "$CONFIGS/git/.gitconfig"     "$HOME/.gitconfig"

# ── Tmux ──────────────────────────────────────────────────────────────────────
safe_symlink "$CONFIGS/tmux/.tmux.conf"    "$HOME/.tmux.conf"

# ── Neovim ────────────────────────────────────────────────────────────────────
# Neovim expects its config at ~/.config/nvim/
safe_symlink "$CONFIGS/nvim"               "$HOME/.config/nvim"

# ── Alacritty ─────────────────────────────────────────────────────────────────
# Alacritty reads ~/.config/alacritty/alacritty.toml
safe_symlink "$CONFIGS/alacritty"          "$HOME/.config/alacritty"

# ── Hyprland (only link if hyprland module was run) ──────────────────────────
if [[ -d "$DOTFILES_DIR/configs/hypr" ]]; then
  safe_symlink "$DOTFILES_DIR/configs/hypr/hyprland"   "$HOME/.config/hypr"
  safe_symlink "$DOTFILES_DIR/configs/hypr/waybar"     "$HOME/.config/waybar"
  safe_symlink "$DOTFILES_DIR/configs/hypr/swaync"     "$HOME/.config/swaync"
  safe_symlink "$DOTFILES_DIR/configs/hypr/wofi"       "$HOME/.config/wofi"
  safe_symlink "$DOTFILES_DIR/configs/hypr/hyprlock"   "$HOME/.config/hyprlock"
  safe_symlink "$DOTFILES_DIR/configs/hypr/hyperpaper" "$HOME/.config/hyperpaper"
  # Wallpapers directory (you populate this yourself)
  mkdir -p "$HOME/.config/wallpapers"
  info "Wallpapers dir ready at ~/.config/wallpapers — drop your images there"
fi

log "All symlinks in place"
