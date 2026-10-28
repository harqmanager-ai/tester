#!/usr/bin/env bash
# Future opt-in uploader. Never invoked by a committed active workflow.
set -euo pipefail

if [[ ${1:-} == --help ]]; then
  printf 'Usage: bash scripts/deploy-dreamhost.sh --deploy PREPARED_SITE_DIRECTORY\n'
  printf 'Requires DREAMHOST_DEPLOY_ENABLED=true and the settings documented in deployment/README.md.\n'
  exit 0
fi
if [[ $# != 2 || $1 != --deploy || ${DREAMHOST_DEPLOY_ENABLED:-false} != true ]]; then
  printf 'Deployment is disabled. Both --deploy and DREAMHOST_DEPLOY_ENABLED=true are required.\n' >&2
  exit 2
fi

for setting in DREAMHOST_HOST DREAMHOST_USER DREAMHOST_WEB_ROOT DREAMHOST_SSH_KEY_FILE DREAMHOST_KNOWN_HOSTS_FILE; do
  if [[ -z ${!setting:-} ]]; then
    printf 'Missing required setting: %s\n' "$setting" >&2
    exit 2
  fi
done
if [[ ! $DREAMHOST_HOST =~ ^[A-Za-z0-9][A-Za-z0-9.-]*$ || ! $DREAMHOST_USER =~ ^[A-Za-z0-9_][A-Za-z0-9_-]*$ ]]; then
  printf 'Invalid SSH hostname or user.\n' >&2
  exit 2
fi
remote_dir=${DREAMHOST_WEB_ROOT%/}
if [[ ! $remote_dir =~ ^/[A-Za-z0-9._/-]+$ || $remote_dir == / || $remote_dir == *'/../'* || $remote_dir == *'/..' || $remote_dir == *'/./'* || $remote_dir == *'/.' ]]; then
  printf 'DREAMHOST_WEB_ROOT must be the exact absolute web directory, without traversal.\n' >&2
  exit 2
fi
port=${DREAMHOST_PORT:-22}
if [[ ! $port =~ ^[0-9]{1,5}$ ]] || (( 10#$port < 1 || 10#$port > 65535 )); then
  printf 'DREAMHOST_PORT must be between 1 and 65535.\n' >&2
  exit 2
fi
if [[ ! -s $DREAMHOST_SSH_KEY_FILE || ! -s $DREAMHOST_KNOWN_HOSTS_FILE ]]; then
  printf 'An existing SSH key file and verified known_hosts file are required.\n' >&2
  exit 2
fi
site_dir=$(cd -- "$2" && pwd -P)
for file in index.html styles.css script.js; do
  if [[ ! -s "$site_dir/$file" || -L "$site_dir/$file" ]]; then
    printf 'The prepared site is missing a regular nonempty %s file.\n' "$file" >&2
    exit 2
  fi
done
if [[ ! -d "$site_dir/assets" || -L "$site_dir/assets" || -n $(find "$site_dir/assets" -type l -print -quit) ]]; then
  printf 'The prepared assets directory is missing or contains symbolic links.\n' >&2
  exit 2
fi
if [[ $site_dir == *$'\n'* || $site_dir == *$'\r'* ]]; then
  printf 'The local site path cannot contain line breaks.\n' >&2
  exit 2
fi
# Escape the local path for the SFTP batch parser; no remote shell is used.
quoted_site=${site_dir//\\/\\\\}
quoted_site=${quoted_site//\"/\\\"}
batch_file=$(mktemp "${TMPDIR:-/tmp}/harqmedia-sftp.XXXXXX")
trap 'rm -f -- "$batch_file"' EXIT
cat > "$batch_file" <<EOF
lcd "$quoted_site"
cd "$remote_dir"
put styles.css
put script.js
put -r assets
put index.html
EOF

# Fail closed on unknown/changed host keys. Never delete existing remote files.
sftp -b "$batch_file" -i "$DREAMHOST_SSH_KEY_FILE" -P "$port" \
  -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes \
  -o "UserKnownHostsFile=$DREAMHOST_KNOWN_HOSTS_FILE" \
  -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no \
  "$DREAMHOST_USER@$DREAMHOST_HOST"
