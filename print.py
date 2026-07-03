
cmd = """
docker save vllm-ray:v0.23.0 | gzip > /srv/hf/vllm-ray.tar.gz
"""

print(cmd)
