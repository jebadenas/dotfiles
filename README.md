# dotfiles

Config files for AeroSpace and WezTerm.

## Bootstrap a new Mac

One-liner once you've cloned this repo:

```bash
git clone https://github.com/jebadenas/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

`bootstrap.sh` will:

1. Install Homebrew (if missing)
2. Install every formula and cask in `Brewfile` via `brew bundle`
3. Symlink `aerospace/aerospace.toml` and `wezterm/wezterm.lua` into `~/.config/`

It's idempotent — safe to re-run after editing the Brewfile.

### Refreshing the Brewfile from your current Mac

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force --describe
```

### Manual follow-ups (Brew can't do these)

- Launch AeroSpace from `/Applications` and grant Accessibility permission
- `gh auth login`
- `aws configure` (or `aws sso login`)
- `az login`
- Copy `~/.ssh/` from old Mac (do NOT commit)
- Copy `~/.kube/config` if needed
- Sign in to Slack, Chrome, Postman; export/import DBeaver connections

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
