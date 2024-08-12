#!/bin/bash

# 代理地址和端口
PROXY_HOST="asdasdasda.serv00.net"
PROXY_PORT="55563"

# SSH 登录信息
SSH_USER="dvdve"
SSH_HOST="s8.serv00.com"
SSH_PORT="22"
SSH_PASS='MaKaSibSey##FCpzZ1&a'

# 失败计数
FAILURE_COUNT=0
MAX_FAILURES=2

while true; do
    CURRENT_TIME=$(date +"%Y-%m-%d %H:%M")

    # 尝试连接到 SOCKS5 代理
    if nc -z -w 5 "$PROXY_HOST" "$PROXY_PORT"; then
        FAILURE_COUNT=0
        echo "代理正常运行。 当前时间: $CURRENT_TIME"
    else
        ((FAILURE_COUNT++))
        echo "代理无法访问！失败次数：$FAILURE_COUNT 当前时间: $CURRENT_TIME"
    fi

    # 如果失败次数超过最大值，则重启代理
    if [ $FAILURE_COUNT -ge $MAX_FAILURES ]; then
        echo "尝试在服务器上重启代理... 当前时间: $CURRENT_TIME"

        while true; do
            # 使用 SSH 登录并执行命令
            sshpass -p "$SSH_PASS" ssh -p "$SSH_PORT" -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST "
                cd /home/example/domains/example.serv00.net/logs &&
                wget -q https://github.com/go-gost/gost/releases/download/v3.0.0-nightly.20240731/gost_3.0.0-nightly.20240731_freebsd_amd64.tar.gz -O temp.tar.gz &&
                tar -xzf temp.tar.gz &&
                mv gost web &&
                ./web -L socks://test:test@:5328 -L relay+wss://:22921/127.0.0.1:5328 -O json > config.json &&
                (nohup ./web -C config.json > /dev/null 2>&1 &) &&
                sleep 2 &&
                rm web config.json temp.tar.gz LICENSE README.md README_en.md
            "
            SSH_EXIT_STATUS=$?

            if [ $SSH_EXIT_STATUS -eq 0 ]; then
                echo "代理在服务器上成功重启。 当前时间: $CURRENT_TIME"
                # 重置失败计数
                FAILURE_COUNT=0
                break
            elif [ $SSH_EXIT_STATUS -eq 5 ]; then
                echo "SSH 登录因认证错误失败。不再重试。 当前时间: $CURRENT_TIME"
                exit 1
            else
                echo "SSH 登录因网络或其他问题失败。将重试。 当前时间: $CURRENT_TIME"
                # 等待 1 分钟后重试
                sleep 60
            fi
        done
    fi

    # 等待 1 分钟
    sleep 60
done

