
cmd = """
docker run --rm --entrypoint bash vllm-ray:v0.23.0 -c "ray --version"
"""

print(cmd)
