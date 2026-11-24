#!/usr/bin/with-contenv bashio
set -e

SERIAL="$(bashio::config 'serial')"
VERBOSE="$(bashio::config 'verbose')"

if [ -z "$SERIAL" ]; then
  bashio::log.fatal "A Dahua device serial number is required in the add-on configuration."
  exit 1
fi

ARGS=(tunnel "$SERIAL" --listen 8554 --remote 554 --host 0.0.0.0)
if [ "$VERBOSE" = "true" ]; then
  ARGS+=(--verbose)
fi

bashio::log.info "Starting Dahua Easy4ip P2P tunnel on TCP port 8554."
exec dahua-p2p "${ARGS[@]}"
