# DevOps Assignment – Monitoring, Backups & Cron

This repo contains:
- `scripts/sys_monitor.sh` – appends system snapshots to `/var/log/sys_monitor.log`.
- `scripts/apache_backup.sh` – creates `/backups/apache_backup_YYYY-MM-DD.tar.gz` and a verify log.
- `scripts/nginx_backup.sh` – creates `/backups/nginx_backup_YYYY-MM-DD.tar.gz` and a verify log.
- `crons/crontab-root.txt` – example root crontab entries.

### How to install
1. Copy scripts to `/usr/local/bin` and make executable.
2. Ensure `/backups` exists and is writable by root.
3. Install cron jobs (either `crontab -e` or `/etc/cron.d/`).

### Notes
- Scripts add a robust `PATH` so cron can find tools.
- If Apache/Nginx dirs aren’t present, the scripts skip them gracefully.
- Requires `tar` (`yum install -y tar`).
