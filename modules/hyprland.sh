#!/usr/bin/env bash
# =============================================================================
# dotfiles/modules/hyprland.sh — full Hyprland WM setup from a minimal Arch install
#
# Installs: Hyprland, Waybar, Swaync, Wofi, Hyprlock, Hyperpaper,
#           Nautilus, a terminal, fonts, GTK theming, and more.
#
# Usage (standalone, after running install.sh for base packages):
#   bash ~/dotfiles/modules/hyprland.sh
#
# Or add to install.sh:
#   run_module "hyprland" "$DOTFILES_DIR/modules/hyprland.sh"
# =============================================================================

# Allow sourcing standalone (helpers + DOTFILES_DIR not yet loaded)
if [[ -z "${DOTFILES_DIR:-}" ]]; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  source "$DOTFILES_DIR/lib/helpers.sh"
fi

CONFIGS="$DOTFILES_DIR/configs/hypr"

# ── 1. Core Wayland / Hyprland packages (pacman) ─────────────────────────────
print_header "Installing Hyprland + Wayland stack"

HYPR_PACMAN_PKGS=(
  # Wayland essentials
  wayland
  wayland-protocols
  xorg-xwayland          # XWayland for legacy X11 apps

  # Hyprland
  hyprland

  # Status bar
  waybar
  otf-font-awesome       # icons for waybar

  # Notifications
  swaync                 # notification daemon (also called SwayNotificationCenter)

  # Application launcher
  wofi

  # Wallpaper
  swaybg                 # simple wallpaper setter (fallback)

  # Lock screen deps
  pam                    # PAM auth for hyprlock

  # Terminal (Alacritty already in packages.sh — add kitty as Wayland-native alternative)
  kitty

  # File manager
  nautilus

  # Polkit agent (needed for GUI auth prompts)
  polkit
  polkit-gnome

  # Screen sharing / portals
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk

  # Display / GPU
  mesa
  vulkan-intel           # swap for vulkan-radeon or nvidia-utils if needed

  # Audio (Pipewire stack)
  pipewire
  pipewire-alsa
  pipewire-pulse
  pipewire-jack
  wireplumber
  pavucontrol            # GUI volume control

  # Clipboard
  wl-clipboard           # wl-copy / wl-paste
  cliphist               # clipboard history

  # Screenshot
  grim                   # grab images from Wayland compositor
  slurp                  # select regions (used with grim)
  swappy                 # screenshot annotation tool

  # Brightness / backlight
  brightnessctl

  # Network management (GUI)
  networkmanager
  network-manager-applet

  # Bluetooth
  bluez
  bluez-utils
  blueberry              # GUI bluetooth manager

  # Fonts
  ttf-jetbrains-mono-nerd
  ttf-nerd-fonts-symbols
  noto-fonts
  noto-fonts-emoji

  # GTK theming
  gtk3
  gtk4
  gnome-themes-extra
  gsettings-desktop-schemas
  dconf                  # needed to apply GTK settings
  nwg-look               # GTK settings GUI (Wayland-native)

  # Qt theming (makes Qt apps follow GTK theme)
  qt5-wayland
  qt6-wayland
  qt5ct
  qt6ct

  # Utilities
  jq                     # JSON processing (waybar scripts)
  imagemagick            # image conversion
  swayidle               # idle daemon (dim/lock after inactivity)
)

filtered_hypr=()
for pkg in "${HYPR_PACMAN_PKGS[@]}"; do
  [[ "$pkg" == \#* ]] && continue
  filtered_hypr+=("$pkg")
done
pacman_install "${filtered_hypr[@]}"


# ── 2. AUR packages ───────────────────────────────────────────────────────────
print_header "Installing AUR packages for Hyprland"

HYPR_AUR_PKGS=(
  hyperpaper             # multi-monitor wallpaper manager
  hyprlock               # lock screen
  hyprpicker             # colour picker
  hyprshot               # screenshot wrapper (wraps grim+slurp)
  wlogout                # logout / power menu
  swww                   # animated wallpaper daemon (alternative to hyperpaper)
  catppuccin-gtk-theme-mocha  # Catppuccin GTK theme (popular ricing theme)
  papirus-icon-theme     # clean icon theme
)

filtered_hypr_aur=()
for pkg in "${HYPR_AUR_PKGS[@]}"; do
  [[ "$pkg" == \#* ]] && continue
  filtered_hypr_aur+=("$pkg")
done
aur_install "${filtered_hypr_aur[@]}"


# ── 3. Enable required services ───────────────────────────────────────────────
print_header "Enabling services for Hyprland"

# NetworkManager
if ! systemctl is-enabled NetworkManager &>/dev/null; then
  elevate systemctl enable --now NetworkManager
  log "NetworkManager enabled"
else
  info "NetworkManager already enabled"
fi

# Bluetooth
if ! systemctl is-enabled bluetooth &>/dev/null; then
  elevate systemctl enable --now bluetooth
  log "Bluetooth enabled"
else
  info "Bluetooth already enabled"
fi

# Pipewire (user services)
for svc in pipewire pipewire-pulse wireplumber; do
  if ! systemctl --user is-enabled "$svc" &>/dev/null; then
    systemctl --user enable --now "$svc" 2>/dev/null || \
      warn "$svc user service not found — may need a relog"
  else
    info "$svc already enabled"
  fi
done

# ── 4. Apply GTK theme via gsettings ─────────────────────────────────────────
print_header "Applying GTK theme"

if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme   "catppuccin-mocha-standard-blue-dark" 2>/dev/null || \
    warn "GTK theme not yet installed — run after AUR packages finish"
  gsettings set org.gnome.desktop.interface icon-theme  "Papirus-Dark"
  gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
  gsettings set org.gnome.desktop.interface font-name    "JetBrainsMono Nerd Font 11"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  log "GTK settings applied"
else
  warn "gsettings not found — GTK theme not applied"
fi

log "Hyprland setup complete — log out and select Hyprland from your display manager, or run: Hyprland"