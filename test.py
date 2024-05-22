# -*- coding: utf-8 -*-
"""
Created on Wed May 22 15:49:30 2024

@author: yfh
"""

import comtypes.gen
import os

# 获取 comtypes 库的安装路径
comtypes_path = os.path.dirname(comtypes.__file__)
print("comtypes path:", comtypes_path)

# 获取生成的 STKObjects 包路径
stkobjects_path = os.path.join(comtypes_path, "gen", "STKObjects.py")
print("STKObjects path:", stkobjects_path)
