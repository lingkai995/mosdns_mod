#!/bin/sh

# 尝试从环境变量中读取代理地址
if [ -n "$PROXY" ]; then
    proxy="$PROXY"
elif [ -n "$proxy" ]; then
    proxy="$proxy"
else
    # 从文件中读取代理地址
    read -r proxy < /etc/mosdns/PROXY
fi

# 如果代理变量非空，则设置 curl 命令使用代理
if [ -n "$proxy" ]; then
	    CURL_COMMAND="curl --progress-bar --show-error -x $proxy -o"
    else
	    CURL_COMMAND="curl --progress-bar --show-error -o"
fi

echo '开始更新mosdns文件...'
echo '## 1. 更新apple-cn.txt'
$CURL_COMMAND /etc/mosdns/apple-cn.txt https://raw.githubusercontent.com/lingkai995/geoip/refs/heads/release/apple-cn.txt
echo '## 2. 更新china_ip_list.txt'
$CURL_COMMAND /etc/mosdns/china_ip_list.txt https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt
echo '## 3. 更新direct-list.txt'
$CURL_COMMAND /etc/mosdns/direct-list.txt https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt
echo '## 4. 更新proxy-list.txt'
$CURL_COMMAND /etc/mosdns/proxy-list.txt https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt
echo '## 5. 更新reject-list.txt'
$CURL_COMMAND /etc/mosdns/reject-list.txt https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt

echo 'mosdns文件更新完成!'
# 发送 SIGHUP 信号以重新加载配置
if [ -f /app/mosdns.pid ]; then
    mosdns_pid=$(cat /app/mosdns.pid)
    if kill -0 $mosdns_pid 2>/dev/null; then
        echo "Mosdns容器即将重启"
        kill -SIGHUP $mosdns_pid
    else
        echo "无法找到 mosdns 进程 (PID: $mosdns_pid)"
    fi
else
    echo "PID 文件不存在，无法发送 SIGHUP 信号"
fi

# 启动 mosdns
echo "重新启动 mosdns..."
/usr/bin/mosdns start --dir /etc/mosdns &
echo $! > /app/mosdns.pid

exit 0