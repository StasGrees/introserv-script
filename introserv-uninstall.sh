#!/bin/sh
SUPPORT_USER="introserv"

log() {
    echo "[INFO] $1"
}

log "Starting support user removal"

if [ "$(uname -s)" = "FreeBSD" ]; then
    if [ -f /usr/local/etc/sudoers.d/$SUPPORT_USER ]; then
        rm -f /usr/local/etc/sudoers.d/$SUPPORT_USER
        log "Removed sudoers file"
    fi
else
    if [ -f /etc/sudoers.d/$SUPPORT_USER ]; then
        rm -f /etc/sudoers.d/$SUPPORT_USER
        log "Removed sudoers file"
    fi
fi

if id "$SUPPORT_USER" >/dev/null 2>&1; then
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

