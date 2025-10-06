#!/usr/bin/env python3
"""
获取数据列表
模拟JavaScript版本的getDataList功能
"""

import os
import re


def get_data_list(data_dir):
    """
    获取数据目录中的输入和输出文件列表
    :param data_dir: 数据目录路径
    :return: 包含in_list, out_list, both_list, count的字典
    """
    # 检查目录是否存在
    if not os.path.exists(data_dir):
        raise FileNotFoundError(f"数据目录 {data_dir} 不存在")
    
    # 获取目录中的所有文件
    files = os.listdir(data_dir)
    
    # 分别存储输入文件和输出文件
    in_list = []
    out_list = []
    
    # 根据文件扩展名分类文件
    for file in files:
        if file.endswith('.in'):
            in_list.append(file)
        elif file.endswith('.out') or file.endswith('.ans'):
            out_list.append(file)
    
    # 按文件名排序
    in_list.sort()
    out_list.sort()
    
    # 创建配对列表
    both_list = []
    
    # 尝试将输入文件和输出文件配对
    for in_file in in_list:
        # 尝试找到对应的输出文件
        base_name = in_file[:-3]  # 去掉.in后缀
        
        # 查找匹配的输出文件
        out_file = None
        for out_candidate in out_list:
            # 检查是否有相同前缀的输出文件
            if out_candidate.startswith(base_name):
                out_file = out_candidate
                break
        
        # 如果找到了匹配的输出文件，则添加到配对列表
        if out_file:
            both_list.append((in_file, out_file))
    
    # 如果没有成功配对，则尝试按顺序配对
    if not both_list and in_list and out_list:
        min_len = min(len(in_list), len(out_list))
        both_list = list(zip(in_list[:min_len], out_list[:min_len]))
    
    return {
        'in_list': in_list,
        'out_list': out_list,
        'both_list': both_list,
        'count': len(both_list)
    }