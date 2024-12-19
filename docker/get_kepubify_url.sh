#!/bin/sh
set -e

KEPUBIFY_RELEASE="${1}"

# Get OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)
case "$OS" in
    Linux)
        case "$ARCH" in
            x86_64) BINARY="kepubify-linux-64bit" ;;
            i686 | i386) BINARY="kepubify-linux-32bit" ;;
            armv7l | armv6l) BINARY="kepubify-linux-arm" ;;
            aarch64) BINARY="kepubify-linux-arm64" ;;
            *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
        esac
        ;;
    Darwin)
        case "$ARCH" in
            x86_64) BINARY="kepubify-darwin-64bit" ;;
            arm64) BINARY="kepubify-darwin-arm64" ;;
            *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
        esac
        ;;
    Windows_NT)
        case "$ARCH" in
            x86_64) BINARY="kepubify-windows-64bit.exe" ;;
            i686 | i386) BINARY="kepubify-windows-32bit.exe" ;;
            arm64) BINARY="kepubify-windows-arm64.exe" ;;
            *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
        esac
        ;;
    *)
        echo "Unsupported OS: $OS" >&2
        exit 1
        ;;
esac
if [ "${KEPUBIFY_RELEASE}x" = "x" ]; then
    KEPUBIFY_RELEASE=$(curl -f -sX GET "https://api.github.com/repos/pgaskin/kepubify/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]');
fi

echo "https://github.com/pgaskin/kepubify/releases/download/${KEPUBIFY_RELEASE}/${BINARY}"
