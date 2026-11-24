#!/usr/bin/with-contenv bashio
set -e

SERIAL="$(bashio::config 'serial')"
USERNAME="$(bashio::config 'username')"
PASSWORD="$(bashio::config 'password')"
VERBOSE="$(bashio::config 'verbose')"
LEGACY_DIAGNOSTIC="$(bashio::config 'diagnostic')"
LEGACY_FORCE_RELAY="$(bashio::config 'force_relay')"

if [ -z "$SERIAL" ]; then
  bashio::log.fatal "Camera serial number is required."
  exit 1
fi

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  bashio::log.fatal "Camera username and password are required for authenticated DMSS P2P."
  exit 1
fi

if [ "$LEGACY_DIAGNOSTIC" = "true" ]; then
  bashio::log.warning "The old diagnostic option is ignored; starting the RTSP tunnel."
  VERBOSE="true"
fi
if [ "$LEGACY_FORCE_RELAY" = "true" ]; then
  bashio::log.warning "The old force_relay option is retained for compatibility; DMSS app-relay is selected automatically."
fi

ARGS=(--yes --app dmss --app-relay --type 1 --username "$USERNAME" --password "$PASSWORD" --port 8554:554 "$SERIAL")

if [ "$VERBOSE" = "true" ]; then
  ARGS+=(--debug --log-retries)
fi

bashio::log.info "Starting dh-fwd v2.4.1 DMSS tunnel on container TCP port 8554."
bashio::log.info "Trying the documented empty-RandSalt Type-1 fallback when device Info is unavailable."

exec /usr/local/bin/dh-fwd "${ARGS[@]}"
