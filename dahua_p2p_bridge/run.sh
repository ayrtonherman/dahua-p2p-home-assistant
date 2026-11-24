#!/usr/bin/with-contenv bashio
set -e

SERIAL="$(bashio::config 'serial')"
FORCE_RELAY="$(bashio::config 'force_relay')"
VERBOSE="$(bashio::config 'verbose')"
LEGACY_DIAGNOSTIC="$(bashio::config 'diagnostic')"

if [ -z "$SERIAL" ]; then
  bashio::log.fatal "Camera serial number is required."
  exit 1
fi

# Keep compatibility with existing saved options from version 0.2.x.
# The old diagnostic flag must no longer prevent the actual tunnel from starting.
if [ "$LEGACY_DIAGNOSTIC" = "true" ]; then
  bashio::log.warning "The old diagnostic-only setting is ignored; starting the RTSP tunnel."
  VERBOSE="true"
fi

# DMSS profile uses its own P2P channel dialect without Type-1 channel auth.
# Camera credentials are used by Home Assistant's RTSP client, not here.
# Type 1 is deliberately not used: this camera's Info response had no RandSalt blob.
ARGS=(--app dmss --type 0 --port 8554:554 --reconnect --yes "$SERIAL")

if [ "$FORCE_RELAY" = "true" ]; then
  ARGS+=(--relay)
fi

if [ "$VERBOSE" = "true" ]; then
  ARGS+=(--debug --log-retries)
fi

bashio::log.info "Starting Dahua DMSS P2P tunnel on local TCP port 8554."
bashio::log.info "Camera RTSP username/password are used in Home Assistant's stream URL."
if [ "$FORCE_RELAY" = "true" ]; then
  bashio::log.info "Forced relay mode is enabled."
fi

exec /usr/local/bin/dh-fwd "${ARGS[@]}"
