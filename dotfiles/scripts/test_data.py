#!/usr/bin/env python3
"""
对目录下的数据进行简单的 diff 评测

使用方法:
test_data.py 1 data
用1测试 data下的所有数据

# 基本用法
python test_data.py 1.out data

# 使用完整路径
python test_data.py -p ./solution data

# 指定输出文件
python test_data.py --output result.txt 1.out data

# 查看帮助
python test_data.py -h
"""

import os
import subprocess
import sys
import time
import argparse
from pathlib import Path

# 导入getDataList模块
from mylib.getDataList import get_data_list

def run_test(main_program, data_path, result_out_path='test_out'):
    """
    运行测试程序并比较结果
    
    Args:
        main_program (str): 要测试的程序名称
        data_path (str): 数据目录路径
        result_out_path (str): 结果输出文件路径
    """
    
    # 检查主程序是否存在
    if not os.path.exists(main_program):
        # 如果没有指定路径分隔符，尝试添加 ./ 前缀
        if not os.path.sep in main_program:
            main_program = f"./{main_program}"
        
        if not os.path.exists(main_program):
            print(f"错误: 找不到程序 '{main_program}'")
            sys.exit(1)
    
    # 获取数据列表
    try:
        data_info = get_data_list(data_path)
        data_list = data_info['both_list']
    except FileNotFoundError as e:
        print(f"错误: {e}")
        sys.exit(1)
    
    if not data_list:
        print(f"在目录 '{data_path}' 中未找到匹配的输入输出文件")
        sys.exit(0)
    
    print(f"找到 {len(data_list)} 组测试数据")
    print(f"测试程序: {main_program}")
    print(f"数据目录: {data_path}")
    print("-" * 50)
    
    # 统计变量
    success_count = 0
    
    # 遍历所有数据文件进行测试
    for i, item in enumerate(data_list, 1):
        _in = os.path.join(data_path, item[0])
        _out = os.path.join(data_path, item[1])
        msg = f"测试 {i}/{len(data_list)}: {_in} <-> {_out}"
        
        # 记录开始时间
        start_time = time.time()
        
        try:
            # 运行主程序，重定向输入输出
            with open(_in, 'r') as inf, open(result_out_path, 'w') as outf:
                subprocess.run([main_program], stdin=inf, stdout=outf, stderr=subprocess.DEVNULL, check=True)
            
            # 计算执行时间
            elapsed_time = time.time() - start_time
            
            # 使用diff命令比较输出结果
            diff_result = subprocess.run(['diff', '--strip-trailing-cr', result_out_path, _out], 
                                       capture_output=True, text=True)
            
            if diff_result.returncode == 0:
                # 输出成功信息和执行时间
                print(f"{msg} 通过 ({elapsed_time:.3f}s)")
                success_count += 1
            else:
                # 输出失败信息和diff结果
                print(f"{msg} 失败 ({elapsed_time:.3f}s)")
                print("输出差异:")
                print(diff_result.stdout)
                if diff_result.stderr:
                    print(diff_result.stderr)
                break
                
        except subprocess.CalledProcessError as e:
            # 输出错误信息
            elapsed_time = time.time() - start_time
            print(f"{msg} 执行失败 ({elapsed_time:.3f}s)")
            if e.stderr:
                print(e.stderr.decode('utf-8'))
            break
        except Exception as e:
            # 输出其他异常信息
            elapsed_time = time.time() - start_time
            print(f"{msg} 发生异常 ({elapsed_time:.3f}s)")
            print(f"错误信息: {e}")
            break
    
    # 输出测试结果统计
    print("-" * 50)
    print(f"测试完成: {success_count}/{len(data_list)} 个测试通过")
    
    # 清理临时文件
    if os.path.exists(result_out_path):
        try:
            os.remove(result_out_path)
        except Exception:
            pass
    
    return success_count == len(data_list)

def main():
    """主函数"""
    # 创建命令行参数解析器
    parser = argparse.ArgumentParser(
        description="对目录下的数据进行简单的 diff 评测",
        epilog="""使用示例:
  python test_data.py 1.out data        # 用1.out测试data目录下的数据
  python test_data.py -p ./sol data     # 用./sol程序测试data目录下的数据
  python test_data.py --program sol --data-path test_data""",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    # 添加命令行参数
    parser.add_argument(
        'program',
        help='要测试的程序名称(默认为1.out)',
        nargs='?',
        default='1.out'
    )
    
    parser.add_argument(
        'data_path',
        help='数据目录路径(默认为data)',
        nargs='?',
        default='data'
    )
    
    parser.add_argument(
        '-o', '--output',
        help='结果输出文件路径(默认为test_out)',
        default='test_out'
    )
    
    parser.add_argument(
        '-p', '--program-path',
        help='程序完整路径',
        dest='program'
    )
    
    parser.add_argument(
        '--data-path',
        help='数据目录路径'
    )
    
    # 解析命令行参数
    args = parser.parse_args()
    
    # 处理参数优先级
    program = args.program_path if args.program_path else args.program
    data_path = args.data_path if args.data_path else args.data_path
    
    # 运行测试
    success = run_test(program, data_path, args.output)
    
    # 根据测试结果设置退出码
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()