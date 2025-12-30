# Introserv Support Access Scripts

This package provides two scripts for managing Introserv support access: installing and removing the support user `introserv`.




## Supported OS

Debian / Ubuntu / Proxmox VE / CentOS / Fedora / AlmaLinux / Rocky Linux / CloudLinux / Arch Linux / Alpine Linux / openSUSE / SLES / FreeBSD




## Install Support User

Run the install script in one command:
```sh
curl -L https://raw.githubusercontent.com/StasGrees/introserv-script/refs/heads/main/introserv-support.sh | sudo sh
```
What happens: creates user `introserv` (if not exists), adds SSH public key for secure access (support@introserv.com), enables passwordless sudo.




## Remove Support User

Run the uninstall script in one command:
```sh
curl -L https://raw.githubusercontent.com/StasGrees/introserv-script/refs/heads/main/introserv-uninstall.sh | sudo sh
```
What happens: removes sudoers file for `introserv`, deletes the user and its home directory.




## Notes

Both scripts are idempotent and safe to run multiple times. SSH access is key-based only; no passwords are created. Installation and removal are fully reversible. Logs are printed to terminal for transparency.




## Support

For any questions or assistance, contact: support@introserv.com
