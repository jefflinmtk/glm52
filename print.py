# -*- coding: utf-8 -*-

# 用三引號包住整段文字，Python 會保留裡面的換行與空格
cmd = """docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu22.04 nvidia-smi"""

print(cmd)
