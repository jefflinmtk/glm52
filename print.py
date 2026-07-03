# -*- coding: utf-8 -*-

# 用三引號包住整段文字，Python 會保留裡面的換行與空格
cmd = """  # 1. 裝 NFS client 套件
  sudo apt update && sudo apt install -y nfs-common

  # 2. 建立掛載點(路徑要和 server 一致)
  sudo mkdir -p /srv/hf

  # 3. 掛載 server 的共享(10.248.13.123 是你 server 的 IP)
  sudo mount -t nfs 10.248.13.123:/srv/hf /srv/hf

  # 4. 驗證:應該看到模型資料夾
  ls /srv/hf/hub/models--nvidia--GLM-5.2-NVFP4"""

print(cmd)
