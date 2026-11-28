ARG ALPINE_VERSION=3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

# Fetcher stage
FROM alpine:${ALPINE_VERSION} AS fetcher

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

# Builder stage
FROM alpine:${ALPINE_VERSION} AS builder

RUN set -ex \
  && apk update \
  && apk upgrade \
  && apk add --no-cache \
  !fzf-bash-plugin \
  bash \
  bash-completion \
  bind-tools \
  curl \
  direnv \
  doggo \
  eza \
  fzf \
  iperf3 \
  iputils \
  jq \
  openssl \
  starship \
  wget \
  zellij-bash-completion \
  zoxide \
  zoxide-bash-completion \
  && rm -rf \
  /usr/share/doc \
  /usr/share/man \
  /usr/share/info \
  /var/cache/apk/*

# Install https-wrench from fetcher
COPY --from=fetcher /tmp/https-wrench /usr/local/bin/https-wrench
RUN /usr/local/bin/https-wrench --version

# Install aws-probe from fetcher
COPY --from=fetcher /tmp/aws-probe /usr/local/bin/aws-probe
RUN /usr/local/bin/aws-probe -v

# Customize bash with local settings
COPY ./config/dotDirenvTemplate /etc/dotDirenvTemplate
COPY ./config/starship.toml /etc/starship.toml

RUN mkdir /root/direnv-templates
COPY ./config/direnv-templates /root/direnv-templates

RUN mkdir /etc/zellij
COPY ./config/zellij/config.kdl /etc/zellij/config.kdl

COPY ./config/bashrc_local /etc/bashrc_local
RUN echo 'source /etc/bashrc_local' >> /root/.bashrc

# Final squashed stage (eliminates duplicate overwritten files across layers)
FROM scratch

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

COPY --from=builder / /

WORKDIR /root

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV STARSHIP_CONFIG=/etc/starship.toml
ENV ZELLIJ_CONFIG_DIR=/etc/zellij

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD exit 0

CMD ["/bin/bash"]
