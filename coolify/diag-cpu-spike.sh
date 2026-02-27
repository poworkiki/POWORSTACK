#!/bin/bash
# === Script de diagnostic CPU spike pour VPS Coolify ===
# Lancer quand le CPU monte : ssh 168.231.69.226 'bash -s' < coolify/diag-cpu-spike.sh
# Ou copier sur le VPS et exécuter : bash diag-cpu-spike.sh

LOGFILE="/tmp/diag-cpu-$(date +%Y%m%d-%H%M%S).log"

echo "=== Diagnostic CPU — $(date) ===" | tee "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "--- 1. mpstat par core (5 échantillons, 1s) ---" | tee -a "$LOGFILE"
mpstat -P ALL 1 5 2>&1 | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "--- 2. Top 20 processus par CPU ---" | tee -a "$LOGFILE"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 20 2>&1 | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "--- 3. Docker conteneurs actifs ---" | tee -a "$LOGFILE"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' 2>&1 | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "--- 4. Docker stats (snapshot) ---" | tee -a "$LOGFILE"
docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}' 2>&1 | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "--- 5. Load + uptime ---" | tee -a "$LOGFILE"
uptime 2>&1 | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "--- 6. RAM ---" | tee -a "$LOGFILE"
free -h 2>&1 | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "--- 7. IO disque ---" | tee -a "$LOGFILE"
iostat -x 1 3 2>/dev/null | tee -a "$LOGFILE" || echo "iostat non disponible" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "=== Log sauvegardé dans $LOGFILE ===" | tee -a "$LOGFILE"
