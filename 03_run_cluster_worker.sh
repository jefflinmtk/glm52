#!/usr/bin/env bash
# =============================================================================
# 03_run_cluster_worker.sh  ->  RUN THIS ON NODES 2..6 (the "workers").
#
# Joins the Ray cluster started by the head node. Run one per worker.
# Keep each terminal OPEN (use screen). Set THIS_NODE_IP per machine.
# =============================================================================
set -euo pipefail

# ---- Config: EDIT THESE per worker ----------------------------------------
HEAD_NODE_IP="10.248.13.123"           # <-- the HEAD node's IP (same on all workers)
THIS_NODE_IP="10.248.13.22"            # <-- THIS worker's own IP (unique per node!)
export HF_HOME="${HF_HOME:-/srv/hf}"   # <-- NFS shared path, same on all 6 nodes
VLLM_IMAGE="vllm-ray:v0.23.0"          # custom image = official v0.23.0 + ray (arm64)
# ----------------------------------------------------------------------------

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RC="$HERE/run_cluster.sh"
if [[ ! -f "$RC" ]]; then
  echo ">> Fetching run_cluster.sh from vLLM repo"
  curl -fsSL -o "$RC" \
    https://raw.githubusercontent.com/vllm-project/vllm/v0.11.0/examples/online_serving/run_cluster.sh
  chmod +x "$RC"
fi

# Local custom image (built from Dockerfile.ray). Only pull if missing.
if ! docker image inspect "$VLLM_IMAGE" >/dev/null 2>&1; then
  echo ">> Image $VLLM_IMAGE not found locally."
  echo "   Load it from NFS: docker load < /srv/hf/vllm-ray.tar.gz"
  exit 1
fi

echo ">> Joining Ray cluster: head=$HEAD_NODE_IP  this=$THIS_NODE_IP"
echo "   Leave this running. Detach screen with Ctrl-a d."
bash "$RC" \
    "$VLLM_IMAGE" \
    "$HEAD_NODE_IP" \
    --worker \
    "$HF_HOME" \
    -e VLLM_HOST_IP="$THIS_NODE_IP"
