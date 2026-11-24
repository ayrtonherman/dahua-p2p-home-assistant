#!/usr/bin/with-contenv bashio
set -e

SERIAL="$(bashio::config 'serial')"
FORCE_RELAY="$(bashio::config 'force_relay')"
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

# The DMSS profile uses the app's unauthenticated P2P channel dialect.
# Camera username/password are used by the RTSP client in Home Assistant,
# not for this P2P channel handshake. Type 1 incorrectly requires a RandSalt
# Info blob which this camera did not provide in the earlier diagnostic.
ARGS=(--app dmss --type 0 --port 8554:554 --reconnect --yes "$SERIAL")

if [ "$FORCE_RELAY" = "true" ]; then
  ARGS+=(--relay)
fi

if [ "$VERBOSE" = "true" ]; then
  ARGS+=(--debug --log-retries)
fi

bashio::log.info "Starting Dahua DMSS P2P tunnel on local TCP port 8554."
bashio::log.info "RTSP camera authentication is handled by Home Assistant, not by this bridge."
if [ "$FORCE_RELAY" = "true" ]; then
  bashio::log.info "Forced relay mode is enabled."
fi

exec /usr/local/bin/dh-fwd "${ARGS[@]}"
