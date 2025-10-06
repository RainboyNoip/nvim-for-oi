#!/usr/bin/env python3
"""
列出所有工具脚本及其功能说明
"""

import os
import sys

def main():
    # 定义工具脚本及其说明
    tools = {
        "b": "快速编译C++程序，支持g++和clang++",
        "dp.py": "对拍工具，用于对比两个程序的输出结果",
        "duipai.py": "自动化对拍工具，可进行多次测试",
        "one-duipai.py": "展示输入文件内容并对比两个程序的运行结果",
        "fzf.py": "使用fzf进行文件选择",
        "transfer.sh": "上传代码文件到transfer.sh服务器,需要设置环境变量TRANSFER_URL",
        "r-list-all-scripts.py": "列出所有工具脚本及其功能说明"
    }
    
    # 获取脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("可用的工具脚本:")
    print("=" * 50)
    
    # 遍历当前目录下的所有文件
    for filename in sorted(os.listdir(script_dir)):
        # 跳过目录和隐藏文件
        if os.path.isdir(os.path.join(script_dir, filename)) or filename.startswith('.'):
            continue
            
        # 获取文件的绝对路径
        file_path = os.path.join(script_dir, filename)
        
        # 检查是否为可执行文件
        if os.access(file_path, os.X_OK) and os.path.isfile(file_path):
            # 如果在我们的工具列表中，显示说明
            if filename in tools:
                print(f"{filename:<20} - {tools[filename]}")
            else:
                # 对于未在列表中的工具，显示基本说明
                print(f"{filename:<20} - 工具脚本")
        elif filename.endswith('.py') and filename != os.path.basename(__file__):
            # 对于Python脚本但不可执行的文件
            if filename in tools:
                print(f"{filename:<20} - {tools[filename]}")
            else:
                print(f"{filename:<20} - Python脚本")
    
    print("=" * 50)
    print("使用说明:")
    print("  1. 直接运行工具脚本名称即可使用")
    print("  2. 使用 <工具名> --help 查看详细帮助信息")

if __name__ == "__main__":
    main()