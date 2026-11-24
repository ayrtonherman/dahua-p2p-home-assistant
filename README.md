# Dahua DMSS P2P bridge for Home Assistant OS

A Home Assistant OS add-on that forwards a Dahua camera's RTSP port through the Dahua DMSS P2P cloud protocol. It is intended for a camera at another internet connection, without inbound port forwarding, a VPN, or a phone relay.

## Target device

Initial target: Dahua DH-IPC-HDW2441TM-S.

The add-on wraps the community project [undervolter/dh-fwd](https://github.com/undervolter/dh-fwd), pinned to a reviewed commit. This is an unofficial, reverse-engineered protocol implementation. Compatibility depends on the camera firmware and the cloud connection mode.

## Install

1. In Home Assistant, open **Settings → Apps → App store → ⋮ → Repositories**.
2. Add: https://github.com/ayrtonherman/dahua-p2p-home-assistant
3. Install **Dahua P2P Bridge**.
4. Enter the camera serial number in the add-on configuration.
5. Leave **Force relay** disabled initially. Start the add-on and check its log.

The bridge listens on TCP port 8554 and forwards it to the camera's RTSP port 554.

## Add the camera to Home Assistant

Use the Generic Camera integration (or another RTSP-capable camera integration) with this stream source:

```text
rtsp://CAMERA_USERNAME:CAMERA_PASSWORD@HOME_ASSISTANT_IP:8554/cam/realmonitor?channel=1&subtype=1
```

Replace the placeholders locally. Do not publish the serial number, camera credentials, or complete RTSP URL. The example uses the substream (`subtype=1`); use `subtype=0` for the main stream.

**Important:** the camera username and password belong in the Home Assistant RTSP stream configuration. The DMSS P2P channel handshake used by this bridge does not use those credentials. The previous Type-1 channel-auth setting required a RandSalt Info blob that was absent in the camera's diagnostic response, so this add-on now uses the DMSS profile's Type-0 channel mode.

## Force relay

If the normal P2P connection cannot establish its direct UDP path, enable **Force relay** in the add-on options and restart it. Relay availability is controlled by Dahua's cloud service and camera firmware.

## Security and limitations

- Keep TCP port 8554 on the trusted Home Assistant network. Do not forward it to the public internet.
- Anyone who can reach the forwarded RTSP port may be able to attempt camera authentication; use a strong camera password and firewall the port.
- The camera may allow only one active P2P relay session. While the bridge is connected, DMSS or another P2P client may temporarily be unable to use the same session.
- This add-on supports one camera per installation.
- This is not an official Dahua or Home Assistant integration and is not guaranteed to work with every firmware or DMSS account configuration.

## Upstream

- https://github.com/undervolter/dh-fwd
- MIT license; see the upstream repository for license and attribution.
