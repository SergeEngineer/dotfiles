

# -e (errexit): Exit immediately if any command fails
# -u (nounset): Treat unset variables as an error and exit immediately
# -o pipefail: Return the exit status of the last command in the pipeline that failed
set -euo pipefail


# ${BASH_SOURCE[0]} — The path to the current script file (like install.sh or /path/to/install.sh)
# dirname "${BASH_SOURCE[0]}" — Extracts just the directory part (removes the filename)
# cd "$(dirname ...)" && pwd — Changes to that directory, then pwd prints its absolute path
# The && ensures pwd only runs if cd succeeds
# $(... ) — Command substitution: captures the output and uses it as the value
# export DOTFILES_DIR — Makes the variable available to child processes/subshells
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# source loads and executes a bash script in the current shell (instead of running it in a subshell).
source "$DOTFILES_DIR/lib/helpers.sh"

# --- Argument parsing --------------------------------------------------------
SKIP_PACKAGES=false
SKIP_SYSTEM=false
SKIP_SERVICES=false
WITH_HYPRLAND=false

for arg in "$@"; do
  case $arg in
    --skip-packages) SKIP_PACKAGES=true ;;
    --skip-system)   SKIP_SYSTEM=true ;;
    --skip-services) SKIP_SERVICES=true ;;
    --with-hyprland) WITH_HYPRLAND=true ;;
    --help)
      echo "Usage: bash install.sh [--skip-packages] [--skip-system] [--skip-services] [--with-hyprland]"
      exit 0 ;;
    *) warn "Unknown argument: $arg" ;;
  esac
done

# --- Main flow ---------------------------------------------------------------
print_header "dotfiles installer"
log "Install root: $DOTFILES_DIR"
log "Running as:   $(whoami)"
# The echo at the end prints a blank line (just a newline character) for better readability of the output. It's a common practice to separate sections of output with blank lines.
echo

# 1. System settings (locale, timezone, hostname)
if [[ "$SKIP_SYSTEM" == false ]]; then
  run_module "system"   "$DOTFILES_DIR/modules/system.sh"
fi

# 2. Packages (pacman + yay AUR)
if [[ "$SKIP_PACKAGES" == false ]]; then
  run_module "packages" "$DOTFILES_DIR/modules/packages.sh"
fi