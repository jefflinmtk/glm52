
cmd = """
  cat > Dockerfile.ray <<'EOF'
  FROM vllm/vllm-openai:v0.23.0
  RUN pip install --no-cache-dir "ray[default]"
  EOF
"""

print(cmd)
