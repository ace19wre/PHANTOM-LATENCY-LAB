#!/bin/bash
# Lab Initialization Orchestrator

# Tell the script to stop immediately if any command fails
set -e

# Catch unexpected errors and print a helpful message instead of "SUCCESS"
error_handler() {
    echo -e "\n=================================================="
    echo " ❌ ERROR: Lab initialization failed midway!"
    echo " Please read the error messages above to see what went wrong."
    echo "=================================================="
}
trap 'error_handler' ERR

echo "=================================================="
echo "      STARTING PHANTOM LATENCY ENVIRONMENT       "
echo "=================================================="

# 0. Check if Docker daemon is running
echo "[*] Checking Docker daemon status..."
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker daemon is not running or you lack permissions."
    echo "Please start the Docker service or run with appropriate privileges."
    exit 1
fi

# 1. Spin down old environments and boot up cleanly
docker compose down -v --remove-orphans &>/dev/null
docker network prune -f &>/dev/null
docker compose up -d --build

echo "[*] Booting dependencies, structural paths initializing..."

# 2. Synchronously install network tools on the blank routers
echo "[*] Installing network utilities on router nodes... (This may take a moment)"
docker exec Router-A apt-get update -qq
docker exec Router-A apt-get install -y iproute2 -qq
docker exec Router-B apt-get update -qq
docker exec Router-B apt-get install -y iproute2 -qq
docker exec Backup-GW apt-get update -qq
docker exec Backup-GW apt-get install -y iproute2 -qq

# 3. Configure Core Routing Path & Loops
echo "[*] Configuring virtual routes and loops..."
# Loop setup: A sends to B, B sends back to A (Changed 'add' to 'replace')
docker exec Router-A ip route replace 192.168.243.0/24 via 192.168.242.10
docker exec Router-B ip route replace 192.168.243.0/24 via 192.168.242.5
# Fix: Prod-App-01 targets Router-A's new local IP on the user subnet (.10)
docker exec Prod-App-01 ip route replace 192.168.243.0/24 via 192.168.241.10

# Configure Backup Gateway Path (Removed sysctl line entirely, changed 'add' to 'replace')
docker exec Backup-GW ip route replace 192.168.243.0/24 dev eth1

# 4. Inject Interface Degradation (200ms latency / 15% packet drops)
docker exec Router-A tc qdisc add dev eth1 root netem delay 200ms 10ms loss 15%

# 5. Spawn Suspicious Connection (Static PID Python Malware)
docker exec -d Prod-App-01 python3 -c '
import socket
import time

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(2)

while True:
    try:
        s.connect(("198.51.100.42", 443))
    except Exception:
        pass
    time.sleep(2)
'

echo "=================================================="
echo "SUCCESS: Lab environment setup complete."
echo "Connect using: ssh student@localhost -p 22222"
echo "Password: 123"
echo "=================================================="
