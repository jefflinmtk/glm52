
cmd = """
docker image inspect vllm-ray:v0.23.0 --format '{{.Architecture}}'
"""

print(cmd)
