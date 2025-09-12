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

- OS (tested): RHEL/CentOS variants noted where applicable.
- Required privileges: `root` or `sudo`.
- Primary tools used: `htop`, `tar`, `cron`, `chage`, `pam_pwquality`.

---

## 3. Task 1 — System Monitoring

### 3.1 What I implemented
- Installed `htop`/`nmon` (if desired).
- Created `/usr/local/bin/sys_monitor.sh` to capture snapshots of uptime, memory, top processes, disk usage and sizes for `/home/*`.
- Scheduled the script to run every 10 minutes via cron.

### 3.2 Commands used
```bash
sudo apt install -y htop nmon libpam-pwquality

# Copied the script to /usr/local/bin/ (example)
sudo cp scripts/sys_monitor.sh /usr/local/bin/sys_monitor.sh
sudo chmod +x /usr/local/bin/sys_monitor.sh

# Added cron (run as root)
sudo crontab -l | cat - > /tmp/root_cron_backup
# then edit with sudo crontab -e to add:
# */10 * * * * /usr/local/bin/sys_monitor.sh

### 3.3 Example log excerpt (/var/log/sys_monitor.log)

### 3.4 Screenshots

docs/screenshots/sys_monitor_log.png - pasted screenshot of /var/log/sys_monitor.log.

## 4. Task 2 — User Management & Access Control
### 4.1 What I implemented

Created users Sarah and mike with home directories as specified:

/home/Sarah/workspace

/home/mike/workspace

Set restrictive permissions so only each user can access their workspace.

Enforced password expiry to 30 days with chage.

Configured PAM password complexity using pam_pwquality (example configuration).

### 4.2 Commands used
# Create users
sudo useradd -m -d /home/Sarah -s /bin/bash Sarah
sudo useradd -m -d /home/mike -s /bin/bash mike

# Set initial passwords (replace in production)
echo "Sarah:ChangeMe!2025" | sudo chpasswd
echo "mike:ChangeMe!2025" | sudo chpasswd

# Create workspace dirs and set permission
sudo mkdir -p /home/Sarah/workspace /home/mike/workspace
sudo chown -R Sarah:Sarah /home/Sarah
sudo chown -R mike:mike /home/mike
sudo chmod 700 /home/Sarah /home/Sarah/workspace
sudo chmod 700 /home/mike /home/mike/workspace

# Set password expiry to 30 days
sudo chage -M 30 Sarah
sudo chage -M 30 mike

# Verify
id Sarah
ls -ld /home/Sarah /home/Sarah/workspace
chage -l Sarah

### 4.3 Sample verification outputs - Screenshots are added in the Screenshots folder

### 4.4 Screenshots

docs/screenshots/id_sarah.png — output of id Sarah.

docs/screenshots/ls_home_sarah.png — ls -ld /home/Sarah output.

docs/screenshots/chage_sarah.png — chage -l Sarah output.

## 5. Task 3 — Backup Configuration for Web Servers
### 5.1 What I implemented

Created /backups and ensured root can write there.

Implemented two scripts:

scripts/apache_backup.sh — archives Apache config (/etc/httpd or /etc/apache2) and /var/www/html.

scripts/nginx_backup.sh — archives /etc/nginx and /usr/share/nginx/html (plus fallback /var/www/html).

Each script creates a compressed archive named:

/backups/apache_backup_YYYY-MM-DD.tar.gz

/backups/nginx_backup_YYYY-MM-DD.tar.gz

Each script writes a verification log:

/backups/apache_verify_YYYY-MM-DD.log

/backups/nginx_verify_YYYY-MM-DD.log

Scheduled both scripts to run every Tuesday at 00:00 via root cron.

### 5.2 Commands used
# Create backups dir
sudo mkdir -p /backups
sudo chown root:root /backups
sudo chmod 750 /backups

# Copy scripts and make executable
sudo cp scripts/apache_backup.sh /usr/local/bin/apache_backup.sh
sudo cp scripts/nginx_backup.sh /usr/local/bin/nginx_backup.sh
sudo chmod +x /usr/local/bin/apache_backup.sh /usr/local/bin/nginx_backup.sh

# Test-run the scripts (run as root)
sudo /usr/local/bin/apache_backup.sh
sudo /usr/local/bin/nginx_backup.sh

# Add root cron entries (sudo crontab -e)
# 0 0 * * 2 /usr/local/bin/apache_backup.sh
# 0 0 * * 2 /usr/local/bin/nginx_backup.sh

### 5.3 Example /backups directory listing
$ ls -lah /backups
total 9.2M
-rw-r--r-- 1 root root 4.2M Sep 12 00:00 apache_backup_2025-09-12.tar.gz
-rw-r--r-- 1 root root 5.1M Sep 12 00:00 nginx_backup_2025-09-12.tar.gz
-rw-r--r-- 1 root root   120 Sep 12 00:00 apache_verify_2025-09-12.log
-rw-r--r-- 1 root root   180 Sep 12 00:00 nginx_verify_2025-09-12.log

### 5.4 Example verification log (apache_verify_YYYY-MM-DD.log)
Verifying /backups/apache_backup_2025-09-12.tar.gz
etc/httpd/conf/httpd.conf
etc/httpd/conf.d/ssl.conf
var/www/html/index.html
Backup completed: /backups/apache_backup_2025-09-12.tar.gz

### 5.5 Screenshots

docs/screenshots/backups_ls.png — ls -lah /backups output.

docs/screenshots/apache_verify.png — contents of /backups/apache_verify_YYYY-MM-DD.log.

docs/screenshots/nginx_verify.png — contents of /backups/nginx_verify_YYYY-MM-DD.log.

## 6. Challenges & Notes

Different distro paths: Apache config may be in /etc/httpd (RHEL/CentOS). Backup scripts detects it.

PAM edits: Editing PAM (/etc/pam.d/common-password or /etc/pam.d/system-auth) can lock out users if misconfigured — always need to keep an open root session during changes.

Permissions for /backups: Running cron as root is simplest; if we prefer users to write backups, then we need to create a backup group and set group ownership/SGID appropriately.

End of report
