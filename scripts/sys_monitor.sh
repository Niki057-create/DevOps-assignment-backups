#!/usr/bin/env bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH
LOG=/var/log/sys_monitor.log
TS="$(date '+%Y-%m-%d %H:%M:%S')"
echo "===== Snapshot: $TS =====" >> "$LOG"
echo "## Uptime & Load" >> "$LOG"
uptime >> "$LOG"
echo -e "\n## Free Memory (MB)" >> "$LOG"
free -m >> "$LOG"
echo -e "\n## Top CPU (top -b -n1 head 15)" >> "$LOG"
top -b -n1 | head -n 15 >> "$LOG"
echo -e "\n## Top 10 Memory Consumers" >> "$LOG"
ps aux --sort=-%mem | awk 'NR==1 || NR<=11' >> "$LOG"
echo -e "\n## Disk Usage (df -h)" >> "$LOG"
df -h >> "$LOG"
echo -e "\n## Home dir sizes (du -sh /home/*)" >> "$LOG"
du -sh /home/* 2>/dev/null | sort -hr >> "$LOG"
echo -e "\n===== End Snapshot =====\n" >> "$LOG"
