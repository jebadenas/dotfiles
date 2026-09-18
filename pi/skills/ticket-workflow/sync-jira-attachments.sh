#!/usr/bin/env bash
set -euo pipefail

auth_file="${JIRA_AUTH_FILE:-$HOME/.config/copilot/jira.env}"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <TICKET-KEY> [OUTPUT_DIR]" >&2
  exit 1
fi

ticket_key="$1"
output_dir="${2:-}"

# Auto-load Jira auth from a dedicated file if env vars are not already set.
if [[ -f "$auth_file" ]]; then
  # shellcheck disable=SC1090
  source "$auth_file"
fi

if [[ -z "${JIRA_EMAIL:-}" || -z "${JIRA_API_TOKEN:-}" ]]; then
  echo "Missing Jira credentials. Set JIRA_EMAIL and JIRA_API_TOKEN." >&2
  echo "Tip: run ~/.pi/agent/skills/ticket-workflow/setup-jira-auth.sh once." >&2
  exit 1
fi

jira_base_url="${JIRA_BASE_URL:-https://eroad.atlassian.net}"

if [[ -z "$output_dir" ]]; then
  session_id="${PI_SESSION_ID:-${COPILOT_SESSION_ID:-manual}}"
  output_dir="$HOME/.pi/agent/tickets/${ticket_key}/attachments"
fi

mkdir -p "$output_dir"

tmp_json="$(mktemp)"
trap 'rm -f "$tmp_json"' EXIT

python3 - "$ticket_key" "$jira_base_url" "$JIRA_EMAIL" "$JIRA_API_TOKEN" "$output_dir" "$tmp_json" <<'PY'
import base64
import json
import os
import pathlib
import re
import sys
import urllib.error
import urllib.request

ticket_key, base_url, email, token, output_dir, out_json = sys.argv[1:7]

api_url = f"{base_url}/rest/api/3/issue/{ticket_key}?fields=attachment"
auth = base64.b64encode(f"{email}:{token}".encode("utf-8")).decode("ascii")

req = urllib.request.Request(api_url)
req.add_header("Authorization", f"Basic {auth}")
req.add_header("Accept", "application/json")

try:
    with urllib.request.urlopen(req) as resp:
        issue = json.loads(resp.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    body = e.read().decode("utf-8", errors="replace")
    print(f"Failed to fetch issue {ticket_key}: HTTP {e.code}\n{body}", file=sys.stderr)
    sys.exit(2)
except urllib.error.URLError as e:
    print(f"Failed to fetch issue {ticket_key}: {e}", file=sys.stderr)
    sys.exit(2)

attachments = (issue.get("fields", {}) or {}).get("attachment", []) or []
pathlib.Path(output_dir).mkdir(parents=True, exist_ok=True)

def safe_name(name: str) -> str:
    # Preserve extension but remove unsafe path characters.
    cleaned = re.sub(r"[^A-Za-z0-9._-]+", "_", name.strip())
    return cleaned or "attachment"

index_rows = []
downloaded = 0

for att in attachments:
    att_id = str(att.get("id", ""))
    filename = att.get("filename") or f"attachment_{att_id}"
    content_url = att.get("content")
    mime_type = att.get("mimeType", "")
    size = att.get("size", 0)

    row = {
        "id": att_id,
        "filename": filename,
        "mimeType": mime_type,
        "size": size,
        "contentUrl": content_url,
        "thumbnailUrl": att.get("thumbnail"),
        "downloadedPath": None,
        "status": "skipped",
        "error": None,
    }

    if not content_url:
        row["error"] = "Missing content URL"
        index_rows.append(row)
        continue

    local_name = safe_name(filename)
    local_path = pathlib.Path(output_dir) / local_name

    # Avoid collisions by suffixing with attachment ID.
    if local_path.exists() and local_path.is_file():
        stem = local_path.stem
        suffix = local_path.suffix
        local_path = pathlib.Path(output_dir) / f"{stem}_{att_id}{suffix}"

    dl_req = urllib.request.Request(content_url)
    dl_req.add_header("Authorization", f"Basic {auth}")
    dl_req.add_header("Accept", "*/*")

    try:
        with urllib.request.urlopen(dl_req) as resp, open(local_path, "wb") as out:
            out.write(resp.read())
        downloaded += 1
        row["status"] = "downloaded"
        row["downloadedPath"] = str(local_path)
    except Exception as e:
        row["status"] = "failed"
        row["error"] = str(e)

    index_rows.append(row)

summary = {
    "ticket": ticket_key,
    "jiraBaseUrl": base_url,
    "outputDir": str(pathlib.Path(output_dir)),
    "attachmentCount": len(attachments),
    "downloadedCount": downloaded,
    "attachments": index_rows,
}

with open(out_json, "w", encoding="utf-8") as f:
    json.dump(summary, f, indent=2)
PY

mv "$tmp_json" "$output_dir/attachments-index.json"

echo "Synced attachments for $ticket_key"
echo "Index: $output_dir/attachments-index.json"
