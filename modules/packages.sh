#!/usr/bin/env bash
# =============================================================================
# dotfiles/modules/packages.sh — install pacman + AUR packages
# Sourced by install.sh — helpers already loaded.
# =============================================================================

# ── System update ─────────────────────────────────────────────────────────────
info "Updating package databases..."
elevate pacman -Sy --noconfirm

# ── Bootstrap yay (AUR helper) ────────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
  info "yay not found — bootstrapping from AUR..."
  pacman_install git base-devel

  yay_tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$yay_tmp/yay"

  if [[ $EUID -eq 0 ]]; then
    # makepkg refuses to run as root — create a temporary build user
    info "Running as root: creating temporary build user for makepkg..."
    useradd -m -G wheel _dotfiles_build 2>/dev/null || true
    echo "_dotfiles_build ALL=(ALL) NOPASSWD: /usr/bin/pacman" \
      > /etc/sudoers.d/dotfiles_build

    chown -R _dotfiles_build:_dotfiles_build "$yay_tmp"
    su -c "cd '$yay_tmp/yay' && makepkg -si --noconfirm" _dotfiles_build

    userdel -r _dotfiles_build 2>/dev/null || true
    rm -f /etc/sudoers.d/dotfiles_build
  else
    (cd "$yay_tmp/yay" && makepkg -si --noconfirm)
  fi

  rm -rf "$yay_tmp"
  log "yay installed"
else
  info "yay already installed"
fi

# ── Core system tools ─────────────────────────────────────────────────────────
# Passed as a single array — one sudo prompt, one pacman transaction.
# Comment lines (starting with #) are stripped before the call.
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
  stow
  openssh
  man-db
  man-pages

  # Fonts
  ttf-jetbrains-mono-nerd
)

# Strip comment-only entries before passing to pacman_install
filtered=()
for pkg in "${PACMAN_PKGS[@]}"; do
  [[ "$pkg" == \#* ]] && continue
  filtered+=("$pkg")
done

pacman_install "${filtered[@]}"

# ── AUR packages ──────────────────────────────────────────────────────────────
# Same pattern — one yay transaction, no repeated prompts.
AUR_PKGS=(
  bash-git-prompt   # git status in bash prompt
)

filtered_aur=()
for pkg in "${AUR_PKGS[@]}"; do
  [[ "$pkg" == \#* ]] && continue
  filtered_aur+=("$pkg")
done

aur_install "${filtered_aur[@]}"

log "Package installation complete"