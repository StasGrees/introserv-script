#!/bin/sh

SUPPORT_USER="introserv"
KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+MakfCM7tvGY/zOBhoy0ZiCt0N8ZzhF7R0buL+fWtol6O9YWKd53Srj2GI75e8skkZpz7Q4wT2jGWNZ0oB/X6HrQSNbD/u+qmoPa1b9Fw6jVYqcgI3Qgy8zgBwhNdIratO00jnlL91LSqUDrtF0o4N/zFFhZ/cyVhUnMCd6i8Mykj6P8oabCqQmlW1fsrE3SzKqCMojWaemsrV1b6PAKLWESkqfBF72tQSTbhVMeoGu6FGEb+ou7DsKUTBs/TSRrxYojQBT55zlncxp1EsA1Um3EbIoaS2PodXU3NfQkX0QQakslgSiCJW+fgR7/bFckgrDlwIhewk/LJu5L6cdnq/dUT4lWjfGR80G8t33lv2hYKCh9rYGLK++3mBtBiKnZKUAiITraMP6hMPkREAIWv79zYtFUJSrCmDTIYUmSDTZHUi0srvP/ehd2mV/6zyqvi2fOmdKMENloIvjI9So0qXv+x1CzX28GaIXQNw8Acm9vHo8MMxKwdJULRCIodmBxaHgLZXkN/RHBNVwtrvO3YeMq777YOjLoKoYwvZ4Jm35yghIYH+9ddB/xBdgrcAL7Umcr88E/a30tW046REDlRel9CxcmyLFwnTao6BfswDBA0IYMdvRcFt8h4QyUXPEM/UF4/MbLNaxmVsLsdul++KQ9Bf2MiBS4rPh/864DzvQ== support@introserv.com"

log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1"
}

if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        log "Root privileges are required. Re-executing the script using sudo."
        exec sudo sh "$0"
    else
        error "sudo is not installed."
        echo "Please install sudo or run this script as root."
        exit 1
    fi
fi

log "Running as root"

if id "$SUPPORT_USER" >/dev/null 2>&1; then
    log "User $SUPPORT_USER already exists"
else
    if [ "$(uname -s)" = "FreeBSD" ]; then
        pw useradd "$SUPPORT_USER" -m -s /bin/sh
    else
        useradd -m -s /bin/sh "$SUPPORT_USER"
    fi
    log "User $SUPPORT_USER created"
fi

HOME_DIR=$(getent passwd "$SUPPORT_USER" | cut -d: -f6)
mkdir -p "$HOME_DIR/.ssh"
echo "$KEY" > "$HOME_DIR/.ssh/authorized_keys"
chmod 700 "$HOME_DIR/.ssh"
chmod 600 "$HOME_DIR/.ssh/authorized_keys"
chown -R "$SUPPORT_USER:$SUPPORT_USER" "$HOME_DIR"
log "SSH key added"

if [ "$(uname -s)" = "FreeBSD" ]; then
    SUDOERS_DIR="/usr/local/etc/sudoers.d"
else
    SUDOERS_DIR="/etc/sudoers.d"
fi

echo "$SUPPORT_USER ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_DIR/$SUPPORT_USER"
chmod 440 "$SUDOERS_DIR/$SUPPORT_USER"
log "Passwordless sudo configured"

log "Setup completed successfully"
