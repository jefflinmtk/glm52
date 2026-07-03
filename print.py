
cmd = """
sudo docker exec -it $(sudo docker ps --filter name=node- --format '{{.Names}}' | head -1) ray status
"""

print(cmd)
