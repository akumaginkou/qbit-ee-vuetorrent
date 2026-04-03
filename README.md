# qbit-ee-vuetorrent

[![Build and Publish](https://github.com/akumaginkou/qbit-ee-vuetorrent/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/akumaginkou/qbit-ee-vuetorrent/actions/workflows/docker-publish.yml)
[![Auto Update](https://github.com/akumaginkou/qbit-ee-vuetorrent/actions/workflows/auto-update.yml/badge.svg)](https://github.com/akumaginkou/qbit-ee-vuetorrent/actions/workflows/auto-update.yml)
[![Test](https://github.com/akumaginkou/qbit-ee-vuetorrent/actions/workflows/test.yml/badge.svg)](https://github.com/akumaginkou/qbit-ee-vuetorrent/actions/workflows/test.yml)

Docker image combining [qBittorrent Enhanced Edition](https://github.com/c0re100/qBittorrent-Enhanced-Edition) with [VueTorrent](https://github.com/VueTorrent/VueTorrent) WebUI, based on [linuxserver/docker-qbittorrent](https://github.com/linuxserver/docker-qbittorrent).

## Features

- **qBittorrent Enhanced Edition** - auto-ban xunlei, shadow, and other leeching clients
- **VueTorrent** - modern, responsive alternative WebUI
- **linuxserver base image** - s6-overlay process supervision, PUID/PGID support, automatic config initialization
- **Multi-architecture** - linux/amd64, linux/arm64
- **Auto-update** - GitHub Actions checks upstream daily and publishes new images automatically
- **Tested** - every build runs integration tests (build, startup, WebUI, API) before publishing

## Quick Start

### Using the pre-built image (recommended)

```yaml
# docker-compose.yml
services:
  qbittorrent:
    image: ghcr.io/akumaginkou/qbit-ee-vuetorrent:latest
    container_name: qbit-ee-vuetorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Tokyo
      - WEBUI_PORT=8080
      - TORRENTING_PORT=6881
    volumes:
      - ./config:/config
      - ./downloads:/downloads
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
```

```bash
docker compose up -d
```

### Using docker run

```bash
docker run -d \
  --name qbit-ee-vuetorrent \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Tokyo \
  -e WEBUI_PORT=8080 \
  -p 8080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v ./config:/config \
  -v ./downloads:/downloads \
  --restart unless-stopped \
  ghcr.io/akumaginkou/qbit-ee-vuetorrent:latest
```

### Building from source

```bash
git clone https://github.com/akumaginkou/qbit-ee-vuetorrent.git
cd qbit-ee-vuetorrent
docker compose up -d --build
```

### Initial Login

WebUI is available at **http://localhost:8080**

The initial admin password is printed in the container logs:

```bash
docker logs qbit-ee-vuetorrent
```

Look for:

```
The WebUI administrator password was not set. A temporary password is provided for this session: xxxxxxxx
```

Login with username `admin` and the temporary password shown, then change it in Settings > WebUI.

## Configuration

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `PUID` | `911` | User ID for file permissions. Set to match your host user (`id -u`) |
| `PGID` | `911` | Group ID for file permissions. Set to match your host group (`id -g`) |
| `TZ` | `Etc/UTC` | Container timezone ([list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)) |
| `WEBUI_PORT` | `8080` | Port the WebUI listens on inside the container |
| `TORRENTING_PORT` | *(not set)* | Override the BitTorrent listening port. If not set, uses the value from qBittorrent config |
| `UMASK` | `022` | Umask for newly created files |
| `LSIO_NON_ROOT_USER` | *(not set)* | Set to any value to run qBittorrent as the container's default user instead of `abc` (no `s6-setuidgid`) |

> **Note:** `PUID`/`PGID`/`UMASK`/`LSIO_NON_ROOT_USER` are provided by the [linuxserver base image](https://docs.linuxserver.io/general/understanding-puid-and-pgid/).

### Volumes

| Container Path | Description |
|---|---|
| `/config` | qBittorrent configuration, database, logs, and session data. Persists all settings across container restarts |
| `/downloads` | Default download directory. Can be changed in qBittorrent settings |

You can mount additional directories for completed/incomplete downloads or watch folders:

```yaml
volumes:
  - ./config:/config
  - /mnt/storage/downloads:/downloads
  - /mnt/storage/incomplete:/downloads/incomplete
  - /mnt/storage/watch:/watch
```

### Ports

| Port | Protocol | Description |
|---|---|---|
| `8080` | TCP | WebUI and WebAPI. Change with `WEBUI_PORT` env var |
| `6881` | TCP + UDP | BitTorrent incoming connections. Change with `TORRENTING_PORT` env var or in qBittorrent settings |

> **Tip:** For best performance, forward the BitTorrent port on your router and set it to match in qBittorrent settings. If using a VPN container, the VPN's forwarded port should be used instead.

### Build Arguments

Pin specific component versions at build time:

```bash
docker compose build \
  --build-arg QBITTORRENT_EE_VERSION=release-5.1.3.10 \
  --build-arg VUETORRENT_VERSION=v2.32.1 \
  --build-arg QBT_CLI_VERSION=v2.0.0
```

| Argument | Default | Description |
|---|---|---|
| `QBITTORRENT_EE_VERSION` | *(latest)* | qBittorrent Enhanced Edition release tag (e.g. `release-5.1.3.10`). See [releases](https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases) |
| `VUETORRENT_VERSION` | *(latest)* | VueTorrent release tag (e.g. `v2.32.1`). See [releases](https://github.com/VueTorrent/VueTorrent/releases) |
| `QBT_CLI_VERSION` | *(latest)* | qBittorrent CLI release tag (e.g. `v2.0.0`). See [releases](https://github.com/fedarovich/qbittorrent-cli/releases) |
| `BUILD_DATE` | *(not set)* | Build timestamp for image labels |

### Image Tags

| Tag | Description |
|---|---|
| `latest` | Most recent build with the latest upstream versions |
| `ee-release-X.Y.Z.N` | Pinned to a specific qBittorrent Enhanced Edition version |
| `vX.Y.Z` | Manually tagged release |

```bash
# Always latest
docker pull ghcr.io/akumaginkou/qbit-ee-vuetorrent:latest

# Pin to specific EE version
docker pull ghcr.io/akumaginkou/qbit-ee-vuetorrent:ee-release-5.1.3.10
```

### VueTorrent WebUI

VueTorrent is pre-installed at `/vuetorrent/vuetorrent` and enabled by default. The default config sets:

```ini
WebUI\AlternativeUIEnabled=true
WebUI\RootFolder=/vuetorrent/vuetorrent
```

To switch back to the default qBittorrent WebUI, edit `config/qBittorrent/qBittorrent.conf`:

```ini
WebUI\AlternativeUIEnabled=false
```

Or change it in VueTorrent Settings > WebUI > "Use Alternative WebUI".

## Automation

### Auto-Update

The [auto-update workflow](.github/workflows/auto-update.yml) runs daily and:

1. Checks for new releases of qBittorrent Enhanced Edition and VueTorrent
2. Skips if the current versions are already published
3. Builds and runs the full test suite
4. Pushes the new image to `ghcr.io`
5. Creates a GitHub Release with version details

### Tests

Every build (PR, tag push, auto-update) runs [integration tests](.github/workflows/test.yml):

- Docker image builds successfully
- `qbittorrent-nox --version` returns expected output
- VueTorrent files are present in the image
- `unrar` binary is functional
- Container starts and WebUI responds with HTTP 200
- VueTorrent content is served
- qBittorrent WebAPI responds (authenticated login, version, preferences)

## Updating

### Pre-built image

```bash
docker compose pull
docker compose up -d
```

### From source

```bash
git pull
docker compose up -d --build
```

## Troubleshooting

### Check container logs

```bash
docker logs qbit-ee-vuetorrent
```

### Check installed versions

```bash
docker exec qbit-ee-vuetorrent cat /build_version
```

### Permission issues

If you see permission errors on `/config` or `/downloads`, ensure `PUID` and `PGID` match your host user:

```bash
id  # Shows your UID and GID
```

### WebUI not accessible

- Verify the port mapping matches `WEBUI_PORT`
- Check firewall rules on the host
- Verify the container is running: `docker ps`

## Credits

- [c0re100/qBittorrent-Enhanced-Edition](https://github.com/c0re100/qBittorrent-Enhanced-Edition)
- [VueTorrent/VueTorrent](https://github.com/VueTorrent/VueTorrent)
- [linuxserver/docker-qbittorrent](https://github.com/linuxserver/docker-qbittorrent)
- [fedarovich/qbittorrent-cli](https://github.com/fedarovich/qbittorrent-cli)
