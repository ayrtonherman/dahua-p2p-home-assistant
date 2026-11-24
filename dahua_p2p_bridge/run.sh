#!/usr/bin/with-contenv bashio
set -e

SERIAL="$(bashio::config 'serial')"
USERNAME="$(bashio::config 'username')"
PASSWORD="$(bashio::config 'password')"
VERBOSE="$(bashio::config 'verbose')"

if [ -z "$SERIAL" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  bashio::log.fatal "Serial number, camera username and camera password are required."
  exit 1
fi

ARGS=(--app dmss --type 1 --username "$USERNAME" --password "$PASSWORD" --port 8554:554 --reconnect --yes "$SERIAL")
if [ "$VERBOSE" = "true" ]; then
  ARGS+=(--debug)
fi

bashio::log.info "Starting authenticated Dahua DMSS P2P tunnel; local RTSP port 8554."
exec /usr/local/bin/dh-fwd "${ARGS[@]}"
