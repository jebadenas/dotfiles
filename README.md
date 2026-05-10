# dotfiles

Config files for AeroSpace and WezTerm.

## Bootstrap a new Mac

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Clone this repo

```bash
git clone https://github.com/jebadenas/dotfiles.git ~/dotfiles
```

### 3. Install apps and fonts

```bash
brew install --cask aerospace wezterm
brew install --cask font-jetbrains-mono-nerd-font
```

### 4. Symlink configs

```bash
# AeroSpace
mkdir -p ~/.config/aerospace
ln -sf ~/dotfiles/aerospace/aerospace.toml ~/.config/aerospace/aerospace.toml

# WezTerm
mkdir -p ~/.config/wezterm
ln -sf ~/dotfiles/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
```

### 5. Launch AeroSpace

Open AeroSpace from Spotlight or your Applications folder. It will start automatically on future logins once running.

---

## What's included

| Tool | Config | Description |
|------|--------|-------------|
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | `aerospace/aerospace.toml` | Tiling window manager |
| [WezTerm](https://wezfurlong.org/wezterm/) | `wezterm/wezterm.lua` | Terminal emulator |

### AeroSpace key bindings

| Key | Action |
|-----|--------|
| `alt-h/j/k/l` | Focus window left/down/up/right |
| `alt-shift-h/j/k/l` | Move window left/down/up/right |
| `alt-1` through `alt-9` | Switch to workspace |
| `alt-shift-1` through `alt-shift-9` | Move window to workspace |
| `alt-tab` | Toggle between last two workspaces |
| `alt-shift-tab` | Move workspace to next monitor |
| `alt-shift-space` | Toggle floating/tiling |
| `alt-f` | Fullscreen |
| `alt-minus / alt-equal` | Resize window |
| `alt-shift-;` | Enter service mode |

### App workspace assignments

| App | Workspace |
|-----|-----------|
| WezTerm | 1 |
| Chrome | 2 |
| Spotify | 3 |
| Discord | 3 |
