
cmd = """docker run --rm --entrypoint bash vllm/vllm-openai:v0.23.0 -c "python -c 'import ray; print(ray.__version__)'; pip show ray          2>/dev/null | head -3; ls /usr/local/bin | grep -i ray""""

print(cmd)
