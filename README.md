# Dahua DMSS P2P bridge for Home Assistant OS

A Home Assistant OS add-on that forwards a Dahua camera's RTSP port through the Dahua DMSS cloud tunnel. It is intended for a camera at another internet connection, without inbound port forwarding, a VPN, or a phone relay.

## Target device

Initial target: Dahua DH-IPC-HDW2441TM-S.

The add-on wraps [undervolter/dh-fwd](https://github.com/undervolter/dh-fwd), pinned to upstream v2.4.1. It includes the DMSS cloud profile, DMSS request dialect, Type-1 authentication and modern app-relay handshake. The add-on also applies a narrow compatibility patch for firmware that does not expose a device Info/RandSalt blob: it tries Type-1 authentication using the documented empty salt realm and omits the RandSalt XML element. The authenticated channel handshake remains mandatory; this does not bypass camera authentication.

This is unofficial, reverse-engineered interoperability software. The exact target camera handshake still requires live verification; a successful build or installation does not prove that the remote camera accepts the connection.

## Install

1. In the parents' Home Assistant, open **Settings → Apps → App store → ⋮ → Repositories**.
2. Add: https://github.com/ayrtonherman/dahua-p2p-home-assistant
3. Refresh the repository and install/update **Dahua P2P Bridge** to **0.3.4**.
4. Keep the existing settings:
   - **Serial:** camera serial number
   - **Username:** local camera username (not the DMSS account email)
   - **Password:** local camera password
   - **Verbose:** on

The old **Force relay** option is retained only for compatibility. DMSS app-relay is selected automatically.

The bridge listens on TCP port 8554 and forwards it to the camera's RTSP port 554.

## Add the camera to Home Assistant

Use the Generic Camera integration (or another RTSP-capable camera integration) with this stream source:

```text
rtsp://CAMERA_USERNAME:CAMERA_PASSWORD@HOME_ASSISTANT_IP:8554/cam/realmonitor?channel=1&subtype=1
```

Replace the placeholders locally. Do not publish the serial number, camera credentials, or complete RTSP URL. The example uses the substream (`subtype=1`); use `subtype=0` for the main stream.

## Security and limitations

- Keep TCP port 8554 on the trusted Home Assistant network. Do not forward it to the public internet.
- The camera's local username/password are used for authenticated P2P channel setup and RTSP.
- The empty-RandSalt path is only an alternate documented Type-1 authentication format. If the camera requires a non-empty salt, the camera should reject the channel request and no tunnel will open.
- Anyone who can reach the forwarded RTSP port may attempt camera authentication; use a strong camera password and firewall the port.
- The camera may allow only one active P2P session. While the bridge is connected, DMSS or another P2P client may temporarily be unable to use the same session.
- This add-on supports one camera per installation.
- Confirm the log reaches a listening/connected state before adding the Generic Camera integration.

## Upstream

- https://github.com/undervolter/dh-fwd/tree/v2.4.1
- https://github.com/khoanguyen-3fc/dh-p2p
- MIT license; see the upstream repository for license and attribution.
