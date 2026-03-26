# Arch Linux Bootstrap Script (yay + pacman + reflector)

## Overview

This setup automates:

- System update (`pacman`)
- Mirror optimization (`reflector`)
- AUR helper installation (`yay`)
- Package installation (official + AUR)

It is designed to be:

- Idempotent (safe to re-run)
- Non-interactive
- Compatible with root and non-root execution
- Safe (no partial upgrades, no makepkg as root)

---

## Key Concepts

### 1. Never Run makepkg as Root

makepkg is intentionally blocked from running as root.

Correct approach:
- Build as non-root user
- Install with pacman -U as root

---

### 2. Avoid makepkg -s and -i in Scripts

| Flag | Problem |
|------|--------|
| -s | Tries to install dependencies using sudo (fails in scripts) |
| -i | Installs package interactively |

Correct approach:

``` bash
makepkg --noconfirm
pacman -U package.pkg.tar.zst
```

---

### 3. Use --needed for Idempotency

Prevents reinstalling existing packages.

``` bash
pacman -S --needed package
```

---

### 4. Avoid Partial Upgrades

Never run:
``` bash
pacman -Sy
```

Always run full upgrade:
``` bash
pacman -Syyu
```

---

## Core Function

pacman_install:

```bash
pacman_install() {
  local pkgs=("$@")

  if [[ $EUID -eq 0 ]]; then
    pacman -S --noconfirm --needed "${pkgs[@]}"
  else
    sudo pacman -S --noconfirm --needed "${pkgs[@]}"
  fi
}
```

---

## System Update + Mirrors

```bash
pacman_install reflector

reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

if [[ $EUID -eq 0 ]]; then
  pacman -Syyu --noconfirm
else
  sudo pacman -Syyu --noconfirm
fi
```

---

## Bootstrap yay

```bash
pacman_install git base-devel go

yay_tmp=$(mktemp -d)
git clone https://aur.archlinux.org/yay.git "$yay_tmp/yay"

makepkg --noconfirm
pacman -U "$yay_tmp"/yay/*.pkg.tar.zst
```

---

## Result

- System updated
- Mirrors optimized
- yay installed
- AUR ready
