#!/usr/bin/env bash
# =============================================================================
# 04_serve_glm52.sh  ->  RUN THIS ON THE HEAD NODE, AFTER all 6 nodes joined.
#
# Launches vLLM across the 6-node Ray cluster and serves an OpenAI-compatible
# API on port 8000.
#
# WHY these parallel settings for 6x GB10 (1 GPU each, no NVLink, 100GbE):
#   - Each GB10 has ONE Blackwell GPU -> tensor-parallel-size 1 (per node).
#   - 6 nodes with a slow-ish interconnect (100GbE, no NVLink) -> use
#     PIPELINE parallelism across nodes: pipeline-parallel-size 6.
#     Pipeline parallel sends far less data between nodes than tensor parallel,
#     so it is the right choice when you don't have NVLink/InfiniBand.
#   - Model = 78 layers, ~465 GB weights. Split over 6 nodes => ~13 layers and
#     ~77 GB per node, which fits inside each 128 GB unified memory with room
#     for KV cache and activations.
#   - NVFP4 runs natively on Blackwell; FP8 KV cache halves KV memory.
# =============================================================================
set -euo pipefail

# ---- Config ----------------------------------------------------------------
# Path to the model AS SEEN INSIDE THE CONTAINER. run_cluster.sh mounts your
# HF_HOME at /root/.cache/huggingface, so either use the repo id (vLLM will find
# it in the mounted cache) or the concrete snapshot path. Repo id is simplest:
MODEL="nvidia/GLM-5.2-NVFP4"
PORT=8000
MAX_LEN=131072   # start at 128k; raise toward 1048576 later if memory allows
# ----------------------------------------------------------------------------

# run_cluster.sh names the container node-<RANDOM>, so auto-detect it.
CONTAINER="$(sudo docker ps --filter 'name=node-' --format '{{.Names}}' | head -1)"
if [[ -z "$CONTAINER" ]]; then
  echo ">> No running 'node-*' container found. Is the Ray head up (script 02)?"
  exit 1
fi
echo ">> Using head container: $CONTAINER"

# Exec INTO the running head container and launch the server there so it sees
# the whole Ray cluster.
sudo docker exec -it "$CONTAINER" \
  bash -lc "
    echo '>> Ray cluster status:'; ray status || true
    echo '>> Starting vLLM serve (this loads ~465GB across 6 nodes; be patient)...'
    vllm serve '$MODEL' \
        --served-model-name glm-5.2 \
        --tensor-parallel-size 1 \
        --pipeline-parallel-size 6 \
        --distributed-executor-backend ray \
        --enable-expert-parallel \
        --trust-remote-code \
        --quantization modelopt_fp4 \
        --kv-cache-dtype fp8_e4m3 \
        --reasoning-parser glm45 \
        --tool-call-parser glm47 \
        --enable-auto-tool-choice \
        --max-model-len $MAX_LEN \
        --gpu-memory-utilization 0.90 \
        --host 0.0.0.0 --port $PORT
  "
