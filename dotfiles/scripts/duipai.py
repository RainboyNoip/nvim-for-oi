#!/usr/bin/env python3
"""
对拍脚本 - 用于自动化测试程序正确性
author: rainboy
用途: 自动生成测试数据，运行用户程序和标准程序并对比输出结果
"""

import os
import sys
import subprocess
import argparse
import shutil

import mylib.fzf as fzf

# 默认配置
TOTAL_COUNT = None
COMPARE_DIR = None
DATA_CODE = None
USR_CODE = None
STD_CODE = None

# 程序变量将在main函数中初始化
USR_PROGRAM = None
STD_PROGRAM = None
DATA_GENERATOR = None

# 比较的基本路径
# tmp 是一个在内存中的filesystem,速度快
BASE_DIR = "/tmp"


def compile_if_newer(code_file, out_file):
    """
    如果源代码比可执行文件新，则重新编译
    :param code_file: 源代码文件
    :param out_file: 可执行文件
    """
    if not os.path.exists(code_file):
        print(f"错误: 源代码文件 {code_file} 不存在")
        sys.exit(1)
        
    if not os.path.exists(out_file) or os.path.getmtime(code_file) > os.path.getmtime(out_file):
        print(f"{code_file} 比 {out_file} 新，正在编译...")
        # 调用b脚本进行编译
        compile_cmd = ["b", "--no_debug", code_file, "-o", out_file, "--not_in"]
        try:
            result = subprocess.run(compile_cmd, check=True)
            if result.returncode != 0:
                print("编译失败!")
                sys.exit(1)
        except subprocess.CalledProcessError:
            print("编译失败!")
            sys.exit(1)


def show_progress(total, current, width=50):
    """
    显示进度条
    :param total: 总数
    :param current: 当前进度
    :param width: 进度条宽度
    """
    # 计算进度百分比
    percentage = int(current * 100 / total)
    # 计算进度条填充的长度
    progress = int(current * width / total)
    # 生成进度条字符串
    bar = "=" * progress
    # 显示进度条和百分比
    print(f"\r[{bar:<{width}}] {current}/{total} {percentage}%", end="", flush=True)


def scan_cpp_files():
    """扫描当前目录下的所有cpp文件"""
    import glob
    return glob.glob("*.cpp")

# 移除了旧的select_file函数，使用fzf.py替代

def get_user_input(prompt, default_value):
    """获取用户输入，提供默认值"""
    user_input = input(f"{prompt} (默认: {default_value}): ").strip()
    return user_input if user_input else default_value

def main():
    """主函数"""
    global TOTAL_COUNT, COMPARE_DIR, DATA_CODE, USR_CODE, STD_CODE
    global USR_PROGRAM, STD_PROGRAM, DATA_GENERATOR
    
    # 示例文本，用于帮助信息展示
    example_text = '''example:
  duipai.py
  duipai.py -n 100
  duipai.py -n 50 -d test_compare --data data.cpp --user sol.cpp --std std.cpp'''

    # 解析命令行参数
    parser = argparse.ArgumentParser(
        description="对拍工具 - 自动生成数据并对比两个程序的输出",
        epilog=example_text,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-n", "--count", type=int, default=0, 
                        help="对拍次数，默认200次")
    parser.add_argument("-d", "--dir", default="",
                        help="比较目录，默认为compare")
    parser.add_argument("--data", default=DATA_CODE,
                        help="数据生成程序源码")
    parser.add_argument("--user", default=USR_CODE,
                        help="用户程序源码")
    parser.add_argument("--std", default=STD_CODE,
                        help="标准程序源码")
    
    args = parser.parse_args()
    
    # 获取对拍次数，如果命令行参数没有提供，则交互式输入
    if args.count > 0:
        TOTAL_COUNT = args.count
    else:
        total_count_input = get_user_input("请输入对拍次数", "200")
        try:
            TOTAL_COUNT = int(total_count_input)
        except ValueError:
            print("错误: 对拍次数必须是数字")
            sys.exit(1)
    
    # 获取比较目录，如果命令行参数没有提供，则交互式输入
    if args.dir:
        COMPARE_DIR = args.dir
    else:
        COMPARE_DIR = get_user_input("请输入比较目录", "compare")
    
    # 如果命令行参数没有提供，则扫描目录让用户通过fzf选择
    cpp_files = scan_cpp_files()
    
    if args.data:
        DATA_CODE = args.data
    else:
        print("请选择数据生成程序源码:")
        DATA_CODE = fzf.select_with_fzf(cpp_files)
        if DATA_CODE is None:
            print("未选择数据生成程序源码")
            sys.exit(1)
    
    if args.user:
        USR_CODE = args.user
    else:
        print("请选择用户程序源码:")
        USR_CODE = fzf.select_with_fzf(cpp_files)
        if USR_CODE is None:
            print("未选择用户程序源码")
            sys.exit(1)
    
    if args.std:
        STD_CODE = args.std
    else:
        print("请选择标准程序源码:")
        STD_CODE = fzf.select_with_fzf(cpp_files)
        if STD_CODE is None:
            print("未选择标准程序源码")
            sys.exit(1)
    
    # 检查是否选择了所有必需的文件
    if not all([DATA_CODE, USR_CODE, STD_CODE]):
        print("错误: 必须选择所有程序源码文件")
        sys.exit(1)
    
    # 初始化程序变量
    global USR_PROGRAM, STD_PROGRAM, DATA_GENERATOR
    USR_PROGRAM = f"{USR_CODE.split('.')[0]}.out"
    STD_PROGRAM = f"{STD_CODE.split('.')[0]}.out"
    DATA_GENERATOR = f"{DATA_CODE.split('.')[0]}.out"
    
    # 编译程序
    compile_if_newer(USR_CODE, USR_PROGRAM)
    compile_if_newer(STD_CODE, STD_PROGRAM)
    compile_if_newer(DATA_CODE, DATA_GENERATOR)
    
    # 创建比较目录
    os.makedirs(COMPARE_DIR, exist_ok=True)
    
    # 对拍循环
    show_progress(TOTAL_COUNT, 0)
    for i in range(1, TOTAL_COUNT + 1):
        # 生成测试数据
        try:
            with open(f"{BASE_DIR}/in", "w") as infile:
                subprocess.run([f"./{DATA_GENERATOR}"], stdout=infile, check=True)
        except subprocess.CalledProcessError:
            print(f"\n生成测试数据失败，第 {i} 次")
            sys.exit(1)
        
        # 运行用户程序
        try:
            with open(f"{BASE_DIR}/in", "r") as infile, open(f"{BASE_DIR}/user_out", "w") as userout:
                subprocess.run([f"./{USR_PROGRAM}"], stdin=infile, stdout=userout, stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError:
            print(f"\n运行用户程序失败，第 {i} 次")
            sys.exit(1)
        
        # 运行标准程序
        try:
            with open(f"{BASE_DIR}/in", "r") as infile, open(f"{BASE_DIR}/std_out", "w") as stdout:
                subprocess.run([f"./{STD_PROGRAM}"], stdin=infile, stdout=stdout, stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError:
            print(f"\n运行标准程序失败，第 {i} 次")
            sys.exit(1)
        
        # 比较输出结果
        try:
            result = subprocess.run(["diff", "-b", "-q", f"{BASE_DIR}/user_out", f"{BASE_DIR}/std_out"], 
                                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if result.returncode != 0:
                # 如果diff出错
                print()  # 换行
                print(f"diff出错，第 {i} 次")
                # 复制输入文件到比较目录
                shutil.copy(f"{BASE_DIR}/in", f"{COMPARE_DIR}/in")
                # 使用vimdiff进行比较
                subprocess.run(["vimdiff", f"{BASE_DIR}/user_out", f"{BASE_DIR}/std_out"])
                # 清理临时文件
                os.remove(f"{BASE_DIR}/user_out")
                os.remove(f"{BASE_DIR}/std_out")
                sys.exit(1)
        except Exception as e:
            print(f"\n比较输出时出错: {e}")
            sys.exit(1)
        
        # 更新进度条
        show_progress(TOTAL_COUNT, i)
    
    # 清理临时文件
    try:
        os.remove(f"{BASE_DIR}/user_out")
        os.remove(f"{BASE_DIR}/std_out")
    except FileNotFoundError:
        pass
    
    print()  # 换行
    print("对拍完成，所有测试通过!")


if __name__ == "__main__":
    main()