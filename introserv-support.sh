#!/bin/sh
SUPPORT_USER="introserv"
KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw1Gcf0jUEXcCkyfG6Us8yjqcUGuE1GOL5+9N0cpE01VwbCxRG/55w8yUQoiEfzQmeD8DSmlrgrRP8Tm2GVgn7CFD1wLhbakL3+dgPcgyaT7I8cy/4+UQxPN1aysHP0rbSN1GgqNcv/CN8og/6GqJ3Y9Jw061wIP3mxM9P3pyOUZd4f6EWCPV77dYLwpabDQEeE88owjYSRMxRWU8yjVk3PVZr+JcwXtyBpf/2E/RSn2JJQgG0YiMUeZwNoklQMfDVnoev+NHlK7vfXKVro4QqAA0B5T1Noox8olLRLjbqMZAn0QtxF4NJ7Q9fgiIIbiUyTqhqsEDLTBdOvzE+gWOptmxW0Nu+SB35K88FZyeRUwGXcw3874I2RZwgedHJDQ49Lx7FxU5Z27SAzfqaTCV2RvIesCAAGRl2VMa2TAldGbIQqZ5U+VkqS+P/uKsJOqL+JX/et1/HjyiLY4BmwLUH/q7aGCVE4Tdk/24E2DkZnG+C3QfBFLNxrUaHAiIiKbwpYPxAXASPCRy5Y60KhJfLd++qqzJfqEfsDlWiQHecDOtGkqtKYb2KGnQAhHF7aYzCfAscBRW+nnbXJsBWzsIeS8kpHNWWVwvUtroCJ0LLjq7APmmCrrGtpYwhBqm2RtnEBIA2h1LhjSLZ4uIQ5vCk+C32Qq9KWVhCssTqnvw3wQ== auth@auth.systemintegra.ru"

log() {
    echo "[INFO] $1"
}

if [ "$(id -u)" != "0" ]; then
    if command -v sudo >/dev/null 2>&1; then
        log "Root privileges are required. Re-executing the script using sudo..."
        exec sudo sh -s "$@"
    else
        echo "[ERROR] This script must be run as root and sudo is not installed."
        exit 1
    fi
fi

log "Starting support user setup"

if command -v sudo >/dev/null 2>&1; then
    log "sudo is already installed"
else
    log "Installing sudo..."
    if [ -f /etc/debian_version ]; then
        apt-get update
        apt-get -y install sudo
    elif [ -f /etc/redhat-release ]; then
        if command -v dnf >/dev/null 2>&1; then
            dnf -y install sudo
        else
            yum -y install sudo
        fi
    elif [ -f /etc/arch-release ] || command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm sudo
    elif [ -f /etc/alpine-release ] || command -v apk >/dev/null 2>&1; then
        apk add --no-cache sudo
    elif command -v zypper >/dev/null 2>&1; then
        zypper --non-interactive install sudo
    elif [ "$(uname -s)" = "FreeBSD" ]; then
        pkg install -y sudo
    else
        log "Unsupported OS. Please install sudo manually."
        exit 1
    fi
fi

if id "$SUPPORT_USER" >/dev/null 2>&1; then
    log "User $SUPPORT_USER already exists"
else
    if [ "$(uname -s)" = "FreeBSD" ]; then
        pw useradd $SUPPORT_USER -m -s /bin/sh
    else
        useradd -m -s /bin/sh $SUPPORT_USER
    fi
    log "User $SUPPORT_USER created"
fi

HOME_DIR=$(getent passwd "$SUPPORT_USER" | cut -d: -f6)
mkdir -p "$HOME_DIR/.ssh"
chmod 700 "$HOME_DIR/.ssh"
chown "$SUPPORT_USER:$SUPPORT_USER" "$HOME_DIR/.ssh"

grep -qF "$KEY" "$HOME_DIR/.ssh/authorized_keys" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "$KEY" >> "$HOME_DIR/.ssh/authorized_keys"
    chmod 600 "$HOME_DIR/.ssh/authorized_keys"
    chown "$SUPPORT_USER:$SUPPORT_USER" "$HOME_DIR/.ssh/authorized_keys"
    log "SSH key added"
else
    log "SSH key already exists"
fi

if [ "$(uname -s)" = "FreeBSD" ]; then
    SUDO_FILE="/usr/local/etc/sudoers.d/$SUPPORT_USER"
else
    SUDO_FILE="/etc/sudoers.d/$SUPPORT_USER"
fi

if [ ! -f "$SUDO_FILE" ]; then
    echo "$SUPPORT_USER ALL=(ALL) NOPASSWD: ALL" > "$SUDO_FILE"
    chmod 440 "$SUDO_FILE"
    log "Passwordless sudo configured"
else
    log "Passwordless sudo already configured"
fi

log "Setup completed successfully"

