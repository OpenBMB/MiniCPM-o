#!/bin/bash
# ============================================
# 生成自签名 SSL 证书（供 Nginx HTTPS + 手机端访问）
# 用法: bash deploy/gen_ssl_cert.sh [输出目录]
# ============================================
set -e

OUT_DIR="${1:-deploy/certs}"
mkdir -p "$OUT_DIR"

echo ">>> 生成自签名 SSL 证书到 $OUT_DIR ..."
openssl req -x509 -nodes -days 3650 \
    -newkey rsa:2048 \
    -keyout "$OUT_DIR/server.key" \
    -out "$OUT_DIR/server.crt" \
    -subj "/C=CN/ST=Local/L=Local/O=MiniCPMo/OU=Dev/CN=minicpmo-local" \
    -addext "subjectAltName=IP:127.0.0.1,IP:0.0.0.0,DNS:localhost"

echo ">>> 证书已生成:"
ls -lh "$OUT_DIR"/server.*
echo ""
echo ">>> 提示: 将 $OUT_DIR 整个目录上传到服务器后,"
echo "    在 docker-compose.yml 旁创建 certs/ 目录并放入 server.crt + server.key"
