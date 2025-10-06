#!/bin/bash

# 设置颜色变量
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取脚本所在的目录的绝对路径
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
HOME_DIR=~
GIT_PROXY="https://gh-proxy.com/"

# 函数：创建符号链接，如果目标文件已存在则备份
# 参数1: 源文件
# 参数2: 目标文件
create_symlink() {
    local source_file="$1"
    local target_file="$2"

    # 如果目标文件已存在
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        # 如果它不是一个指向我们源文件的链接
        if [ "$(readlink "$target_file")" != "$source_file" ]; then
            echo -e "${YELLOW}Backing up existing $target_file to ${target_file}.bak${NC}"
            mv "$target_file" "${target_file}.bak"
        else
            echo -e "${GREEN}Symlink $target_file already exists and is correct. Skipping.${NC}"
            return
        fi
    fi

    echo -e "Creating symlink: ${GREEN}$target_file -> $source_file${NC}"
    # 创建符号链接
    ln -s "$source_file" "$target_file"
}

echo "Starting dotfiles installation..."

# 0. git clone 对应的仓库
echo ""
echo "Clone tmux plugin Manager.."
git clone $GIT_PROXY"https://github.com/tmux-plugins/tpm" "$HOME_DIR/.tmux/plugins/tpm"

# 1. 安装 tmux.conf
echo ""
echo "Installing tmux configuration..."
create_symlink "$SCRIPT_DIR/tmux.conf" "$HOME_DIR/.tmux.conf"

# 2. 安装 scripts 目录下的脚本
echo ""
echo "Installing scripts..."
BIN_DIR="$HOME_DIR/.local/bin"

# 确保 ~/.local/bin 目录存在
if [ ! -d "$BIN_DIR" ]; then
    echo "Creating directory: $BIN_DIR"
    mkdir -p "$BIN_DIR"
fi

# 遍历 scripts 目录下的所有文件
for script in "$SCRIPT_DIR/scripts"/*; do
    # 获取文件名
    filename=$(basename "$script")
    # 忽略 readme.md 文件
    if [ "$filename" == "readme.md" ]; then
        continue
    fi

    # 赋予可执行权限
    chmod +x "$script"
    # 在 ~/.local/bin 中创建链接，不带 .sh 后缀
    create_symlink "$script" "$BIN_DIR/${filename%.sh}"
done

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo -e "Please make sure ${YELLOW}'$BIN_DIR'${NC} is in your shell's \$PATH."
