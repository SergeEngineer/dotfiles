#!/usr/bin/env bash
# =============================================================================
# dotfiles/modules/symlinks.sh — single source of truth for all symlinks
#
# RULE: Only this file creates symlinks. Modules install software; they never
#       call safe_symlink themselves. This means you can re-apply all config
#       links at any time without reinstalling packages:
#
#         bash install.sh --skip-packages --skip-system --skip-services
#
# Sourced by install.sh — helpers and DOTFILES_DIR already loaded.
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
safe_symlink "$CONFIGS/nvim"               "$HOME/.config/nvim"

# ── Alacritty ─────────────────────────────────────────────────────────────────
safe_symlink "$CONFIGS/alacritty"          "$HOME/.config/alacritty"

# ── Hyprland stack ────────────────────────────────────────────────────────────
# Only linked when the hypr config directory exists (i.e. --with-hyprland was run).
# Add a new tool here when you add a configs/hypr/<tool>/ directory.
if [[ -d "$CONFIGS/hypr" ]]; then
  safe_symlink "$CONFIGS/hypr/hyprland"    "$HOME/.config/hypr"
  safe_symlink "$CONFIGS/hypr/waybar"      "$HOME/.config/waybar"
  safe_symlink "$CONFIGS/hypr/swaync"      "$HOME/.config/swaync"
  safe_symlink "$CONFIGS/hypr/wofi"        "$HOME/.config/wofi"
  safe_symlink "$CONFIGS/hypr/hyprlock"    "$HOME/.config/hyprlock"
  safe_symlink "$CONFIGS/hypr/hyperpaper"  "$HOME/.config/hyperpaper"

  # Wallpapers directory — not a symlink, just a location you populate yourself.
  # Both autostart.conf (swww) and hyprlock.conf expect wallpaper.jpg here.
  mkdir -p "$HOME/.config/wallpapers"
  info "Wallpapers dir ready at ~/.config/wallpapers — drop your images there"
fi

log "All symlinks in place"