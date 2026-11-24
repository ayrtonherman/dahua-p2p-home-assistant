#!/usr/bin/with-contenv bashio
set -e

SERIAL="$(bashio::config 'serial')"
USERNAME="$(bashio::config 'username')"
PASSWORD="$(bashio::config 'password')"
VERBOSE="$(bashio::config 'verbose')"
DIAGNOSTIC="$(bashio::config 'diagnostic')"

if [ -z "$SERIAL" ]; then
  bashio::log.fatal "Camera serial number is required."
  exit 1
fi

if [ "$DIAGNOSTIC" = "true" ]; then
  bashio::log.info "Running DMSS device-info diagnostic only; no RTSP tunnel will be opened."
  exec /usr/local/bin/dh-fwd --app dmss --info --debug --yes "$SERIAL"
fi

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  bashio::log.fatal "Camera username and camera password are required."
  exit 1
fi

ARGS=(--app dmss --type 1 --username "$USERNAME" --password "$PASSWORD" --port 8554:554 --reconnect --yes "$SERIAL")
if [ "$VERBOSE" = "true" ]; then
  ARGS+=(--debug)
fi

bashio::log.info "Starting authenticated Dahua DMSS P2P tunnel; local RTSP port 8554."
exec /usr/local/bin/dh-fwd "${ARGS[@]}"
