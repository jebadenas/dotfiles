#!/usr/bin/env bash
# get-db-password.sh <ENV> [--refresh] [--copy]
#
# Decrypts the EROAD dbdepot developer password for the given environment,
# caches it locally, and prints it to stdout (or copies to clipboard with --copy).
#
# Environments: dev, test, apacpp, napp, apac, na
# Cache: ~/.config/copilot/db-passwords/<env>.env  (chmod 600)
#
# Usage:
#   get-db-password.sh apac            # use cache if available
#   get-db-password.sh apac --refresh  # force re-decrypt from KMS
#   get-db-password.sh apac --copy     # put password in clipboard (no stdout)

set -eo pipefail

CACHE_DIR="${DB_PASSWORD_CACHE_DIR:-$HOME/.config/copilot/db-passwords}"
AWS_PROFILE="${AWS_PROFILE:-default}"

# ── Argument parsing ────────────────────────────────────────────────────────────
if [ $# -lt 1 ]; then
  echo "Usage: $0 <env> [--refresh] [--copy]" >&2
  echo "Environments: dev test apacpp napp apac na" >&2
  exit 1
fi

env_key="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
refresh=false
copy_mode=false

shift
for arg in "$@"; do
  case "$arg" in
    --refresh) refresh=true ;;
    --copy)    copy_mode=true ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# ── Environment lookup (bash 3.x compatible, no associative arrays) ─────────────
get_region() {
  case "$1" in
    dev|test|apacpp|apac) echo "ap-southeast-2" ;;
    napp|na)              echo "us-west-2" ;;
    *) echo "" ;;
  esac
}

get_secret() {
  case "$1" in
    dev)    echo "secret_AQECAHgYgRQH6Y5MUD8J1lSC+cx2nJaldqey5GAffJyoTqp0qgAAAHYwdAYJKoZIhvcNAQcGoGcwZQIBADBgBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDDb8aCqNOQTW8hSc3QIBEIAzDHy4VHK/5WpYb8dE7RkCtz6GcrPbPStgM8LPKqmSdme1sKW/GYQLlBnPkJFSfULRHTb3" ;;
    test)   echo "secret_AQECAHgYgRQH6Y5MUD8J1lSC+cx2nJaldqey5GAffJyoTqp0qgAAAHYwdAYJKoZIhvcNAQcGoGcwZQIBADBgBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDK1e+yBsHjOEBzsrVgIBEIAzivPx2/lvYq3ul7Gk9KLKw6Hr51oJHQXURBzh24Gov6R7+yAO1sRTp9HnYca9ST6yArcG" ;;
    apacpp) echo "secret_AQECAHjoq9uzn39orolpW59zaS/Txak55EuR3kZBAXO85PrOsgAAAHYwdAYJKoZIhvcNAQcGoGcwZQIBADBgBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDNx2lKF3I6n8iTBr/wIBEIAzbH/O1KxQMrhJxH2f5hE/9y2kSxh2OY9D5y6IEA0ZrnaehD3Zo686VA7QeFhMUrHDF4m8" ;;
    napp)   echo "secret_AQECAHjMuZMnP1ssBUvWDHWcN0OnanZd9iYFCOqG4KKNHvkT9AAAAHYwdAYJKoZIhvcNAQcGoGcwZQIBADBgBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDPcLfYvIlUg5Vt+KtAIBEIAzOdnA5ofz+e3yoI3Wd5+cj7Nd7F91noOK0iy3tJBF2vtXVkKJu70kIinKmbQilWQHE/Ad" ;;
    apac)   echo "secret_AQECAHh/te0wYJZ1mjf64EE8TvMNQ6gjtf8xhqOvQHo668TfIAAAAHYwdAYJKoZIhvcNAQcGoGcwZQIBADBgBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDOSczuMa1tUEe6QHVAIBEIAzLnmMJrhOJ6L9F5zCPTcZdMO5LDS9A1hAXMl1d12J6gja3PJWdy/RvO0eFgRJ5UUlXt7r" ;;
    na)     echo "secret_AQECAHgwEb5brGRc0WL35jlwuZjeGQGiKksoDDLqcnx1BXbpsAAAAHYwdAYJKoZIhvcNAQcGoGcwZQIBADBgBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDDw3HJO/g/k/EDANIwIBEIAzYFeRgCRbXG3cg1yMS8PoDXSuAxIuXhO5THlhnzPql/QSzw/0m8gdy/un0AvSekyCQWl/" ;;
    *) echo "" ;;
  esac
}

region="$(get_region "$env_key")"
secret="$(get_secret "$env_key")"

if [ -z "$region" ] || [ -z "$secret" ]; then
  echo "Unknown environment: $env_key. Valid: dev test apacpp napp apac na" >&2
  exit 1
fi

cache_file="$CACHE_DIR/${env_key}.env"
mkdir -p "$CACHE_DIR"
chmod 700 "$CACHE_DIR"

# ── Use cache if available and not forcing refresh ──────────────────────────────
if [ "$refresh" = false ] && [ -f "$cache_file" ]; then
  . "$cache_file"
  if [ -n "${DB_DEVELOPER_PASSWORD:-}" ]; then
    if [ "$copy_mode" = true ]; then
      printf '%s' "$DB_DEVELOPER_PASSWORD" | pbcopy
      echo "[$env_key] Password copied from cache." >&2
    else
      printf '%s' "$DB_DEVELOPER_PASSWORD"
    fi
    exit 0
  fi
fi

# ── Decrypt from KMS ────────────────────────────────────────────────────────────
echo "[$env_key] Cache miss — decrypting from KMS..." >&2

# Ensure AWS SSO session is valid; re-login if expired.
if ! aws sts get-caller-identity --profile "$AWS_PROFILE" >/dev/null 2>&1; then
  echo "[$env_key] AWS SSO session expired. Logging in..." >&2
  aws sso login --profile "$AWS_PROFILE"
fi

# Export short-lived credentials (configuration-cmd requires env vars, not SSO profile).
eval "$(aws configure export-credentials --profile "$AWS_PROFILE" --format env)"

password="$(configuration-cmd decrypt -region "$region" -secret "$secret" | tr -d '\r\n')"

if [ -z "$password" ]; then
  echo "[$env_key] Decryption returned empty password." >&2
  exit 1
fi

# Write to cache with strict permissions.
printf 'DB_DEVELOPER_PASSWORD="%s"\n' "$password" > "$cache_file"
chmod 600 "$cache_file"

echo "[$env_key] Password cached at $cache_file" >&2

if [ "$copy_mode" = true ]; then
  printf '%s' "$password" | pbcopy
  echo "[$env_key] Password copied to clipboard." >&2
else
  printf '%s' "$password"
fi
