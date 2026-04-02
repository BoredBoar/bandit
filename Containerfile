FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="bandit" \
      org.opencontainers.image.description="Cross-platform environment for OverTheWire Bandit wargame" \
      org.opencontainers.image.source="https://github.com/clwilli/bandit"

# Install tools in a single layer to keep image size small.
# Package selection mirrors what the Bandit levels require.
RUN apt-get update && apt-get install -y --no-install-recommends \
    # SSH and remote access
    openssh-client \
    sshpass \
    # Network tools
    netcat-openbsd \
    ncat \
    curl \
    wget \
    # Development / analysis tools
    git \
    python3 \
    xxd \
    binutils \
    file \
    bsdmainutils \
    openssl \
    # Compression
    gzip \
    bzip2 \
    xz-utils \
    zstd \
    tar \
    zip \
    unzip \
    # Terminal multiplexers
    tmux \
    screen \
    # Editors
    vim \
    nano \
    # Utilities
    jq \
    less \
    man-db \
    locales \
    ca-certificates \
 && locale-gen en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Create a non-root user so we don't run as root inside the container.
# UID 1000 aligns with the default user on most Linux desktops.
RUN useradd --uid 1000 --create-home --shell /bin/bash player

# Mount point for the host-side credential/progress data
RUN mkdir -p /home/player/.bandit && chown player:player /home/player/.bandit

USER player
WORKDIR /home/player

# Default: drop to an interactive shell
CMD ["/bin/bash"]
