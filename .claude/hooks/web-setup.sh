#!/usr/bin/env bash
# Bootstraps a Claude Code on the web (cloud) session so bin/rspec and
# bin/rubocop work. No-op on local machines.
set -euo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

cd "$CLAUDE_PROJECT_DIR"
log() { echo "[web-setup] $*" >&2; }

SUDO=""
[ "$(id -u)" -eq 0 ] || SUDO="sudo"

# System packages: Postgres, libvips (ruby-vips), headless Chrome for system specs
if ! command -v pg_ctlcluster >/dev/null || ! dpkg -s libvips-dev >/dev/null 2>&1; then
  log "installing system packages"
  $SUDO apt-get update -qq
  $SUDO apt-get install -y -qq postgresql libvips-dev libpq-dev chromium >/dev/null ||
    $SUDO apt-get install -y -qq postgresql libvips-dev libpq-dev chromium-browser >/dev/null || true
fi

# Postgres on the port expected by config/database.yml (54321), user postgres/postgres
PG_VERSION=$(ls /etc/postgresql | sort -V | tail -1)
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
if ! grep -q "^port = 54321" "$PG_CONF"; then
  $SUDO sed -i "s/^port = .*/port = 54321/" "$PG_CONF"
fi
$SUDO pg_ctlcluster "$PG_VERSION" main restart
$SUDO -u postgres psql -p 54321 -qc "ALTER USER postgres PASSWORD 'postgres';"

# Ruby version from .ruby-version
RUBY_WANTED=$(cat .ruby-version)
if [ "$(ruby -e 'print RUBY_VERSION' 2>/dev/null || true)" != "$RUBY_WANTED" ]; then
  log "installing ruby $RUBY_WANTED (slow the first time)"
  if command -v rbenv >/dev/null; then
    rbenv install -s "$RUBY_WANTED"
    eval "$(rbenv init - bash)"
  elif command -v mise >/dev/null; then
    mise install "ruby@$RUBY_WANTED"
    eval "$(mise activate bash)"
  else
    log "no rbenv/mise found, cannot install ruby $RUBY_WANTED"
    exit 1
  fi
fi

log "bundle install"
bundle install --quiet --jobs 4

log "preparing test database"
RAILS_ENV=test bin/rails db:prepare >/dev/null

# Persist env for the rest of the session
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  command -v rbenv >/dev/null && echo 'eval "$(rbenv init - bash)"' >> "$CLAUDE_ENV_FILE"
  command -v mise >/dev/null && echo 'eval "$(mise activate bash)"' >> "$CLAUDE_ENV_FILE"
fi

log "ready: bin/rspec and bin/rubocop available"
