FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ninja-build \
    git \
    cmake \
    python3 \
    python3-pip \
    python3-venv \
    dfu-util \
    gcc \
    g++ \
    libusb-1.0-0-dev \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install west and yq
RUN pipx install west
RUN pipx install yq
