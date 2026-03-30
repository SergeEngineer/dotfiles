#!/usr/bin/env bash
# =============================================================================
# dotfiles/modules/services.sh — enable & start systemd services
# Sourced by install.sh — helpers already loaded.
# =============================================================================

# enable_service <name> [--user]
#   --user  → runs as systemctl --user (for user-level services)
enable_service() {
  local svc="$1"
  local user_flag=""
  [[ "${2:-}" == "--user" ]] && user_flag="--user"

  # shellcheck disable=SC2086
  if systemctl $user_flag is-enabled "$svc" &>/dev/null; then
    info "$svc — already enabled, skipping"
  else
    info "Enabling $svc..."
    # shellcheck disable=SC2086
    elevate systemctl $user_flag enable --now "$svc"
  fi
}

# ── System-level (core) services ─────────────────────────────────────────────────────
enable_service "sshd"             # SSH daemon
enable_service "systemd-timesyncd" # NTP time sync
enable_service "fstrim.timer"

# ── Networking ───────────────────────────────────────
enable_service "NetworkManager"

# ── Hardware ─────────────────────────────────────────
enable_service "bluetooth"

# ── Security ─────────────────────────────────────────
enable_service "ufw"

# ── Add more services below as you need them ──────────────────────────────────
# enable_service "docker"
# enable_service "bluetooth"
# enable_service "cups"           # printing

# ── Maintenance ──────────────────────────────────────
# enable_service "paccache.timer"

log "Services configured"