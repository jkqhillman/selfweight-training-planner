#!/bin/zsh
# 双击此文件启动本地训练应用；关闭终端窗口即可停止服务。
cd "$(dirname "$0")"
PORT=4174
python3 -m http.server "$PORT" --bind 127.0.0.1 &
server_pid=$!
sleep 1
open "http://127.0.0.1:$PORT/?v=19"
wait $server_pid
