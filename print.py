# -*- coding: utf-8 -*-
# 直接使用三引號，保留所有換行與空白
command = """sudo bash -c 'cat >> /etc/exports <<EOF
/srv/hf 10.248.13.23(ro,sync,no_subtree_check,no_root_squash) 10.248.13.24(ro,sync,no_subtree_check,no_root_squash)
10.248.13.25(ro,sync,no_subtree_check,no_root_squash) 10.248.13.123(ro,sync,no_subtree_check,no_root_squash)
10.248.13.22(ro,sync,no_subtree_check,no_root_squash) 10.248.13.122(ro,sync,no_subtree_check,no_root_squash)
EOF'"""
print(command)
