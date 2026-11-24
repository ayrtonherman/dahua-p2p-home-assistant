# Dahua P2P bridge for Home Assistant OS

A Home Assistant OS add-on wrapper around the community project [ludufre/dahua-p2p](https://github.com/ludufre/dahua-p2p). It attempts to expose a Dahua camera's RTSP service through the Easy4ip cloud relay, so Home Assistant can consume the stream without inbound port forwarding or a site-to-site VPN.

## Status

**Experimental; not yet tested with this camera or this Home Assistant installation.** The upstream project is an unofficial reverse-engineered implementation intended for personal and research use. Compatibility with every Dahua model and firmware is not guaranteed.

The first target is one camera: Dahua DH-IPC-HDW2441TM-S. Do not publish the camera serial number, username, password, or stream URL in this repository.

## Installation

1. In Home Assistant, open **Settings → Apps → App store → ⋮ → Repositories**.
2. Add this repository URL: https://github.com/ayrtonherman/dahua-p2p-home-assistant
3. Install **Dahua P2P Bridge**.
4. In the add-on configuration, enter the camera's P2P serial number. Do not put credentials in GitHub.
5. Start the add-on and inspect its log.

The add-on listens on TCP port 8554 and forwards that connection through the Dahua P2P tunnel to the camera's RTSP port 554.

## Home Assistant camera stream

Once the bridge is running, a local RTSP client on the Home Assistant network can connect to:

```text
rtsp://CAMERA_USERNAME:CAMERA_PASSWORD@HOME_ASSISTANT_IP:8554/cam/realmonitor?channel=1&subtype=1
```

Use the camera's own local device credentials in the RTSP URL. Keep that URL private. The example uses the substream (subtype 1); subtype 0 is usually the main stream.

## Important limitations

- This is an experimental wrapper, not an official Dahua or Home Assistant integration.
- The upstream P2P project documents one relay session per camera at a time. While the bridge holds the tunnel, DMSS or another P2P client may be unable to use that camera's relay session.
- The upstream project documents relay authentication and firmware-related limitations. Some devices may reject the P2P channel.
- The add-on currently supports one camera instance per add-on installation.
- Only amd64 and aarch64 builds are configured at present.
- Do not expose TCP port 8554 to the public internet. Keep it on the trusted home network.

## Upstream

- https://github.com/ludufre/dahua-p2p
- Upstream CLI: `dahua-p2p tunnel <SERIAL> --listen 8554 --remote 554 --host 0.0.0.0`

## License and attribution

This wrapper is separate from the upstream project. The upstream `dahua-p2p` package is MIT-licensed; see its repository for its license and notices. The upstream maintainer describes their project as personal/research use and not affiliated with Dahua or Intelbras.
