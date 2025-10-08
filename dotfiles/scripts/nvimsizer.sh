#!/bin/bash

# 检查参数数量
if [ "$#" -ne 2 ]; then
    echo "使用方法: $0 <主文件> <侧边文件>"
    exit 1
fi

MAIN_FILE=$1
SIDE_FILE=$2

# 使用 wc -L 命令计算最长行的长度，非常高效
# < "$SIDE_FILE" 用于将文件内容重定向到 wc 命令的标准输入
MAX_WIDTH=$(wc -L < "$SIDE_FILE")

# 增加一点 padding
WIDTH_WITH_PADDING=$((MAX_WIDTH + 2))

# 启动 nvim 并执行命令
nvim -O "$MAIN_FILE" "$SIDE_FILE" -c "wincmd l | vertical resize $WIDTH_WITH_PADDING | wincmd h"
