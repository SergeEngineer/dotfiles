#!/usr/bin/env bash
# =============================================================================
# dotfiles/modules/system.sh — locale, timezone, hostname, pacman tweaks
# Sourced by install.sh — helpers already loaded.
# =============================================================================

# ── Locale ────────────────────────────────────────────────────────────────────
LOCALE="en_US.UTF-8"

if ! grep -q "^${LOCALE}" /etc/locale.gen 2>/dev/null; then
  info "Enabling locale $LOCALE..."
  sudo sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
  sudo locale-gen
else
  info "Locale $LOCALE already enabled"
fi

if [[ "$(cat /etc/locale.conf 2>/dev/null)" != "LANG=${LOCALE}" ]]; then
  info "Setting system locale..."
  echo "LANG=${LOCALE}" | sudo tee /etc/locale.conf > /dev/null
fi

# ── Timezone ──────────────────────────────────────────────────────────────────
# Change this to your own timezone (timedatectl list-timezones)
TIMEZONE="America/Vancouver"

current_tz=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "")
if [[ "$current_tz" != "$TIMEZONE" ]]; then
  info "Setting timezone to $TIMEZONE..."
  sudo timedatectl set-timezone "$TIMEZONE"
else
  info "Timezone already set to $TIMEZONE"
fi

sudo timedatectl set-ntp true
log "NTP sync enabled"

# ── Hostname ──────────────────────────────────────────────────────────────────
# Change HOSTNAME to whatever you want your machine to be called
HOSTNAME="archbox"

if [[ "$(cat /etc/hostname 2>/dev/null)" != "$HOSTNAME" ]]; then
  info "Setting hostname to $HOSTNAME..."
  echo "$HOSTNAME" | sudo tee /etc/hostname > /dev/null
  sudo hostnamectl set-hostname "$HOSTNAME"
else
  info "Hostname already set to $HOSTNAME"
fi

# ── Pacman tweaks ─────────────────────────────────────────────────────────────
PACMAN_CONF="/etc/pacman.conf"

enable_pacman_option() {
  local option="$1"
  if grep -q "^#${option}" "$PACMAN_CONF"; then
    info "Enabling pacman option: $option"
    sudo sed -i "s/^#${option}/${option}/" "$PACMAN_CONF"
  else
    info "Pacman option already set: $option"
  fi
}

enable_pacman_option "Color"
enable_pacman_option "VerbosePkgLists"
enable_pacman_option "ParallelDownloads = 5"

log "System configuration complete"