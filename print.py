# -*- coding: utf-8 -*-

# 用三引號包住整段文字，Python 會保留裡面的換行與空格
cmd = """sudo bash -c 'cat > /etc/exports <<EOF
/srv/hf 10.248.13.22(ro,sync,no_subtree_check,no_root_squash)
/srv/hf 10.248.13.23(ro,sync,no_subtree_check,no_root_squash)
/srv/hf 10.248.13.24(ro,sync,no_subtree_check,no_root_squash)
/srv/hf 10.248.13.25(ro,sync,no_subtree_check,no_root_squash)
/srv/hf 10.248.13.122(ro,sync,no_subtree_check,no_root_squash)
/srv/hf 10.248.13.123(ro,sync,no_subtree_check,no_root_squash)
EOF'"""

print(cmd)
