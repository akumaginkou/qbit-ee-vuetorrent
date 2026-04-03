# qbit-ee-vuetorrent

Docker image combining [qBittorrent Enhanced Edition](https://github.com/c0re100/qBittorrent-Enhanced-Edition) with [VueTorrent](https://github.com/VueTorrent/VueTorrent) WebUI, based on [linuxserver/docker-qbittorrent](https://github.com/linuxserver/docker-qbittorrent).

## Features

- **qBittorrent Enhanced Edition** — auto-ban xunlei, shadow, and other leeching clients
- **VueTorrent** — modern, responsive WebUI
- **linuxserver base image** — s6-overlay, PUID/PGID support, automatic config initialization
- **Multi-architecture** — x86_64, aarch64, armv7l, armv6l, i686

## Quick Start

```bash
git clone git@github.com:akumaginkou/qbit-ee-vuetorrent.git
cd qbit-ee-vuetorrent
docker compose up -d --build
```

WebUI is available at **http://localhost:8080**

The initial admin password is printed in the container logs:

```bash
docker logs qbit-ee-vuetorrent
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `Asia/Tokyo` | Timezone |
| `WEBUI_PORT` | `8080` | WebUI port |
| `TORRENTING_PORT` | — | Override BitTorrent listening port |

### Volumes

| Path | Description |
|---|---|
| `/config` | qBittorrent configuration and data |
| `/downloads` | Default download directory |

### Build Arguments

Pin specific versions at build time:

```bash
docker compose build \
  --build-arg QBITTORRENT_EE_VERSION=release-5.1.3.10 \
  --build-arg VUETORRENT_VERSION=v2.32.1
```

## Ports

| Port | Protocol | Description |
|---|---|---|
| `8080` | TCP | WebUI |
| `6881` | TCP/UDP | BitTorrent |

## Updating

```bash
docker compose down
docker compose up -d --build
```

## Credits

- [c0re100/qBittorrent-Enhanced-Edition](https://github.com/c0re100/qBittorrent-Enhanced-Edition)
- [VueTorrent/VueTorrent](https://github.com/VueTorrent/VueTorrent)
- [linuxserver/docker-qbittorrent](https://github.com/linuxserver/docker-qbittorrent)
