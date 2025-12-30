#!/bin/sh

SUPPORT_USER="introserv"
KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw1Gcf0jUEXcCkyfG6Us8yjqcUGuE1GOL5+9N0cpE01VwbCxRG/55w8yUQoiEfzQmeD8DSmlrgrRP8Tm2GVgn7CFD1wLhbakL3+dgPcgyaT7I8cy/4+UQxPN1aysHP0rbSN1GgqNcv/CN8og/6GqJ3Y9Jw061wIP3mxM9P3pyOUZd4f6EWCPV77dYLwpabDQEeE88owjYSRMxRWU8yjVk3PVZr+JcwXtyBpf/2E/RSn2JJQgG0YiMUeZwNoklQMfDVnoev+NHlK7vfXKVro4QqAA0B5T1Noox8olLRLjbqMZAn0QtxF4NJ7Q9fgiIIbiUyTqhqsEDLTBdOvzE+gWOptmxW0Nu+SB35K88FZyeRUwGXcw3874I2RZwgedHJDQ49Lx7FxU5Z27SAzfqaTCV2RvIesCAAGRl2VMa2TAldGbIQqZ5U+VkqS+P/uKsJOqL+JX/et1/HjyiLY4BmwLUH/q7aGCVE4Tdk/24E2DkZnG+C3QfBFLNxrUaHAiIiKbwpYPxAXASPCRy5Y60KhJfLd++qqzJfqEfsDlWiQHecDOtGkqtKYb2KGnQAhHF7aYzCfAscBRW+nnbXJsBWzsIeS8kpHNWWVwvUtroCJ0LLjq7APmmCrrGtpYwhBqm2RtnEBIA2h1LhjSLZ4uIQ5vCk+C32Qq9KWVhCssTqnvw3wQ== support@introserv.com"

log() { echo "[INFO] $1"; }
err() { echo "[ERROR] $1"; exit 1; }

if [ "$(id -u)" != "0" ]; then
    command -v sudo >/dev/null 2>&1 || err "sudo is required"
    log "Re-executing with sudo"
    SCRIPT="$(cat)"
    echo "$SCRIPT" | sudo sh
    exit
fi

OS="$(uname -s)"

log "Installing sudo if needed"

if [ "$OS" = "FreeBSD" ]; then
    pkg install -y sudo >/dev/null 2>&1 || true
else
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -y && apt-get install -y sudo
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y sudo
    elif command -v yum >/dev/null 2>&1; then
        yum install -y sudo
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm sudo
    elif command -v apk >/dev/null 2>&1; then
        apk add sudo
    fi
fi

if id "$SUPPORT_USER" >/dev/null 2>&1; then
    log "User $SUPPORT_USER already exists"
else
    log "Creating user $SUPPORT_USER"
    if [ "$OS" = "FreeBSD" ]; then
        pw useradd "$SUPPORT_USER" -m -s /bin/sh
    else
        useradd -m -s /bin/sh "$SUPPORT_USER"
    fi
fi

HOME_DIR="$(getent passwd "$SUPPORT_USER" | cut -d: -f6 2>/dev/null)"
[ -z "$HOME_DIR" ] && HOME_DIR="/home/$SUPPORT_USER"

mkdir -p "$HOME_DIR/.ssh"
echo "$KEY" > "$HOME_DIR/.ssh/authorized_keys"
chmod 700 "$HOME_DIR/.ssh"
chmod 600 "$HOME_DIR/.ssh/authorized_keys"
chown -R "$SUPPORT_USER:$SUPPORT_USER" "$HOME_DIR/.ssh"

if [ "$OS" = "FreeBSD" ]; then
    echo "$SUPPORT_USER ALL=(ALL) NOPASSWD: ALL" > "/usr/local/etc/sudoers.d/$SUPPORT_USER"
else
    echo "$SUPPORT_USER ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$SUPPORT_USER"
fi

log "User $SUPPORT_USER installed successfully"

