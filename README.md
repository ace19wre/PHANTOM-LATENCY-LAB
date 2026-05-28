# Network Diagnostics Lab: The Phantom Latency

Welcome to the Production Application Server incident response lab. Your objective is to troubleshoot routing loops, isolate suspicious exfiltration network states, and deploy programmatic tracing utilities on a compromised node.

---

## 📋 Prerequisites

Before starting, ensure you have the following installed on your machine:
* **Docker:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows & macOS) or [Docker Engine](https://docs.docker.com/engine/install/) (Linux).
* **SSH Client:** Modern versions of Windows (PowerShell/CMD), macOS, and Linux have this built-in natively.

---

# 🚀 How to Run the Lab

### 1. Download and Initialize the Environment
Open your terminal or PowerShell and run the one-liner command corresponding to your Operating System. This will automatically download the lab files, navigate to the correct directory, and spin up the Docker environment.

* **For Linux & macOS Users:**
  Because Docker requires elevated system privileges on Linux, you will need to use `sudo` to clone and set up the environment. Follow these 3 steps:

  **Step 1: Clone the repository and navigate into the directory**
  ```bash
  sudo git clone https://github.com/ace19wre/phantom-latency-lab.git && cd phantom-latency-lab
  ```

  **Step 2: Grant execution permissions to the setup script**
  ```bash
  sudo chmod +x init-lab.sh
  ```

  **Step 3: Run the initialization script**
  ```bash
  sudo ./init-lab.sh
  ```
* **For Windows Users (Run in PowerShell as Administrator):**
```powershell
git clone -c core.autocrlf=false https://github.com/ace19wre/phantom-latency-lab.git; if ($?) { cd phantom-latency-lab; Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process; .\init-lab.ps1 }
```

### 2. Log into the Target Server
Once the initialization script finishes successfully, SSH into the affected production server (`Prod-App-01`):
```bash
ssh student@localhost -p 22222
```
* **Password:** `123`

---

## 🛠️ Verification & Evaluation Rules

You are confined to using native Linux CLI networking utilities (`ping`, `traceroute`, `netstat`, `route`, `ip`, `arp`) inside the container. 

To check your progress and see if your fixes are functioning correctly at any point during the lab, run the following command directly from the `Prod-App-01` terminal shell:

```bash
check
```

The system will instantly evaluate your log output configuration, live kernel routing rules, and threat containment setups to print a live status summary.
