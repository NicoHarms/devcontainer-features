#!/usr/bin/env bash
# Docker-in-Docker Installation Script
# This script detects the OS and runs the appropriate installation script
#
# Supported OS:
# - Alpine Linux
# - Debian/Ubuntu
#
# Docs:
# Maintainer: The Dev Container spec maintainers

export DOCKER_VERSION="${VERSION:-"latest"}" # The Docker/Moby Engine + CLI should match in version
export USE_MOBY="${MOBY:-"true"}"
export MOBY_BUILDX_VERSION="${MOBYBUILDXVERSION:-"latest"}" # TODO: unused in alpine
export DOCKER_DASH_COMPOSE_VERSION="${DOCKERDASHCOMPOSEVERSION:-"v2"}" #v1, v2 or none # TODO: unused in alpine
export AZURE_DNS_AUTO_DETECTION="${AZUREDNSAUTODETECTION:-"true"}"
export DOCKER_DEFAULT_ADDRESS_POOL="${DOCKERDEFAULTADDRESSPOOL:-""}"
export USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
export INSTALL_DOCKER_BUILDX="${INSTALLDOCKERBUILDX:-"true"}"
export INSTALL_DOCKER_COMPOSE_SWITCH="${INSTALLDOCKERCOMPOSESWITCH:-"true"}"
export MICROSOFT_GPG_KEYS_URI="https://packages.microsoft.com/keys/microsoft.asc" # TODO: unused in alpine
export MICROSOFT_GPG_KEYS_ROLLING_URI="https://packages.microsoft.com/keys/microsoft-rolling.asc" # TODO: unused in alpine
export DOCKER_MOBY_ARCHIVE_VERSION_CODENAMES="trixie bookworm buster bullseye bionic focal jammy noble" # TODO: unused in alpine
export DOCKER_LICENSED_ARCHIVE_VERSION_CODENAMES="trixie bookworm buster bullseye bionic focal hirsute impish jammy noble" # TODO: unused in alpine
export DISABLE_IP6_TABLES="${DISABLEIP6TABLES:-false}"

set -e

# Setup STDERR.
err() {
    echo "(!) $*" >&2
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            alpine)
                echo "alpine"
                ;;
            debian|ubuntu)
                echo "debian"
                ;;
            *)
                err "Unsupported OS: $ID"
                err "Supported OS: Alpine Linux, Debian, Ubuntu"
                exit 1
                ;;
        esac
    else
        err "Cannot detect OS: /etc/os-release not found"
        exit 1
    fi
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect OS and run appropriate install script
OS=$(detect_os)
echo "Detected OS: $OS"

case "$OS" in
    alpine)
        INSTALL_SCRIPT="$SCRIPT_DIR/install-alpine.sh"
        ;;
    debian)
        INSTALL_SCRIPT="$SCRIPT_DIR/install-debian.sh"
        ;;
    *)
        err "Unsupported OS detected: $OS"
        exit 1
        ;;
esac

# Check if the install script exists
if [ ! -f "$INSTALL_SCRIPT" ]; then
    err "Installation script not found: $INSTALL_SCRIPT"
    exit 1
fi

echo "Running $INSTALL_SCRIPT..."

# Run the appropriate install script with all passed arguments
exec "$INSTALL_SCRIPT" "$@"
