# Dotfiles

My personal Arch Linux configuration, managed as a single repo.
One command gets a fresh machine from zero to fully configured.

## Quick start — base system

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

## Quick start — base + Hyprland WM

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh --with-hyprland

# Drop a wallpaper in place, then start Hyprland
cp ~/Pictures/mywallpaper.jpg ~/.config/wallpapers/wallpaper.jpg
Hyprland
```

Both are idempotent — safe to run again at any time.

---

## What gets installed

### Base modules

| Module | What it does |
|---|---|
| `system.sh` | Sets locale, timezone, hostname, pacman options |
| `packages.sh` | Installs pacman packages + AUR packages via `yay` |
| `symlinks.sh` | Links config files from this repo into `$HOME` |
| `services.sh` | Enables systemd services (sshd, NTP, etc.) |

### Hyprland module (`--with-hyprland`)

| Tool | Role |
|---|---|
| **Hyprland** | Wayland tiling window manager |
| **Waybar** | Status bar (workspaces, clock, volume, battery, network) |
| **Swaync** | Notification daemon + notification center |
| **Wofi** | Application launcher |
| **Hyprlock** | Lock screen |
| **Hyperpaper** | Wallpaper manager (multi-monitor) |
| **swww** | Animated wallpaper daemon (alternative to Hyperpaper) |
| **wlogout** | Logout / power menu |
| **swayidle** | Idle management (dim → lock → suspend) |
| **Nautilus** | File manager |
| **Kitty** | Wayland-native terminal |
| **Pipewire** | Audio stack (replaces PulseAudio) |
| **pavucontrol** | GUI volume mixer |
| **grim + slurp** | Screenshot tools |
| **hyprshot** | Screenshot wrapper |
| **hyprpicker** | Colour picker |
| **cliphist** | Clipboard history |
| **NetworkManager** | Network management + tray icon |
| **Bluez + Blueberry** | Bluetooth + GUI |
| **Catppuccin Mocha** | GTK + Hyprland colour theme |
| **Papirus-Dark** | Icon theme |

---

## Config files managed

### Base
| Tool | Repo path | Links to |
|---|---|---|
| bash | `configs/bash/.bashrc` | `~/.bashrc` |
| bash | `configs/bash/.bash_profile` | `~/.bash_profile` |
| git | `configs/git/.gitconfig` | `~/.gitconfig` |
| tmux | `configs/tmux/.tmux.conf` | `~/.tmux.conf` |
| neovim | `configs/nvim/` | `~/.config/nvim/` |
| alacritty | `configs/alacritty/` | `~/.config/alacritty/` |

### Hyprland
| Tool | Repo path | Links to |
|---|---|---|
| Hyprland | `configs/hypr/hyprland/` | `~/.config/hypr/` |
| Waybar | `configs/hypr/waybar/` | `~/.config/waybar/` |
| Swaync | `configs/hypr/swaync/` | `~/.config/swaync/` |
| Wofi | `configs/hypr/wofi/` | `~/.config/wofi/` |
| Hyprlock | `configs/hypr/hyprlock/` | `~/.config/hyprlock/` |
| Hyperpaper | `configs/hypr/hyperpaper/` | `~/.config/hyperpaper/` |

---

## Flags

```bash
bash install.sh --with-hyprland    # include full Hyprland WM setup
bash install.sh --skip-packages    # skip pacman/yay installs
bash install.sh --skip-system      # skip locale/timezone/hostname
bash install.sh --skip-services    # skip systemd service setup
```

Flags can be combined:

```bash
# Re-apply only symlinks on an already-configured machine
bash install.sh --skip-packages --skip-system --skip-services
```

---

## Hyprland keybindings (quick reference)

| Binding | Action |
|---|---|
| `Super + Return` | Open terminal (kitty) |
| `Super + Space` | Open launcher (wofi) |
| `Super + B` | Open browser |
| `Super + E` | Open file manager |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + H/J/K/L` | Move focus |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + 1–0` | Switch workspace |
| `Super + Shift + 1–0` | Move window to workspace |
| `Super + S` | Toggle scratchpad |
| `Super + L` | Lock screen |
| `Super + Shift + Escape` | Power menu (wlogout) |
| `Super + Shift + N` | Toggle notification center |
| `Super + Shift + C` | Colour picker |
| `Super + C` | Clipboard history |
| `Print` | Screenshot (full screen) |
| `Shift + Print` | Screenshot (select region) |
| `Super + Print` | Screenshot (focused window) |

---

## Personalise before first push

1. `configs/git/.gitconfig` — set your name and email
2. `modules/system.sh` — set `HOSTNAME` and `TIMEZONE`
3. `modules/packages.sh` — add/remove packages to taste
4. `configs/hypr/hyprland/monitors.conf` — set your monitor name and resolution
5. `configs/hypr/hyprland/autostart.conf` — switch between `swww` and `hyperpaper`

---

## Machine-specific overrides

Anything not tracked in git goes in `~/.bashrc.local` — sourced at the end of
`.bashrc` and gitignored by convention. Use it for work proxies, private
tokens, machine-specific aliases, etc.

---

## Push to GitHub

```bash
cd ~/dotfiles
git init
git add .
git commit -m "initial dotfiles"
git remote add origin https://github.com/YOUR_USERNAME/dotfiles.git
git push -u origin main
```

---

## Repo layout

```
dotfiles/
├── install.sh
├── lib/
│   └── helpers.sh
├── modules/
│   ├── system.sh
│   ├── packages.sh
│   ├── symlinks.sh
│   ├── services.sh
│   └── hyprland.sh          ← opt-in with --with-hyprland
└── configs/
    ├── bash/
    ├── nvim/
    ├── tmux/
    ├── git/
    ├── alacritty/
    └── hypr/
        ├── hyprland/        ← hyprland.conf + colors, monitors, keybinds, rules, autostart
        ├── waybar/          ← config.jsonc + style.css
        ├── swaync/          ← config.json + style.css
        ├── wofi/            ← config + style.css
        ├── hyprlock/        ← hyprlock.conf
        └── hyperpaper/      ← config
```
