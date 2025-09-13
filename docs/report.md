# DevOps Assignment – System Monitoring, User Management & Backup Automation

**Prepared by:** Nikitha  
**Date:** 2025-09-13

---

## 1. Overview

This report documents the setup and verification of:

- System monitoring (Task 1)  
- User management & access control for two developers: Sarah and Mike (Task 2)  
- Automated backups for Sarah’s Apache server and Mike’s Nginx server, scheduled weekly with verification (Task 3)  

All scripts and cron entries are included in the repository under `scripts/` and `crons/`. Screenshots and terminal outputs are in `docs/screenshots/` and included below.

---

## 2. Environment

- OS (tested): Ubuntu 22.04 LTS (commands included are compatible with Debian/Ubuntu; RHEL/CentOS variants noted where applicable).  
- Required privileges: `root` or `sudo`.  
- Primary tools used: `htop`, `tar`, `cron`, `chage`, `pam_pwquality`.

---

## 3. Task 1 — System Monitoring

### 3.1 What I implemented
- Installed `htop`/`nmon`.  
- Created `/usr/local/bin/sys_monitor.sh` to capture snapshots of uptime, memory, top processes, disk usage and sizes for `/home/*`.  
- Scheduled the script to run every 10 minutes via cron.  

### 3.2 Commands used
```bash
# Install (Ubuntu)
sudo apt update
sudo apt install -y htop nmon libpam-pwquality

# Copy the script to /usr/local/bin/
sudo cp scripts/sys_monitor.sh /usr/local/bin/sys_monitor.sh
sudo chmod +x /usr/local/bin/sys_monitor.sh

# Add cron (run as root)
sudo crontab -e
# */10 * * * * /usr/local/bin/sys_monitor.sh```

### 3.3 Verification ###
tail -n 20 /var/log/sys_monitor.log

### 3.4 Screenshots ###

## 4. Task 2 — User Management & Access Control

### 4.1 What I implemented
Created users Sarah and mike with isolated home directories.

Set restrictive permissions so only each user can access their workspace.

Enforced password expiry to 30 days with chage.

Configured PAM password complexity with pam_pwquality.

