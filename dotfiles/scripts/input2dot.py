#!/usr/bin/env python3
"""
将多行数据转换成对应的dot图形描述语言

功能说明:
    将文本格式的图数据转换为Graphviz的dot语言格式，便于生成图形可视化

输入格式:
    每行包含节点和可选的边权重:
    - "1 2 3" 表示节点1和节点2之间有一条权重为3的边
    - "1 2" 表示节点1和节点2之间有一条无权重的边

输出格式:
    无向图示例:
        1--2[label="3"];
        1--2[label="3"];
        1--2;
        1--2[label="3"];
        1--2;

    有向图示例(-d参数):
        1->2[label="3"];
        1->2[label="3"];
        1->2;
        1->2[label="3"];
        1->2;

使用示例:
    cat data.txt | input2dot.py > output.dot
    cat data.txt | input2dot.py -d > output.dot
"""

import sys
import argparse

exampe_text = '''生成无向图
cat data.txt | input2dot.py > output.dot

生成有向图
cat data.txt | input2dot.py -d > output.dot

查看帮助
input2dot.py -h

生成的dot文件可以使用Graphviz工具进一步转换为PNG等图像格式：
dot -Tpng output.dot -o output.png

也可以配合 dot2png.py 使用：
cat data.txt | input2dot.py | dot2png.py
'''

def main():
    """主函数"""
    # 创建命令行参数解析器
    parser = argparse.ArgumentParser(
        description="将文本格式的图数据转换为Graphviz的dot语言格式",
        epilog=exampe_text,
        formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument('-d', '--directed', action="store_true", help="生成有向图(默认为无向图)")
    args = parser.parse_args()

    # 定义dot语言模板
    # graph: 无向图; digraph: 有向图
    # node: 设置节点样式(圆形、固定大小、填充白色、使用accent8配色方案)
    template = '''{graph_type} g {{
    node[shape=circle fixedsize=true style=filled fillcolor=white colorscheme=accent8];
    {content}
}}'''

    # 存储生成的边内容
    content = "" 

    # 从标准输入读取所有行
    lines = sys.stdin.readlines()
    
    # 处理每一行数据
    for line in lines:
        # 跳过空行
        if line.strip() == "":
            continue
            
        # 按空格分割行数据
        parts = line.split()
        
        # 根据数据长度生成不同的边描述
        if len(parts) >= 3:
            # 三个或更多元素: 起点 终点 权重
            # 生成带标签的边: 节点1--节点2[label="权重"];
            content += ("{}--{}[label=\"{}\"];\n".format(parts[0], parts[1], parts[2]))
        else:
            # 两个元素: 起点 终点
            # 生成无标签的边: 节点1--节点2;
            content += ("{}--{};\n".format(parts[0], parts[1]))

    # 根据参数决定生成有向图还是无向图
    if args.directed:
        # 有向图: 将无向边符号"--"替换为有向边符号"->"
        content = content.replace("--", "->")
        graph_type = "digraph"
    else:
        # 无向图
        graph_type = "graph"

    # 输出最终的dot格式内容
    print(template.format(graph_type=graph_type, content=content))

# 程序入口点
if __name__ == "__main__":
    main()

