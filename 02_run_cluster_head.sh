#!/usr/bin/env bash
# =============================================================================
# 02_run_cluster_head.sh   ->  RUN THIS ON NODE 1 ONLY (the "head").
#
# Starts the vLLM container and initializes the Ray HEAD node.
# Keep this terminal OPEN (use screen). Closing it tears down the cluster.
#
# Prereqs on every node:
#   - Docker + NVIDIA Container Toolkit installed
#   - GLM-5.2-NVFP4 present at $HF_HOME (same path on every node, or NFS)
#   - All nodes can ping each other over the 100GbE network
# =============================================================================
set -euo pipefail

# ---- Config: EDIT THESE ----------------------------------------------------
HEAD_NODE_IP="10.248.13.123"           # <-- this node's IP (the NFS server / head)
export HF_HOME="${HF_HOME:-/srv/hf}"   # <-- NFS shared path, same on all 6 nodes
VLLM_IMAGE="vllm-ray:v0.23.0"          # custom image = official v0.23.0 + ray (arm64)
# ----------------------------------------------------------------------------

# vLLM ships run_cluster.sh in its repo. Always fetch fresh, then patch it so
# its internal `docker run` uses sudo (this environment needs sudo for docker).
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RC="$HERE/run_cluster.sh"
echo ">> Fetching run_cluster.sh from vLLM repo"
curl -fsSL -o "$RC" \
  https://raw.githubusercontent.com/vllm-project/vllm/v0.11.0/examples/online_serving/run_cluster.sh
sed -i 's/\bdocker /sudo docker /g' "$RC"   # docker needs sudo here
chmod +x "$RC"

# Local custom image (built from Dockerfile.ray). Only pull if missing.
if ! sudo docker image inspect "$VLLM_IMAGE" >/dev/null 2>&1; then
  echo ">> Image $VLLM_IMAGE not found locally."
  echo "   Build it: docker build -f Dockerfile.ray -t $VLLM_IMAGE ."
  echo "   Or load from NFS: docker load < /srv/hf/vllm-ray.tar.gz"
  exit 1
fi

# Detect the NIC that owns this node's IP, so Gloo/NCCL bind to the real
# 100GbE interface instead of loopback (fixes "connectFullMesh ... 127.0.0.1").
IFACE="$(ip -o -4 addr show | awk -v ip="$HEAD_NODE_IP" '$4 ~ ip"/" {print $2; exit}')"
echo ">> Detected network interface for $HEAD_NODE_IP: ${IFACE:-<none>}"
[[ -z "$IFACE" ]] && { echo "ERROR: could not find NIC for $HEAD_NODE_IP"; exit 1; }

echo ">> Starting Ray HEAD on $HEAD_NODE_IP"
echo "   Leave this running. Detach screen with Ctrl-a d."
bash "$RC" \
    "$VLLM_IMAGE" \
    "$HEAD_NODE_IP" \
    --head \
    "$HF_HOME" \
    -e VLLM_HOST_IP="$HEAD_NODE_IP" \
    -e GLOO_SOCKET_IFNAME="$IFACE" \
    -e NCCL_SOCKET_IFNAME="$IFACE"
