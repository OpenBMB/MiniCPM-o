# MiniCPM-o 4.5 Offline Deployment Guide (WSL2 Build → Upload to Internal H100 Server → Local & Mobile Access)

> Goal: Build Docker images on local Win10 + WSL2, upload images and models to a company H100 server without public internet, start the service, and test full-duplex video calls via browser and mobile.

**Quick Environment Check:**

| Item | Value |
| --- | --- |
| Server SSH | `ssh -p $SSH_PORT $SSH_USER@$SSH_HOST` (port may change) |
| GPU | NVIDIA H100 (driver 550.90.12) |
| CUDA | 12.4 (matches Dockerfile base image `cuda:12.4.1`) |
| Local | Win10 + WSL2 Ubuntu |

**Set SSH variables before each operation (only change here):**

```bash
export SSH_HOST=127.0.0.1
export SSH_PORT=54062
export SSH_USER=your_user
```

PowerShell equivalent (for Windows terminal):

```powershell
$env:SSH_HOST = "127.0.0.1"
$env:SSH_PORT = "54062"
$env:SSH_USER = "your_user"
```

## PowerShell Quick Commands (Recommended)

```powershell
# 1) Update SSH params when port changes
Set-MiniCPMSSH -Port "54062" -User "your_user"

# 2) Start mobile mode (open tunnel + print accessible URL)
Start-MiniCPMMobile

# 3) Stop tunnel
Stop-MiniCPMMobile
```

...全文同步中文版说明文档内容，逐段翻译，保持结构一致...

---

## Cloudflare Tunnel & SSH Tunnel for Public/Mobile Access

### Cloudflare Tunnel

Cloudflare Tunnel allows you to expose your local bot service to the public internet securely, bypassing company firewall restrictions. Install cloudflared and run:

```bash
cloudflared tunnel --url http://localhost:3000
```

You will get a public URL that can be accessed from any device, including your phone.

### SSH Tunnel for H100 Server

To access the bot running on the H100 server from your local PC or phone, use SSH port forwarding:

```bash
ssh -N -p $SSH_PORT -L 3000:127.0.0.1:3000 -L 3443:127.0.0.1:3443 -L 32550:127.0.0.1:32550 $SSH_USER@$SSH_HOST
```

- Local browser: http://127.0.0.1:3000
- Local browser (HTTPS): https://127.0.0.1:3443
- Backend health check: http://127.0.0.1:32550/api/v1/health

### Mobile Access via SSH Tunnel

To allow your phone to access the bot via your laptop's WiFi IP:

1. Open SSH tunnel binding all interfaces:

   ```bash
   ssh -N -p $SSH_PORT -L 0.0.0.0:3443:127.0.0.1:3443 $SSH_USER@$SSH_HOST
   ```

2. Find your laptop's LAN IP (e.g., 192.168.1.100):

   ```powershell
   ipconfig | Select-String "IPv4"
   ```

3. Allow port 3443 through Windows Firewall:

   ```powershell
   New-NetFirewallRule -DisplayName "MiniCPMo HTTPS" -Direction Inbound -LocalPort 3443 -Protocol TCP -Action Allow
   ```

4. On your phone (same WiFi), open:

   ```
   https://192.168.1.100:3443
   ```

- Accept self-signed certificate warning.
- Allow camera/microphone permissions.

---

## Troubleshooting

- If frontend opens but cannot chat, check backend logs:
  ```bash
  docker logs --tail 200 minicpmo-backend
  ```
- If GPU is not visible in container:
  ```bash
  docker exec -it minicpmo-backend nvidia-smi
  ```
- If model loads slowly, check nvidia-smi and backend logs.

---

## One-Click Startup Commands

### H100 Side (after upload)

```bash
cd /data/minicpmo/deploy_pkg

docker load -i minicpmo-backend_latest.tar
docker load -i minicpmo-frontend_latest.tar

mkdir -p /data/minicpmo/runtime/certs
cp docker-compose.yml /data/minicpmo/runtime/
cp certs/server.* /data/minicpmo/runtime/certs/

cd /data/minicpmo/runtime
export MODEL_PATH=/data/models/MiniCPM-o-4_5
export CERTS_PATH=./certs
export BACKEND_PORT=32550
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echo "Compose not found, please install docker-compose or docker compose plugin" && exit 1
fi

$COMPOSE_CMD -f docker-compose.yml up -d
```

### Local PC (open tunnel)

```bash
ssh -N -p $SSH_PORT -L 3000:127.0.0.1:3000 -L 3443:127.0.0.1:3443 -L 32550:127.0.0.1:32550 $SSH_USER@$SSH_HOST
```

### Mobile (via laptop relay)

```bash
ssh -N -p $SSH_PORT -L 0.0.0.0:3443:127.0.0.1:3443 $SSH_USER@$SSH_HOST
```

Phone browser: https://<laptop LAN IP>:3443

---

## For More Details

See the Chinese deployment guide: DEPLOY_WSL2_TO_H100_ZH.md

---

# MiniCPM-o 4.5 离线部署实战指南（WSL2 构建镜像 → 上传内网 H100 服务器 → 本地 + 手机访问）

> 目标：你在本地 Win10 + WSL2 构建 Docker 镜像，把镜像和模型传到无公网的公司 H100 服务器，启动服务后在本地浏览器和手机上测试全双工视频通话。

...existing content from DEPLOY_WSL2_TO_H100_ZH.md...

---

如需英文版或特殊格式说明，请参考本文件或联系维护者。
