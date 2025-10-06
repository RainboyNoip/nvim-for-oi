## 安装依赖
```bash
sudo apt install -y python3 fzf graphviz clangd
```

# 配置

## tmux

使用了 [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

安装

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```


Installing plugins

1.  Add new plugin to `~/.tmux.conf` with `set -g @plugin '...'`
2.  Press `prefix` + I (capital i, as in **I**nstall) to fetch the plugin.

- [Tmux 快捷键速查表](https://blog.roj.ac.cn/blog/tmux%E5%B8%B8%E7%94%A8%E5%BF%AB%E6%8D%B7%E9%94%AE.html)

## 脚本使用

### transfer.sh

通过命令行上传分享代码[github](https://github.com/dutchcoders/transfer.sh)

编辑配置文件 (以 `~/.bashrc` 为例):

```bash
echo 'export TRANSFER_URL="http:// your-transfer-sh-url"' >> ~/.bashrc
```