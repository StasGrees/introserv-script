#!/bin/sh
SUPPORT_USER="introserv"

log() {
    echo "[INFO] $1"
}

if [ "$(id -u)" != "0" ]; then
    echo "[ERROR] This script must be run as root"
    exit 1
fi

log "Starting support user removal"

if [ "$(uname -s)" = "FreeBSD" ]; then
    if [ -f /usr/local/etc/sudoers.d/$SUPPORT_USER ]; then
        rm -f /usr/local/etc/sudoers.d/$SUPPORT_USER
        log "Removed sudoers file"
    else
        log "No sudoers file found for $SUPPORT_USER"
    fi
else
    if [ -f /etc/sudoers.d/$SUPPORT_USER ]; then
        rm -f /etc/sudoers.d/$SUPPORT_USER
        log "Removed sudoers file"
    else
        log "No sudoers file found for $SUPPORT_USER"
    fi
fi

if id "$SUPPORT_USER" >/dev/null 2>&1; then
    log "Stopping all processes of $SUPPORT_USER"
    pkill -u "$SUPPORT_USER" 2>/dev/null || true
    sleep 1
fi

if id "$SUPPORT_USER" >/dev/null 2>&1; then
    log "Removing user $SUPPORT_USER"
    if [ "$(uname -s)" = "FreeBSD" ]; then
        pw userdel "$SUPPORT_USER" -r
    else
        userdel -r "$SUPPORT_USER"
    fi
    log "User $SUPPORT_USER removed"
else
    log "User $SUPPORT_USER does not exist"
fi

log "Cleanup completed successfully"
