#!/usr/bin/env bash
# =============================================================================
# dotfiles/lib/helpers.sh — shared utilities for all modules
# =============================================================================

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

# Privilege escalation — uses sudo if available, runs directly if already root.
# Usage: elevate pacman -S foo
elevate() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  else
    die "Not root and sudo not found. Install sudo or run as root."
  fi
}

# Install one or more pacman packages in a single transaction (one sudo prompt).
# Already-installed packages are filtered out first and reported individually.
# Usage: pacman_install pkg1 pkg2 pkg3
#        pacman_install "${MY_ARRAY[@]}"
pacman_install() {
  local to_install=()

  for pkg in "$@"; do
    if pacman -Qi "$pkg" &>/dev/null; then
      info "$pkg — already installed, skipping"
    else
      to_install+=("$pkg")
    fi
  done

  if [[ ${#to_install[@]} -eq 0 ]]; then
    info "All packages already installed"
    return 0
  fi

  info "Installing ${#to_install[@]} package(s): ${to_install[*]}"
  elevate pacman -S --noconfirm --needed "${to_install[@]}"
}

# Install one or more AUR packages via yay in a single transaction.
# Already-installed packages are filtered out first.
# Usage: aur_install pkg1 pkg2 pkg3
#        aur_install "${MY_ARRAY[@]}"
aur_install() {
  local to_install=()

  for pkg in "$@"; do
    if pacman -Qi "$pkg" &>/dev/null; then
      info "$pkg — already installed, skipping"
    else
      to_install+=("$pkg")
    fi
  done

  if [[ ${#to_install[@]} -eq 0 ]]; then
    info "All AUR packages already installed"
    return 0
  fi

  info "Installing ${#to_install[@]} AUR package(s): ${to_install[*]}"
  yay -S --noconfirm --needed "${to_install[@]}"
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