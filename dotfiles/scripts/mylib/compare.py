#!/usr/bin/env python3
"""
比较结果
"""

import os
import subprocess
import sys

from .getDataList import get_data_list

def diff(__in, file1, file2):
    """
    比较两个文件是否相同
    :param __in: 输入文件路径（未使用，保持接口一致）
    :param file1: 标准输出文件路径
    :param file2: 程序输出文件路径
    :return: 1表示相同，0表示不同
    """
    try:
        # 使用diff命令比较文件，忽略行尾空格差异
        subprocess.run(["diff", "--strip-trailing-cr", file1, file2], check=True, capture_output=True)
        return 1
    except subprocess.CalledProcessError:
        return 0
    except Exception as e:
        return 0


def run(time, exe, in_file, out):
    """
    运行程序并重定向输入输出
    :param time: 超时时间（秒）
    :param exe: 可执行文件路径
    :param in_file: 输入文件路径
    :param out: 输出文件路径
    :return: 1表示成功，0表示超时或失败
    """
    try:
        # 使用timeout命令运行程序
        subprocess.run(["timeout", str(time), exe], 
                      stdin=open(in_file, 'r'), 
                      stdout=open(out, 'w'), 
                      stderr=subprocess.DEVNULL, 
                      check=True)
        return 1
    except subprocess.CalledProcessError:
        return 0
    except Exception as e:
        return 0

def compare(exe_path, data_dir, time=1):
    """
    比较程序执行结果
    :param exe_path: 可执行文件路径
    :param data_dir: 数据目录
    :param time: 超时时间（秒），默认为1秒
    :return: 结果列表，包含'AC'、'WA'、'TLE'等结果
    """
    # 获取数据列表
    data_info = get_data_list(data_dir)
    in_list = data_info['in_list']
    out_list = data_info['out_list']
    both_list = data_info['both_list']
    count = data_info['count']
    
    results = []
    
    for i in range(count):
        in_file, out_file = both_list[i]
        __in = os.path.join(data_dir, in_file)
        file1 = os.path.join(data_dir, out_file)
        file2 = 'out'
        
        # 运行程序
        if run(time, exe_path, __in, file2) == 0:
            # 超时
            results.append('TLE')
            continue
        
        # 比较输出结果
        if diff(__in, file1, file2) == 0:
            # 答案错误
            results.append('WA')
            continue
        
        # 答案正确
        results.append('AC')
    
    return results


# 如果直接运行此脚本，则解析命令行参数并执行比较
# python compare.py <可执行文件路径> <数据目录> [超时时间]
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("用法: python compare.py <可执行文件路径> <数据目录> [超时时间]")
        sys.exit(1)
    
    exe_path = sys.argv[1]
    data_dir = sys.argv[2]
    time = int(sys.argv[3]) if len(sys.argv) > 3 else 1
    
    results = compare(exe_path, data_dir, time)
    
    # 输出结果统计
    ac_count = results.count('AC')
    wa_count = results.count('WA')
    tle_count = results.count('TLE')
    
    print(f"总测试数: {len(results)}")
    print(f"通过 (AC): {ac_count}")
    print(f"错误 (WA): {wa_count}")
    print(f"超时 (TLE): {tle_count}")
    
    # 详细结果
    print("\n详细结果:")
    for i, result in enumerate(results):
        print(f"测试 {i+1}: {result}")
