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
VLLM_IMAGE="vllm/vllm-openai:v0.23.0"  # version required by the model card
# ----------------------------------------------------------------------------

# vLLM ships run_cluster.sh in its repo. Fetch it if not present.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RC="$HERE/run_cluster.sh"
if [[ ! -f "$RC" ]]; then
  echo ">> Fetching run_cluster.sh from vLLM repo"
  curl -fsSL -o "$RC" \
    https://raw.githubusercontent.com/vllm-project/vllm/v0.11.0/examples/online_serving/run_cluster.sh
  chmod +x "$RC"
fi

echo ">> Pulling image (first time only): $VLLM_IMAGE"
docker pull "$VLLM_IMAGE"

echo ">> Starting Ray HEAD on $HEAD_NODE_IP"
echo "   Leave this running. Detach screen with Ctrl-a d."
bash "$RC" \
    "$VLLM_IMAGE" \
    "$HEAD_NODE_IP" \
    --head \
    "$HF_HOME" \
    -e VLLM_HOST_IP="$HEAD_NODE_IP"
