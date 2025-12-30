#!/bin/sh
SUPPORT_USER="introserv"
KEY="ssh-rsa AAAAB3... support@introserv.com"

log() {
    echo "[INFO] $1"
}

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
echo "$KEY" > "$HOME_DIR/.ssh/authorized_keys"
chmod 600 "$HOME_DIR/.ssh/authorized_keys"
chmod 700 "$HOME_DIR/.ssh"
chown -R "$SUPPORT_USER:$SUPPORT_USER" "$HOME_DIR"
log "SSH key added"

if [ "$(uname -s)" = "FreeBSD" ]; then
    echo "$SUPPORT_USER ALL=(ALL) NOPASSWD: ALL" > /usr/local/etc/sudoers.d/$SUPPORT_USER
    chmod 440 /usr/local/etc/sudoers.d/$SUPPORT_USER
else
    echo "$SUPPORT_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$SUPPORT_USER
    chmod 440 /etc/sudoers.d/$SUPPORT_USER
fi
log "Passwordless sudo configured"

log "Setup completed successfully"

