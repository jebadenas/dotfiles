#!/usr/bin/env bash
set -euo pipefail

auth_file="${JIRA_AUTH_FILE:-$HOME/.config/copilot/jira.env}"
base_url_default="${JIRA_BASE_URL:-https://eroad.atlassian.net}"

mkdir -p "$(dirname "$auth_file")"

read -r "jira_email?Jira email: "
read -s -r "jira_api_token?Jira API token: "
echo
read -r "jira_base_url?Jira base URL [${base_url_default}]: "

if [[ -z "$jira_email" || -z "$jira_api_token" ]]; then
  echo "Email and API token are required." >&2
  exit 1
fi

if [[ -z "$jira_base_url" ]]; then
  jira_base_url="$base_url_default"
fi

cat > "$auth_file" <<EOF
export JIRA_EMAIL="$jira_email"
export JIRA_API_TOKEN="$jira_api_token"
export JIRA_BASE_URL="$jira_base_url"
EOF

chmod 600 "$auth_file"

zshrc_file="$HOME/.zshrc"
source_line="source \"$auth_file\""
if [[ -f "$zshrc_file" ]]; then
  if ! grep -Fq "$source_line" "$zshrc_file"; then
    printf '\n# Jira attachment sync auth\n%s\n' "$source_line" >> "$zshrc_file"
  fi
else
  printf '# Jira attachment sync auth\n%s\n' "$source_line" > "$zshrc_file"
fi

echo "Saved Jira auth to $auth_file"
echo "Added source line to $zshrc_file"
echo "Open a new shell or run: source \"$auth_file\""
