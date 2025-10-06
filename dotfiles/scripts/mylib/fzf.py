import subprocess
import shutil

def select_with_fzf(options):
    """
    使用 fzf 从列表中选择一个选项。

    Args:
        options (list): 供选择的字符串列表。

    Returns:
        str: 用户选择的选项。如果用户取消选择 (例如按 Esc 或 Ctrl+C)，
             则返回 None。
    """
    # 1. 检查 fzf 是否已安装
    if not shutil.which("fzf"):
        print("错误: fzf 命令未找到。请先安装 fzf。")
        print("安装指南: https://github.com/junegunn/fzf#installation")
        return None

    # 2. 将选项列表转换为 fzf 需要的输入格式（每行一个）
    #    确保列表中的每个元素都是字符串
    options_str = "\n".join(map(str, options))

    try:
        # 3. 调用 fzf 进程
        #    - input: 将字符串传递给 fzf 的 stdin
        #    - capture_output=True: 捕获 stdout 和 stderr
        #    - text=True: 以文本模式（自动编码/解码）处理输入和输出
        #    - check=True: 如果 fzf 返回非零退出码（例如用户取消），则会引发 CalledProcessError
        result = subprocess.run(
            ['fzf'],
            input=options_str,
            capture_output=True,
            text=True,
            check=True
        )
        
        # 4. fzf 的输出会包含一个换行符，使用 strip() 清除它
        return result.stdout.strip()

    except subprocess.CalledProcessError:
        # 5. 如果用户在 fzf 中按下了 Esc 或 Ctrl+C，fzf 会以非零状态码退出
        #    此时 subprocess.run 会因为 check=True 而抛出异常。
        #    我们捕获这个异常，并将其视为“无选择”。
        return None
