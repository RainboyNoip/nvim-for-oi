#!/usr/bin/env python3
"""
洛谷题目样例数据下载器
使用方法: python luogu.py 1000
会自动下载对应题目的样例数据，保存为 in1, in2 ... 和 out1, out2 ...
"""

import sys
import urllib.request
import urllib.error
import http.cookiejar
import json
import re
import os
import gzip
import subprocess

# 添加 gum 模块路径
sys.path.append(os.path.join(os.path.dirname(__file__), 'mylib'))
try:
    from gum import input as gum_input
except ImportError:
    print("警告: 无法导入 gum 模块，将使用普通 input()")
    gum_input = None

class Luogu:
    def __init__(self):
        self.base_url = "https://www.luogu.com.cn/problem"
    
    def get_problem_id(self, id_str):
        """处理题目ID，确保格式正确"""
        id_str = str(id_str).strip()
        if re.match(r'^\d', id_str):
            return f'P{id_str}'
        return id_str
    
    def http(self, id_str):
        """获取题目数据"""
        real_id = self.get_problem_id(id_str)
        url = f"{self.base_url}/{real_id}"
        
        print(f"正在获取题目: {real_id}")
        print(f"URL: {url}")
        
        # 首先尝试使用urllib
        result = self._http_urllib(url)
        if result is not None:
            return result
            
        # 如果urllib失败，尝试使用curl命令
        print("urllib请求失败，尝试使用curl命令...")
        return self._http_curl(url)
    
    def _http_urllib(self, url):
        """使用urllib获取题目数据"""
        try:
            # 1. 创建一个 CookieJar 对象来存储 cookie
            cookie_jar = http.cookiejar.CookieJar()

            # 2. 创建一个 HTTPCookieProcessor 处理器，传入 CookieJar 对象
            cookie_handler = urllib.request.HTTPCookieProcessor(cookie_jar)

            # 3. 创建一个支持重定向和Cookie的opener
            opener = urllib.request.build_opener(cookie_handler, urllib.request.HTTPRedirectHandler())

            # 4. 安装为全局 opener
            urllib.request.install_opener(opener)

            # 设置请求头
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language': 'zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3',
                'Accept-Encoding': 'gzip, deflate',
                'Connection': 'keep-alive',
                'Upgrade-Insecure-Requests': '1',
            }
            
            # 创建请求对象
            req = urllib.request.Request(url, headers=headers)
            
            # 发送请求
            response = urllib.request.urlopen(req, timeout=15)
            
            # 读取响应内容
            raw_content = response.read()
            
            # 检查内容是否被gzip压缩
            if response.headers.get('Content-Encoding') == 'gzip':
                # 解压缩gzip内容
                html_content = gzip.decompress(raw_content).decode('utf-8')
            else:
                # 直接解码
                html_content = raw_content.decode('utf-8')
            
            # 查找包含题目数据的script标签
            # 查找 <script id="lentille-context" type="application/json"> 标签
            pattern = r'<script id="lentille-context"[^>]*type="application/json"[^>]*>(.*?)</script>'
            match = re.search(pattern, html_content, re.DOTALL)
            
            if match:
                json_content = match.group(1)
                # 处理可能的HTML转义字符
                json_content = json_content.replace('\\', '\\\\')  # 先处理反斜杠
                json_content = json_content.replace('\\"', '"')    # 处理转义的双引号
                
                # 在JSON解析之前解码Unicode转义字符
                json_content = json_content.encode().decode('unicode-escape')
                
                parsed_data = json.loads(json_content)
                return parsed_data.get('data', {})
            else:
                # 如果找不到lentille-context，尝试其他方法
                print("未找到lentille-context脚本标签，尝试其他解析方法...")
                # 尝试查找其他可能包含数据的模式
                return self._extract_data_alternative(html_content)
                
        except urllib.error.HTTPError as e:
            print(f"HTTP错误: {e.code} - {e.reason}")
            if e.code == 403:
                print("可能是被反爬虫机制拦截，请稍后再试")
            return None
        except urllib.error.URLError as e:
            print(f"网络请求错误: {e}")
            print("请检查网络连接或稍后再试")
            return None
        except json.JSONDecodeError as e:
            print(f"JSON解析错误: {e}")
            return None
        except Exception as e:
            print(f"urllib请求失败: {e}")
            return None
    
    def _http_curl(self, url):
        """使用curl命令获取题目数据"""
        try:
            
            # 构造curl命令，直接输出到标准输出
            # 使用 --compressed 参数自动处理gzip压缩
            curl_cmd = [
                'curl',
                '-H', 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                '--connect-timeout', '15',
                '--max-time', '30',
                '--retry', '2',
                '--retry-delay', '1',
                '-L',  # 跟随重定向
                '--compressed',  # 自动处理gzip压缩
                url
            ]
            
            print("执行curl命令:", ' '.join(curl_cmd))
            result = subprocess.run(curl_cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                # 直接使用curl的输出
                html_content = result.stdout
                
                # 查找包含题目数据的script标签
                pattern = r'<script id="lentille-context"[^>]*type="application/json"[^>]*>(.*?)</script>'
                match = re.search(pattern, html_content, re.DOTALL)
                
                if match:
                    json_content = match.group(1)
                    # 处理可能的HTML转义字符
                    json_content = json_content.replace('\\', '\\\\')  # 先处理反斜杠
                    json_content = json_content.replace('\\"', '"')    # 处理转义的双引号
                    
                    # 在JSON解析之前解码Unicode转义字符
                    json_content = json_content.encode().decode('unicode-escape')
                    
                    parsed_data = json.loads(json_content)
                    return parsed_data.get('data', {})
                else:
                    print("curl获取的内容中未找到lentille-context脚本标签")
                    return None
            else:
                print(f"curl命令执行失败: {result.stderr}")
                return None
                
        except Exception as e:
            print(f"curl请求失败: {e}")
            return None
    
    def _extract_data_alternative(self, html_content):
        """备用数据提取方法"""
        # 尝试查找其他可能包含题目信息的模式
        # 查找题目标题
        title_pattern = r'<title>(.*?)</title>'
        title_match = re.search(title_pattern, html_content)
        title = title_match.group(1) if title_match else "未知题目"
        
        # 查找题目描述（简化版）
        desc_pattern = r'<meta name="description" content="(.*?)"'
        desc_match = re.search(desc_pattern, html_content)
        description = desc_match.group(1) if desc_match else ""
        
        # 构造一个基本的数据结构
        return {
            "problem": {
                "title": title,
                "description": description,
                "samples": []  # 这里无法提取样例数据
            }
        }
    
    def download_samples(self, id_str):
        """下载样例数据并保存到文件"""
        data = self.http(id_str)
        
        if not data:
            print("无法获取题目数据")
            return False
        
        problem = data.get('problem', {})
        samples = problem.get('samples', [])
        
        if not samples:
            print("未找到样例数据")
            # 尝试从HTML中直接提取样例数据
            print("尝试从HTML中直接提取样例数据...")
            return self._extract_samples_from_html(id_str)
        
        print(f"找到 {len(samples)} 组样例数据")
        
        # 保存样例数据到文件
        for i, sample in enumerate(samples, 1):
            # 检查sample的类型
            if isinstance(sample, dict):
                # 样本是字典格式
                input_data = sample.get('input', '')
                output_data = sample.get('output', '')
            elif isinstance(sample, (list, tuple)) and len(sample) >= 2:
                # 样本是列表或元组格式
                input_data = sample[0]
                output_data = sample[1]
            else:
                # 未知格式，跳过
                print(f"警告: 第{i}个样本格式未知，跳过")
                continue
            
            # 保存输入数据
            input_filename = f"in{i}"
            with open(input_filename, 'w', encoding='utf-8') as f:
                f.write(input_data)
            print(f"已保存输入数据到: {input_filename}")
            
            # 保存输出数据
            output_filename = f"out{i}"
            with open(output_filename, 'w', encoding='utf-8') as f:
                f.write(output_data)
            print(f"已保存输出数据到: {output_filename}")
        
        return True
    
    def _extract_samples_from_html(self, id_str):
        """从HTML中直接提取样例数据"""
        real_id = self.get_problem_id(id_str)
        url = f"{self.base_url}/{real_id}"
        
        # 设置请求头
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        try:
            # 创建请求对象
            req = urllib.request.Request(url, headers=headers)
            
            # 发送请求
            with urllib.request.urlopen(req) as response:
                html_content = response.read().decode('utf-8')
            
            # 尝试从HTML中提取样例数据
            # 查找样例输入输出
            sample_pattern = r'<h3>样例\s*输入\s*#(\d+)</h3>\s*<pre[^>]*>(.*?)</pre>.*?<h3>样例\s*输出\s*#\1</h3>\s*<pre[^>]*>(.*?)</pre>'
            samples = re.findall(sample_pattern, html_content, re.DOTALL)
            
            if not samples:
                # 尝试另一种模式
                sample_pattern = r'输入\s*#(\d+).*?<pre[^>]*>(.*?)</pre>.*?输出\s*#\1.*?<pre[^>]*>(.*?)</pre>'
                samples = re.findall(sample_pattern, html_content, re.DOTALL)
            
            if not samples:
                # 尝试更简单的模式
                input_pattern = r'<h3>样例输入\s*#(\d+)</h3>\s*<pre[^>]*>(.*?)</pre>'
                output_pattern = r'<h3>样例输出\s*#(\d+)</h3>\s*<pre[^>]*>(.*?)</pre>'
                
                inputs = re.findall(input_pattern, html_content, re.DOTALL)
                outputs = re.findall(output_pattern, html_content, re.DOTALL)
                
                # 尝试匹配输入输出对
                samples = []
                for i, inp in enumerate(inputs):
                    if i < len(outputs):
                        samples.append((inp[0], inp[1], outputs[i][1]))
            
            if samples:
                print(f"从HTML中找到 {len(samples)} 组样例数据")
                
                # 保存样例数据到文件
                for i, sample in enumerate(samples, 1):
                    # 清理HTML实体
                    input_data = self._clean_html_entities(sample[1].strip())
                    output_data = self._clean_html_entities(sample[2].strip())
                    
                    # 保存输入数据
                    input_filename = f"in{i}"
                    with open(input_filename, 'w', encoding='utf-8') as f:
                        f.write(input_data)
                    print(f"已保存输入数据到: {input_filename}")
                    
                    # 保存输出数据
                    output_filename = f"out{i}"
                    with open(output_filename, 'w', encoding='utf-8') as f:
                        f.write(output_data)
                    print(f"已保存输出数据到: {output_filename}")
                
                return True
            else:
                print("无法从HTML中提取样例数据")
                return False
                
        except Exception as e:
            print(f"提取样例数据时出错: {e}")
            return False
    
    def _clean_html_entities(self, text):
        """清理HTML实体"""
        # 替换常见的HTML实体
        import html
        # 先使用html.unescape处理标准HTML实体
        text = html.unescape(text)
        
        # 移除可能的HTML标签
        text = re.sub(r'<[^>]+>', '', text)
        
        return text

def main():
    # 检查是否提供了题目ID参数
    if len(sys.argv) < 2:
        # 如果没有提供参数，使用 gum.input 或普通 input 获取题目ID
        if gum_input:
            problem_id = gum_input(
                placeholder="请输入题目ID (例如: 1001 或 B3634)",
                prompt="题目ID: "
            )
        else:
            problem_id = input("请输入题目ID (例如: 1001 或 B3634): ")
        
        # 如果用户没有输入任何内容，则退出
        if not problem_id.strip():
            print("未输入题目ID，程序退出。")
            sys.exit(1)
    else:
        problem_id = sys.argv[1]
    
    # 创建洛谷对象并下载样例数据
    luogu = Luogu()
    success = luogu.download_samples(problem_id)
    
    if success:
        print("样例数据下载完成!")
    else:
        print("样例数据下载失败!")
        sys.exit(1)

if __name__ == "__main__":
    main()
