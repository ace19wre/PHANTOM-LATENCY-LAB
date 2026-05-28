# Lab Initialization Orchestrator for Windows (PowerShell)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      STARTING PHANTOM LATENCY ENVIRONMENT       " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 0. Check if Docker daemon is running
Write-Host "[*] Checking Docker daemon status..." -ForegroundColor Yellow
$null = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker daemon is not running or unresponsive." -ForegroundColor Red
    Write-Host "Please start Docker Desktop/Daemon and try again." -ForegroundColor Red
    exit
}

# 1. Spin down old environments and boot up cleanly
docker compose down -v --remove-orphans 2>$null
docker network prune -f | Out-Null
docker compose up -d --build

Write-Host "[*] Booting dependencies, structural paths initializing..." -ForegroundColor Yellow

# 2. Synchronously install network tools on the blank routers
Write-Host "[*] Installing network utilities on router nodes... (This may take a moment)"
docker exec Router-A apt-get update -qq
docker exec Router-A apt-get install -y iproute2 -qq
docker exec Router-B apt-get update -qq
docker exec Router-B apt-get install -y iproute2 -qq
docker exec Backup-GW apt-get update -qq
docker exec Backup-GW apt-get install -y iproute2 -qq

# 3. Configure Core Routing Path & Loops
Write-Host "[*] Configuring virtual routes and loops..." -ForegroundColor Yellow
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
docker exec -d Prod-App-01 python3 -c "import socket, time; s=socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.settimeout(2); [exec('try:\n s.connect((\x22198.51.100.42\x22, 443))\nexcept:\n pass\ntime.sleep(2)') for _ in iter(int, 1)]"

Write-Host "==================================================" -ForegroundColor Green
Write-Host "SUCCESS: Lab environment setup complete." -ForegroundColor Green
Write-Host "Connect using: ssh student@localhost -p 22222" -ForegroundColor Green
Write-Host "Password: 123" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
