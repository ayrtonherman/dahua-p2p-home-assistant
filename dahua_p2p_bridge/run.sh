#!/usr/bin/with-contenv bashio
set -e

SERIAL="$(bashio::config 'serial')"
USERNAME="$(bashio::config 'username')"
PASSWORD="$(bashio::config 'password')"
FORCE_RELAY="$(bashio::config 'force_relay')"
VERBOSE="$(bashio::config 'verbose')"
LEGACY_DIAGNOSTIC="$(bashio::config 'diagnostic')"

if [ -z "$SERIAL" ]; then
  bashio::log.fatal "Camera serial number is required."
  exit 1
fi

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  bashio::log.fatal "Camera username and password are required for authenticated DMSS P2P."
  exit 1
fi

# Keep compatibility with existing saved options from version 0.2.x.
if [ "$LEGACY_DIAGNOSTIC" = "true" ]; then
  bashio::log.warning "The old diagnostic-only setting is ignored; starting the RTSP tunnel."
  VERBOSE="true"
fi

# This camera returns 404 for /info/device/<SN>. The build patch implements
# Dahua's documented no-RandSalt Type-1 auth path for this firmware.
ARGS=(--app dmss --type 1 --username "$USERNAME" --password "$PASSWORD" --port 8554:554 --reconnect "$SERIAL")

if [ "$FORCE_RELAY" = "true" ]; then
  ARGS+=(--relay)
fi

if [ "$VERBOSE" = "true" ]; then
  ARGS+=(--debug --log-retries)
fi

bashio::log.info "Starting authenticated Dahua DMSS P2P tunnel on local TCP port 8554."
bashio::log.info "Camera credentials are used for P2P channel authentication and RTSP."
if [ "$FORCE_RELAY" = "true" ]; then
  bashio::log.info "Forced relay mode is enabled."
fi

exec /usr/local/bin/dh-fwd "${ARGS[@]}"
