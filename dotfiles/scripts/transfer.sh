#!/bin/bash

# --- 颜色定义 ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- 检查环境变量 ---
# 从环境变量 TRANSFER_URL 获取上传地址
# 如果变量未设置或为空,则打印错误并退出
if [ -z "$TRANSFER_URL" ]; then
    echo -e "${RED}错误: 环境变量 TRANSFER_URL 未设置!${NC}"
    echo -e "请先设置上传地址, 例如:"
    echo -e "${YELLOW}export TRANSFER_URL=\"http://your-transfer_sh-url.com:port\"${NC}"
    exit 1
fi

BASE_URL="$TRANSFER_URL"

# --- 帮助信息 ---
usage() {
    echo "一个使用 cURL 上传文件到 transfer.sh 的脚本"
    echo ""
    echo -e "${YELLOW}用法:${NC}"
    echo "  $0 <文件路径>"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  $0 ./my_document.txt"
    exit 1
}

# --- 主逻辑 ---

# 检查是否提供了文件路径参数
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供要上传的文件路径。${NC}"
    usage
fi

FILE_PATH="$1"

# 检查文件是否存在
if [ ! -f "$FILE_PATH" ]; then
    echo -e "${RED}错误: 文件 '$FILE_PATH' 不存在!${NC}"
    exit 1
fi

FILENAME=$(basename "$FILE_PATH")

echo -e "正在上传: ${YELLOW}$FILENAME${NC} 到 ${BASE_URL}..."
echo ""

# 执行上传命令并捕获返回的分享链接
SHARE_URL=$(curl --progress-bar --upload-file "$FILE_PATH" "${BASE_URL}/${FILENAME}")

# 检查上传是否成功
if [[ $? -ne 0 || -z "$SHARE_URL" || ! "$SHARE_URL" == http* ]]; then
    echo -e "${RED}上传失败! 请检查你的网络或 TRANSFER_URL 是否正确。${NC}"
    exit 1
fi

# 根据分享链接生成直接下载链接 (raw link)
DOWNLOAD_URL=$(echo "$SHARE_URL" | sed "s|${BASE_URL}|${BASE_URL}/get|")

echo -e "--------------------------------------------------"
echo -e "${GREEN}✓ 上传成功!${NC}"
echo ""
echo -e "${YELLOW}分享链接:${NC} ${SHARE_URL}"
echo -e "${YELLOW}直接下载 (Raw):${NC} ${DOWNLOAD_URL}"
echo -e "--------------------------------------------------"