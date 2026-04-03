# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-alpine:edge

# set version label
ARG BUILD_DATE
ARG VERSION
ARG QBITTORRENT_EE_VERSION
ARG QBT_CLI_VERSION
ARG VUETORRENT_VERSION
LABEL build_version="qBittorrent-Enhanced-Edition Docker version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="custom"

# environment settings
ENV HOME="/config" \
    XDG_CONFIG_HOME="/config" \
    XDG_DATA_HOME="/config"

# install runtime packages and qBittorrent Enhanced Edition
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    grep \
    icu-libs \
    p7zip \
    python3 \
    qt6-qtbase-sqlite \
    curl \
    jq \
    unzip && \
  echo "**** install qBittorrent Enhanced Edition ****" && \
  if [ -z ${QBITTORRENT_EE_VERSION+x} ]; then \
    QBITTORRENT_EE_VERSION=$(curl -sL "https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases/latest" \
    | jq -r '.tag_name'); \
  fi && \
  ARCH=$(uname -m) && \
  case "${ARCH}" in \
    x86_64)  ARCH_SUFFIX="x86_64-linux-musl" ;; \
    aarch64) ARCH_SUFFIX="aarch64-linux-musl" ;; \
    armv7l)  ARCH_SUFFIX="arm-linux-musleabihf" ;; \
    armv6l)  ARCH_SUFFIX="arm-linux-musleabi" ;; \
    i686)    ARCH_SUFFIX="i686-linux-musl" ;; \
    *)       echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
  esac && \
  echo "Downloading qBittorrent-Enhanced-Edition ${QBITTORRENT_EE_VERSION} for ${ARCH_SUFFIX}" && \
  curl -o /tmp/qbittorrent-ee.zip -L \
    "https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/${QBITTORRENT_EE_VERSION}/qbittorrent-enhanced-nox_${ARCH_SUFFIX}_static.zip" && \
  unzip /tmp/qbittorrent-ee.zip -d /tmp/qbittorrent-ee && \
  cp /tmp/qbittorrent-ee/qbittorrent-nox /usr/bin/qbittorrent-nox && \
  chmod +x /usr/bin/qbittorrent-nox && \
  echo "**** install qbittorrent-cli ****" && \
  mkdir /qbt && \
  if [ -z ${QBT_CLI_VERSION+x} ]; then \
    QBT_CLI_VERSION=$(curl -sL "https://api.github.com/repos/fedarovich/qbittorrent-cli/releases/latest" \
    | jq -r '.tag_name'); \
  fi && \
  QBT_CLI_ARCH="x64" && \
  if [ "${ARCH}" = "aarch64" ]; then QBT_CLI_ARCH="arm64"; fi && \
  curl -o /tmp/qbt.tar.gz -L \
    "https://github.com/fedarovich/qbittorrent-cli/releases/download/${QBT_CLI_VERSION}/qbt-linux-alpine-${QBT_CLI_ARCH}-net6-${QBT_CLI_VERSION#v}.tar.gz" && \
  tar xf /tmp/qbt.tar.gz -C /qbt && \
  echo "**** install VueTorrent WebUI ****" && \
  if [ -z ${VUETORRENT_VERSION+x} ]; then \
    VUETORRENT_VERSION=$(curl -sL "https://api.github.com/repos/VueTorrent/VueTorrent/releases/latest" \
    | jq -r '.tag_name'); \
  fi && \
  curl -o /tmp/vuetorrent.zip -L \
    "https://github.com/VueTorrent/VueTorrent/releases/download/${VUETORRENT_VERSION}/vuetorrent.zip" && \
  mkdir -p /vuetorrent && \
  unzip /tmp/vuetorrent.zip -d /vuetorrent && \
  printf "qBittorrent-Enhanced-Edition version: ${QBITTORRENT_EE_VERSION}\nVueTorrent version: ${VUETORRENT_VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /root/.cache \
    /tmp/*

# add local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8080 6881 6881/udp

VOLUME /config
