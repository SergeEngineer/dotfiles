#!/usr/bin/env bash
# =============================================================================
# dotfiles/modules/packages.sh — install pacman + AUR packages
# Sourced by install.sh — helpers already loaded.
# =============================================================================

# ── System update ─────────────────────────────────────────────────────────────
info "Updating package databases..."
# Refresh mirrors properly: reflector is a tool that fetches the latest mirror list from Arch Linux and sorts it by speed, ensuring you have the fastest mirrors for package downloads. This can significantly speed up installations and updates.

#pacman_install reflector

#reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
if [[ ! -f /etc/pacman.d/mirrorlist.updated ]]; then
  pacman_install reflector

  reflector --latest 10 --protocol https --sort rate  --save /etc/pacman.d/mirrorlist

  touch /etc/pacman.d/mirrorlist.updated
fi

if [[ $EUID -eq 0 ]]; then
  pacman -Syyu --noconfirm
else
  sudo pacman -Syyu --noconfirm
fi
# -Syy → force refresh mirrors
# -u → full system upgrade

# ── Bootstrap yay (AUR helper) ────────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
  info "yay not found — bootstrapping from AUR..."

  pacman_install git base-devel go

  yay_tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$yay_tmp/yay"

  if [[ $EUID -eq 0 ]]; then
    useradd -m builduser 2>/dev/null || true
    chown -R builduser:builduser "$yay_tmp"

    su builduser -c "cd '$yay_tmp/yay' && makepkg --noconfirm" || {
      echo "yay build failed"
      exit 1
    }

    pacman -U --noconfirm "$yay_tmp"/yay/*.pkg.tar.zst
    userdel -r builduser 2>/dev/null || true
  else
    (cd "$yay_tmp/yay" && makepkg --noconfirm)
    sudo pacman -U --noconfirm "$yay_tmp"/yay/*.pkg.tar.zst
  fi

  rm -rf "$yay_tmp"
  log "yay installed"
fi

# ── Core system tools ─────────────────────────────────────────────────────────
PACMAN_PKGS=(
  # Shell & terminal
  bash
  bash-completion
  tmux
  alacritty

  # Editors
  neovim

  # Development
  git
  git-delta          # better git diffs
  base-devel
  make
  cmake
  python
  python-pip
  nodejs
  npm
  ripgrep            # fast grep (used by nvim plugins)
  fd                 # fast find (used by nvim plugins)
  fzf                # fuzzy finder

  # System utilities
  htop
  btop
  tree
  curl
  wget
  unzip
  zip
  stow               # optional: GNU stow for symlink management
  openssh
  man-db
  man-pages

  # Fonts (useful for alacritty / terminal)
  ttf-jetbrains-mono-nerd
)

for pkg in "${PACMAN_PKGS[@]}"; do
  # Skip comment lines
  [[ "$pkg" == \#* ]] && continue
  pacman_install "$pkg"
done

# ── AUR packages ──────────────────────────────────────────────────────────────
AUR_PKGS=(
  # Shell
  bash-git-prompt   # git status in your bash prompt
)

for pkg in "${AUR_PKGS[@]}"; do
  [[ "$pkg" == \#* ]] && continue
  aur_install "$pkg"
done

log "Package installation complete"