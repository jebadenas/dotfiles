#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"

selection=$(herdr tab list --workspace "$HERDR_ACTIVE_WORKSPACE_ID" \
  | jq -r '.result.tabs[] | "\(.tab_id)\t\(.label)"' \
  | fzf --with-nth=2 --prompt="Move pane to tab: ")

tab_id=$(echo "$selection" | awk '{print $1}')

if [[ -n "$tab_id" ]]; then
  herdr pane move "$HERDR_ACTIVE_PANE_ID" --tab "$tab_id" --split right
fi
