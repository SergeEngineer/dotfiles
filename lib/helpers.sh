#!/usr/bin/env bash
# ==========================================================================================================================================================
# dotfiles/lib/helpers.sh — shared utilities for all modules — functions that every module needs but that do not belong to any one module specifically.
# These are sourced by the individual module scripts to provide common utilities.
# The general rule for what belongs in helpers.sh is: if two or more modules would need the same function, it goes in helpers.sh.
# ==========================================================================================================================================================


# Colours (disabled when not a terminal)
if [[ -t 1 ]]; then
  C_RESET="\033[0m"
  C_BOLD="\033[1m"
  C_GREEN="\033[0;32m"
  C_YELLOW="\033[0;33m"
  C_RED="\033[0;31m"
  C_CYAN="\033[0;36m"
else
  C_RESET="" C_BOLD="" C_GREEN="" C_YELLOW="" C_RED="" C_CYAN=""
fi
 
log()     { echo -e "${C_GREEN}[✓]${C_RESET} $*"; }
info()    { echo -e "${C_CYAN}[→]${C_RESET} $*"; }
warn()    { echo -e "${C_YELLOW}[!]${C_RESET} $*"; }
error()   { echo -e "${C_RED}[✗]${C_RESET} $*" >&2; }
die()     { error "$*"; exit 1; }
 
print_header() {
  local title="$*"
  local line
  line=$(printf '─%.0s' $(seq 1 ${#title}))
  echo
  echo -e "${C_BOLD}${C_CYAN}  $title${C_RESET}"
  echo -e "${C_CYAN}  $line${C_RESET}"
  echo
}
 
# Run a module script and report success/failure
run_module() {
  local name="$1"
  local script="$2"
  print_header "Module: $name"
  if [[ ! -f "$script" ]]; then
    warn "Module script not found: $script — skipping"
    return 0
  fi
  # shellcheck disable=SC1090
  source "$script" || die "Module '$name' failed"
  log "Module '$name' completed"
}
 
# Install a pacman package only if not already installed (idempotent)
# local pkg="$1" — Stores the package name argument in a local variable for easier reference
# pacman -Qi "$pkg" &>/dev/null — Checks if package is already installed
# &>/dev/null — Suppresses all output (both stdout and stderr) from the command (silent check)
# -Q means "query local packages"
# -i means "detailed info"
# -- needed means "don't reinstall if already installed"
pacman_install() {
  local pkgs=("$@")

  info "Installing: ${pkgs[*]}"

  if [[ $EUID -eq 0 ]]; then
    pacman -S --noconfirm --needed "${pkgs[@]}"
  else
    sudo pacman -S --noconfirm --needed "${pkgs[@]}"
  fi
}

# Install an AUR package via yay only if not already installed (idempotent)
aur_install() {
  local pkg="$1"
  if pacman -Qi "$pkg" &>/dev/null; then
    info "$pkg — already installed, skipping"
  else
    info "Installing AUR: $pkg..."
    yay -S --noconfirm --needed "$pkg"
  fi
}
 
# Create a symlink, backing up any existing file first
safe_symlink() {
  local src="$1"   # absolute path inside dotfiles repo
  local dst="$2"   # absolute path in $HOME
 
  # Ensure destination directory exists
  mkdir -p "$(dirname "$dst")"
 
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    info "$(basename "$dst") — already linked, skipping"
    return 0
  fi
 
  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup="${dst}.bak-$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing: $dst → $backup"
    mv "$dst" "$backup"
  fi
 
  ln -sf "$src" "$dst"
  log "Linked: $dst → $src"
}
 
# Prompt user y/n (returns 0 for yes, 1 for no)
confirm() {
  local prompt="${1:-Continue?}"
  read -rp "$(echo -e "${C_YELLOW}[?]${C_RESET} $prompt [y/N] ")" answer
  [[ "${answer,,}" == "y" || "${answer,,}" == "yes" ]]
}

# Check if a command exists before trying to use it
require_cmd() {
  command -v "$1" &>/dev/null || die "Required command not found: $1"
}

# Add a line to a file only if it isn't already there (idempotent file editing)
append_if_missing() {
  local line="$1"
  local file="$2"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

# Clone a git repo only if the destination doesn't exist yet
git_clone_once() {
  local url="$1"
  local dest="$2"
  if [[ -d "$dest" ]]; then
    info "$(basename "$dest") already cloned, skipping"
  else
    git clone --depth=1 "$url" "$dest"
  fi
}

# Run a command as another user (useful for AUR builds which can't run as root)
run_as_user() {
  sudo -u "$SUDO_USER" -- "$@"
}

# Print the OS and version (useful for guards at the top of modules)
is_arch() {
  [[ -f /etc/arch-release ]]
}