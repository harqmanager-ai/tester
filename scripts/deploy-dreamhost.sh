#!/usr/bin/env bash
# Opt-in rsync uploader. No connection is made until all prerequisites pass.
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
if [[ ! -f $DREAMHOST_SSH_KEY_FILE || ! -s $DREAMHOST_SSH_KEY_FILE || ! -f $DREAMHOST_KNOWN_HOSTS_FILE || ! -s $DREAMHOST_KNOWN_HOSTS_FILE ]]; then
  printf 'An existing SSH key file and verified known_hosts file are required.\n' >&2
  exit 2
fi
site_dir=$(cd -- "$2" && pwd -P)
for file in index.html styles.css script.js; do
  if [[ ! -f "$site_dir/$file" || ! -s "$site_dir/$file" || -L "$site_dir/$file" ]]; then
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
if ! command -v rsync >/dev/null || ! command -v ssh >/dev/null; then
  printf 'The deployment runner needs rsync and OpenSSH.\n' >&2
  exit 2
fi

# A wrapper passes each SSH option as a separate argument, including key paths
# containing spaces. No credentials or remote shell commands are written here.
ssh_dir=$(mktemp -d "${TMPDIR:-/tmp}/harqmedia-ssh.XXXXXX")
trap 'rm -rf -- "$ssh_dir"' EXIT
ssh_wrapper="$ssh_dir/ssh"
cat > "$ssh_wrapper" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exec ssh -F /dev/null -p "$DREAMHOST_PORT" -i "$DREAMHOST_SSH_KEY_FILE" \
  -o BatchMode=yes -o IdentitiesOnly=yes -o IdentityAgent=none \
  -o StrictHostKeyChecking=yes -o UpdateHostKeys=no \
  -o "UserKnownHostsFile=$DREAMHOST_KNOWN_HOSTS_FILE" \
  -o GlobalKnownHostsFile=/dev/null \
  -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no \
  -o ConnectTimeout=15 -o ServerAliveInterval=15 -o ServerAliveCountMax=2 \
  "$@"
EOF
chmod 700 "$ssh_wrapper"
export DREAMHOST_PORT="$port" DREAMHOST_SSH_KEY_FILE DREAMHOST_KNOWN_HOSTS_FILE
# rsync's remote-shell parser uses doubled quotes for literal quote characters.
ssh_command="\"${ssh_wrapper//\"/\"\"}\""
destination="$DREAMHOST_USER@$DREAMHOST_HOST:$remote_dir/"

# Exclusions must precede the assets allowlist, including for nested files.
# There is deliberately no --delete or --delete-excluded option: existing
# remote files stay in place, and .htaccess is never sent or overwritten.
rsync_options=(
  --recursive --times --perms --chmod=D755,F644 --compress --delay-updates
  --rsh="$ssh_command"
  --exclude='.htaccess'
  --exclude='.git' --exclude='.github'
  --exclude='[Rr][Ee][Aa][Dd][Mm][Ee]*'
  --exclude='scripts/' --exclude='deployment/'
)

# Publish dependencies before the homepage. Only these public paths can pass,
# even if the supplied source folder contains repository or deployment files.
rsync "${rsync_options[@]}" \
  --include='/styles.css' --include='/script.js' \
  --include='/assets/' --include='/assets/***' --exclude='*' \
  "$site_dir/" "$destination"
rsync "${rsync_options[@]}" \
  --include='/index.html' --exclude='*' \
  "$site_dir/" "$destination"
