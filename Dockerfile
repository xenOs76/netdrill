# Fetcher stage
FROM alpine:latest AS fetcher

RUN apk add --no-cache curl tar

# Fetch https-wrench
RUN set -ex \
  && ARCH=$(uname -m) \
  && case "$ARCH" in \
  x86_64) BIN_ARCH="Linux_x86_64" ;; \
  aarch64) BIN_ARCH="Linux_arm64" ;; \
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
  esac \
  && curl -sSL https://api.github.com/repos/xenOs76/https-wrench/releases/latest \
  | grep "browser_download_url.*${BIN_ARCH}\.tar\.gz" \
  | cut -d '"' -f 4 \
  | xargs curl -L -o https-wrench.tar.gz \
  && tar -xzf https-wrench.tar.gz \
  && mv https-wrench /tmp/https-wrench \
  && chmod +x /tmp/https-wrench

# Fetch aws-probe
RUN set -ex \
  && ARCH=$(uname -m) \
  && case "$ARCH" in \
  x86_64) BIN_ARCH="Linux_amd64" ;; \
  aarch64) BIN_ARCH="Linux_arm64" ;; \
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
  esac \
  && curl -sSL https://api.github.com/repos/xenOs76/aws-probe/releases/latest \
  | grep "browser_download_url.*${BIN_ARCH}\.tar\.gz" \
  | cut -d '"' -f 4 \
  | xargs curl -L -o aws-probe.tar.gz \
  && tar -xzf aws-probe.tar.gz \
  && mv aws-probe /tmp/aws-probe \
  && chmod +x /tmp/aws-probe

# Main stage
FROM alpine:latest

ARG LABEL_CREATED
ARG LABEL_DESCRIPTION
ARG LABEL_REVISION
ARG LABEL_SOURCE

LABEL org.opencontainers.image.authors="xeno@os76.xyz"
LABEL org.opencontainers.image.created=$LABEL_CREATED
LABEL org.opencontainers.image.description="NetDrill is a Docker image designed for network troubleshooting within Kubernetes clusters"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.revision=$LABEL_REVISION
LABEL org.opencontainers.image.source=$LABEL_SOURCE
LABEL org.opencontainers.image.title="NetDrill"

RUN set -ex \
  && apk update \
  && apk upgrade \
  && apk add --no-cache \
  bash \
  bash-completion \
  doggo \
  curl \
  eza \
  direnv \
  iperf3 \
  iputils \
  jq \
  neovim \
  nmap \
  openssl \
  starship \
  tcpdump \
  tcptraceroute \
  wget \
  zellij-bash-completion \
  zoxide \
  zoxide-bash-completion

# Install https-wrench from fetcher
COPY --from=fetcher /tmp/https-wrench /usr/local/bin/https-wrench

# Install aws-probe from fetcher
COPY --from=fetcher /tmp/aws-probe /usr/local/bin/aws-probe

WORKDIR /root

# Customize bash with local settings
COPY ./config/dotDirenvTempleate /etc/dotDirenvTemplate

COPY ./config/starship.toml /etc/starship.toml
ENV STARSHIP_CONFIG=/etc/starship.toml 

RUN mkdir /root/direnv-templates
COPY ./config/direnv-templates /root/direnv-templates

RUN mkdir /etc/zellij
COPY ./config/zellij/config.kdl /etc/zellij/config.kdl
ENV ZELLIJ_CONFIG_DIR=/etc/zellij

COPY ./config/bashrc_local /etc/bashrc_local
RUN echo 'source /etc/bashrc_local' >> /root/.bashrc

CMD ["/bin/bash"]
