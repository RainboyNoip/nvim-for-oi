#!/bin/bash

# 设置颜色变量
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取脚本所在的目录的绝对路径
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
HOME_DIR=~

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
git clone "https://github.com/tmux-plugins/tpm" "$HOME_DIR/.tmux/plugins/tpm"

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

# 3. 安装 C++ 格式规则（clang-format）
echo ""
echo "Installing clang-format style..."
create_symlink "$SCRIPT_DIR/../config/clang-format" "$HOME_DIR/.clang-format"

# clang-format 从文件所在目录逐级向上找 .clang-format，/tmp 的父目录是 /，
# 找不到 ~/.clang-format，临时题单文件会退回纯 LLVM 风格（2 空格、全部展开）。
# 补一条软链覆盖 /tmp；但 /tmp 一般是 tmpfs，重启即清空。
if [ -e "$HOME_DIR/.clang-format" ] || [ -L "$HOME_DIR/.clang-format" ]; then
    ln -sfn "$HOME_DIR/.clang-format" /tmp/.clang-format
    echo -e "${GREEN}Symlink /tmp/.clang-format -> $HOME_DIR/.clang-format${NC}"
    echo -e "${YELLOW}注意: /tmp 重启即清空，需要时重跑本脚本，${NC}"
    echo -e "${YELLOW}或自行加一句: ln -sfn ~/.clang-format /tmp/.clang-format${NC}"
fi

# 4. 安装 ruff 用户级配置（Python 格式化行宽等）
echo ""
echo "Installing ruff config..."
mkdir -p "$HOME_DIR/.config/ruff"
create_symlink "$SCRIPT_DIR/../config/ruff.toml" "$HOME_DIR/.config/ruff/ruff.toml"

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo -e "Please make sure ${YELLOW}'$BIN_DIR'${NC} is in your shell's \$PATH."
