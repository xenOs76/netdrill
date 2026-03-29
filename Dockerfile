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

# Main stage
FROM alpine:latest

RUN set -ex \
    && apk update \
    && apk upgrade \
    && apk add --no-cache \
        apache2-utils \
        bash \
        bind-tools \
        busybox-extras \
        curl \
        drill \
        ethtool \
        file \
        fping \
        httpie \
        iftop \
        iperf3 \
        iproute2 \
        iputils \
        ipvsadm \
        jq \
        nmap \
        nmap-scripts \
        nmap-nping \
        openssl \
        socat \
        strace \
        tcpdump \
        tcptraceroute \
        util-linux \
        neovim \
        wget \
        bash-completion \
        eza \
        fzf \
        zoxide \
        zoxide-bash-completion \
        zellij \
        zellij-bash-completion \
        starship

# Install https-wrench from fetcher
COPY --from=fetcher /tmp/https-wrench /usr/local/bin/https-wrench

WORKDIR /root

# Customize bash with local settings
COPY ./config/starship.toml /etc/starship.toml
ENV STARSHIP_CONFIG=/etc/starship.toml 

RUN mkdir /etc/zellij
COPY ./config/zellij/config.kdl /etc/zellij/config.kdl
ENV ZELLIJ_CONFIG_DIR=/etc/zellij

COPY ./config/bashrc_local /etc/bashrc_local
RUN echo 'source /etc/bashrc_local' >> /root/.bashrc

CMD ["/bin/bash"]
