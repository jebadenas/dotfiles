#!/usr/bin/env bash
# Bootstrap a new Mac from this dotfiles repo.
# Idempotent — safe to re-run.

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

log()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m  %s\n" "$*"; }

# 1. Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apple Silicon brew lives in /opt/homebrew; Intel in /usr/local
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. Install everything from Brewfile
if [ -f "$DOTFILES/Brewfile" ]; then
  log "Running brew bundle (this can take a while)..."
  brew bundle install --file="$DOTFILES/Brewfile"
else
  warn "No Brewfile found at $DOTFILES/Brewfile — skipping"
fi

# 3. Symlink configs
link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    log "Already linked: $dest"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing $dest -> $backup"
    mv "$dest" "$backup"
  fi
  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

log "Symlinking configs..."
link "$DOTFILES/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"
link "$DOTFILES/wezterm/wezterm.lua"      "$HOME/.config/wezterm/wezterm.lua"

log "Done. Next steps:"
cat <<'EOF'

  - Launch AeroSpace from /Applications (grants Accessibility permission on first run)
  - gh auth login
  - aws configure   (or aws sso login)
  - az login
  - Copy ~/.ssh/ from old Mac (do NOT commit)
  - Copy ~/.kube/config from old Mac if you need cluster access
  - Sign in to Slack, Chrome, Postman, DBeaver

EOF
