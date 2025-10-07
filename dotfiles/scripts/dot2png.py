#!/usr/bin/env python3
"""
将dot文件转换为PNG图像文件

功能说明:
    批量将Graphviz的dot格式文件转换为PNG图像文件
    支持指定输入目录和输出目录

使用示例:
    python dot2png.py                    # 转换当前目录下的所有dot文件
    python dot2png.py /path/to/dots      # 转换指定目录下的所有dot文件
    python dot2png.py -O /path/to/output # 指定输出目录
"""

import argparse
import os
import subprocess
import glob
import sys

def list_dots(directory):
    """
    列出指定目录下的所有dot文件
    
    Args:
        directory (str): 要搜索的目录路径
        
    Returns:
        list: dot文件路径列表
    """
    return glob.glob(os.path.join(directory, '*.dot'))

def convert_dot_content_to_png(dot_content, output_file):
    """
    将dot内容转换为PNG文件
    
    Args:
        dot_content (str): dot格式的内容
        output_file (str): 输出PNG文件路径
        
    Returns:
        bool: 转换是否成功
    """
    try:
        # 使用subprocess将dot内容通过stdin传递给dot命令
        result = subprocess.run(
            ['dot', '-Tpng', '-o', output_file],
            input=dot_content,
            capture_output=True,
            text=True,
            check=True
        )
        
        print(f"成功转换内容到: {output_file}")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"转换失败: {output_file}")
        print(f"错误信息: {e.stderr}")
        return False
    except FileNotFoundError:
        print("错误: 未找到dot命令，请确保已安装Graphviz")
        return False
    except Exception as e:
        print(f"转换过程中发生错误: {output_file}")
        print(f"错误信息: {str(e)}")
        return False

def convert_dot_file_to_png(dot_file, output_dir):
    """
    将单个dot文件转换为PNG文件
    
    Args:
        dot_file (str): dot文件路径
        output_dir (str): 输出目录路径
        
    Returns:
        bool: 转换是否成功
    """
    try:
        # 构建输出文件路径
        base_name = os.path.splitext(os.path.basename(dot_file))[0]
        output_file = os.path.join(output_dir, base_name + '.png')
        
        # 使用subprocess替代os.system，更安全且能捕获错误
        result = subprocess.run(
            ['dot', '-Tpng', '-o', output_file, dot_file],
            capture_output=True,
            text=True,
            check=True
        )
        
        print(f"成功转换: {dot_file} -> {output_file}")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"转换失败: {dot_file}")
        print(f"错误信息: {e.stderr}")
        return False
    except FileNotFoundError:
        print("错误: 未找到dot命令，请确保已安装Graphviz")
        return False
    except Exception as e:
        print(f"转换过程中发生错误: {dot_file}")
        print(f"错误信息: {str(e)}")
        return False

def main():
    """主函数"""
    # 检查是否从管道接收输入
    if not sys.stdin.isatty():
        # 从标准输入读取dot内容
        dot_content = sys.stdin.read()
        if not dot_content.strip():
            print("错误: 标准输入为空")
            sys.exit(1)
        
        # 创建命令行参数解析器（管道模式下不需要输入路径参数）
        parser = argparse.ArgumentParser(
            description="将Graphviz的dot内容或文件转换为PNG图像文件",
            epilog="""使用示例:
  python dot2png.py                    # 转换当前目录下的所有dot文件
  python dot2png.py /path/to/dots      # 转换指定目录下的所有dot文件
  python dot2png.py -O /path/to/output # 指定输出目录
  cat file.dot | python dot2png.py -o output.png  # 管道模式""",
            formatter_class=argparse.RawDescriptionHelpFormatter
        )
        
        parser.add_argument(
            "-o", "--output",
            help="输出PNG文件路径(管道模式下必需)",
            type=str,
            default="output.png"
        )
        parser.add_argument(
            "-O", "--output_path",
            help="输出PNG文件的目录(默认为当前目录)",
            type=str,
            default="."
        )
        
        # 解析命令行参数
        args = parser.parse_args()
        
        # 确定输出文件路径
        if args.output:
            output_file = args.output
        else:
            output_file = os.path.join(args.output_path, "output.png")
        
        # 检查输出目录是否存在，不存在则创建
        output_dir = os.path.dirname(output_file) or "."
        if output_dir != "." and not os.path.exists(output_dir):
            try:
                os.makedirs(output_dir)
                print(f"创建输出目录: {output_dir}")
            except Exception as e:
                print(f"错误: 无法创建输出目录 '{output_dir}': {str(e)}")
                sys.exit(1)
        
        # 转换dot内容
        if convert_dot_content_to_png(dot_content, output_file):
            print(f"转换完成: 1/1 个文件成功转换")
        else:
            print("转换失败")
            sys.exit(1)
        
        return
    
    # 创建命令行参数解析器（文件模式）
    parser = argparse.ArgumentParser(
        description="将Graphviz的dot文件批量转换为PNG图像文件",
        epilog="""使用示例:
  python dot2png.py                    # 转换当前目录下的所有dot文件
  python dot2png.py /path/to/dots      # 转换指定目录下的所有dot文件
  python dot2png.py -O /path/to/output # 指定输出目录""",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    # 添加命令行参数
    parser.add_argument(
        "input_path",
        help="包含dot文件的输入目录(默认为当前目录)",
        type=str,
        default=".",
        nargs="?"
    )
    parser.add_argument(
        "-O", "--output_path",
        help="输出PNG文件的目录(默认为当前目录)",
        type=str,
        default="."
    )
    
    # 解析命令行参数
    args = parser.parse_args()
    
    # 检查输入目录是否存在
    if not os.path.exists(args.input_path):
        print(f"错误: 输入目录 '{args.input_path}' 不存在")
        sys.exit(1)
    
    # 检查输出目录是否存在，不存在则创建
    if not os.path.exists(args.output_path):
        try:
            os.makedirs(args.output_path)
            print(f"创建输出目录: {args.output_path}")
        except Exception as e:
            print(f"错误: 无法创建输出目录 '{args.output_path}': {str(e)}")
            sys.exit(1)
    
    # 获取所有dot文件
    dot_files = list_dots(args.input_path)
    
    # 检查是否有dot文件
    if not dot_files:
        print(f"在目录 '{args.input_path}' 中未找到dot文件")
        sys.exit(0)
    
    print(f"找到 {len(dot_files)} 个dot文件")
    print(f"输入目录: {args.input_path}")
    print(f"输出目录: {args.output_path}")
    print("-" * 50)
    
    # 转换每个dot文件
    success_count = 0
    for dot_file in dot_files:
        if convert_dot_file_to_png(dot_file, args.output_path):
            success_count += 1
    
    # 输出转换结果统计
    print("-" * 50)
    print(f"转换完成: {success_count}/{len(dot_files)} 个文件成功转换")

if __name__ == "__main__":
    main()


