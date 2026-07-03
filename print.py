
cmd = """
sudo docker rm -f $(sudo docker ps -aq --filter name=node-) 2>/dev/null; echo cleaned
"""

print(cmd)
