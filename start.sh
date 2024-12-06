#!/bin/sh

# 启动 mosdns 并在后台运行，保存 PID
/usr/bin/mosdns start --dir /etc/mosdns &
MOSDNS_PID=$!
echo $MOSDNS_PID > /app/mosdns.pid

# 启动 crond 并在后台运行
crond -l 0 &

# 捕获退出信号，优雅地停止 mosdns 和 crond
trap "kill $MOSDNS_PID; exit 0" SIGTERM SIGINT

# 等待 mosdns 进程结束，保持脚本运行
wait $MOSDNS_PID