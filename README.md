# Dahua DMSS P2P bridge for Home Assistant OS

A Home Assistant OS add-on that forwards a Dahua camera's RTSP port through the Dahua DMSS P2P cloud protocol. It is intended for a camera at another internet connection, without inbound port forwarding, a VPN, or a phone relay.

## Target device

Initial target: Dahua DH-IPC-HDW2441TM-S.

The add-on wraps the community project [undervolter/dh-fwd](https://github.com/undervolter/dh-fwd), pinned to a reviewed commit, with a small compatibility patch for Dahua firmware that returns HTTP 404 / no Info blob from `/info/device/<SN>`. The documented legacy no-salt Type-1 path derives the channel key using an empty salt and omits the `<RandSalt>` XML element. The add-on now uses the DMSS profile and Type-1 channel authentication with the camera's local username and password.

This is unofficial, reverse-engineered interoperability software. The patch is based on the documented no-salt protocol behavior; the exact target camera handshake still requires live verification.

## Install

1. In the parents' Home Assistant, open **Settings → Apps → App store → ⋮ → Repositories**.
2. Add: https://github.com/ayrtonherman/dahua-p2p-home-assistant
3. Refresh the repository and install/update **Dahua P2P Bridge** to **0.3.2**.
4. Configure:
   - **Serial:** camera serial number
   - **Username:** local camera username (not the DMSS account email)
   - **Password:** local camera password
   - **Force relay:** off for the first test
   - **Verbose:** on
5. Start the add-on and inspect its log.

The bridge listens on TCP port 8554 and forwards it to the camera's RTSP port 554.

## Add the camera to Home Assistant

Use the Generic Camera integration (or another RTSP-capable camera integration) with this stream source:

```text
rtsp://CAMERA_USERNAME:CAMERA_PASSWORD@HOME_ASSISTANT_IP:8554/cam/realmonitor?channel=1&subtype=1
```

Replace the placeholders locally. Do not publish the serial number, camera credentials, or complete RTSP URL. The example uses the substream (`subtype=1`); use `subtype=0` for the main stream.

## Force relay

If the normal DMSS P2P connection cannot establish its direct UDP path, enable **Force relay** in the add-on options and restart it. Relay availability is controlled by Dahua's cloud service and camera firmware.

## Security and limitations

- Keep TCP port 8554 on the trusted Home Assistant network. Do not forward it to the public internet.
- The camera's local username/password are used for both authenticated P2P channel setup and RTSP.
- Anyone who can reach the forwarded RTSP port may be able to attempt camera authentication; use a strong camera password and firewall the port.
- The camera may allow only one active P2P relay session. While the bridge is connected, DMSS or another P2P client may temporarily be unable to use the same session.
- This add-on supports one camera per installation.
- No live end-to-end test has yet confirmed compatibility with every firmware revision.

## Upstream

- https://github.com/undervolter/dh-fwd
- MIT license; see the upstream repository for license and attribution.
