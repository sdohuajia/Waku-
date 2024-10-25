#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/Waku.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "================================================================"
        echo "节点社区 Telegram 群组: https://t.me/niuwuriji"
        echo "节点社区 Telegram 频道: https://t.me/niuwuriji"
        echo "节点社区 Discord 社群: https://discord.gg/GbMV5EcNWF"
        echo "退出脚本，请按键盘Ctrl+C退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装节点"
        echo "2. 修复错误（暂不可用，官方脚本有问题）"
        echo "3. 更新脚本"
        echo "4. 退出"
        read -rp "请输入操作选项：" choice

        case $choice in
            1)
                install_node
                ;;
            2)
                fix_errors
                ;;
            3)
                update_script
                ;;
            4)
                view_logs
                ;;
            5)
                echo "退出脚本！"
                exit 0
                ;;
            *)
                echo "无效的选择，请重新输入。"
                sleep 2
                ;;
        esac
    done
}

# 安装节点工具的函数
function install_node_tools() {
    # 更新软件源并升级系统软件
    sudo apt update && sudo apt upgrade -y

    # 安装必要的软件和工具
    sudo apt install -y curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev
}

# 安装 Docker 的函数
function install_docker() {
    # 检查 Docker 是否已安装
    if command -v docker &> /dev/null; then
        echo "Docker 已安装。"
    else
        echo "Docker 未安装，正在安装 Docker..."
        # 安装 Docker
        sudo apt install -y docker.io

        # 检查是否安装了 docker-compose，如果未安装则安装
        if ! command -v docker-compose &> /dev/null; then
            echo "docker-compose 未安装，正在安装 docker-compose..."
            sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            docker-compose --version  # 版本应为 docker-compose version 1.29.2
            if command -v docker-compose &> /dev/null; then
                echo "docker-compose 安装成功。"
            else
                echo "docker-compose 安装失败，请检查错误。"
                exit 1
            fi
        else
            echo "docker-compose 已安装。"
        fi
    fi
    
    # 检查是否安装了 docker-compose，如果未安装则安装
    if ! command -v docker-compose &> /dev/null; then
        echo "docker-compose 未安装，正在安装 docker-compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        docker-compose --version  # 版本应为 docker-compose version 1.29.2
        if command -v docker-compose &> /dev/null; then
            echo "docker-compose 安装成功。"
        else
            echo "docker-compose 安装失败，请检查错误。"
            exit 1
        fi
    else
        echo "docker-compose 已安装。"
    fi
}

# 安装节点函数
function install_node() {
    # 安装节点工具
    install_node_tools

    # 安装 Docker
    install_docker

    # 克隆或更新 nwaku-compose 项目
    if [ -d "nwaku-compose" ]; then
        echo "更新 nwaku-compose 项目..."
        cd nwaku-compose || { echo "进入 nwaku-compose 目录失败，请检查错误信息。"; exit 1; }
        git stash push --include-untracked
        git pull origin master
        cd ..
    else
        echo "克隆 nwaku-compose 项目 ..."
        git clone https://github.com/waku-org/nwaku-compose
    fi

    # 进入 nwaku-compose 目录
    cd nwaku-compose || {
        echo "进入 nwaku-compose 目录失败，请检查错误信息。"
        exit 1
    }

    echo "成功进入 nwaku-compose 目录。"

    # 复制 .env.example 到 .env
    cp .env.example .env

    echo "成功复制 .env.example 到 .env 文件。"

    # 获取用户输入并更新 .env 文件
    read -rp "请输入您的 Infura 项目密钥（key）： " infura_key
    read -rp "请输入您的测试网络私钥-不要0x开头（<YOUR_TESTNET_PRIVATE_KEY_HERE>）： " testnet_private_key
    read -rp "请输入您的安全密钥存储密码（my_secure_keystore_password）： " keystore_password

    # 使用 sed 或其他方法替换 .env 文件中的占位符
    sed -i "s|<key>|$infura_key|g" .env
    sed -i "s|<YOUR_TESTNET_PRIVATE_KEY_HERE>|$testnet_private_key|g" .env
    sed -i "s|my_secure_keystore_password|$keystore_password|g" .env

    echo ".env 文件已更新。"

    # 执行 register_rln.sh 脚本
    echo "正在执行 register_rln.sh 脚本..."
    ./register_rln.sh

    echo "register_rln.sh 脚本执行完成。"

    # 启动 Docker Compose 服务
    echo "启动 Docker Compose 服务..."
    docker-compose up -d || { echo "启动 Docker Compose 失败，请检查错误信息。"; exit 1; }

    echo "Docker Compose 服务启动完成。"
    read -rp "按 Enter 返回菜单。"
}

# 查看日志函数
function view_logs() {
    echo "正在查看 nwaku 的日志..."
    # 使用 docker-compose 查看 nwaku 的日志
    docker-compose logs -f nwaku
    echo "按 Ctrl+C 退出日志查看。"
}

# 修复错误函数
function fix_errors() {
    # 停止 Docker Compose 服务
    docker-compose down

    # 进入 nwaku-compose 目录
    cd nwaku-compose || { echo "进入 nwaku-compose 目录失败，请检查错误信息。"; exit 1; }

    # 执行 git stash 和 git pull 操作
    git stash push --include-untracked
    git pull origin master

    # 删除 keystore 和 rln_tree 目录
    rm -rf keystore rln_tree

    # 编辑 .env 文件
    echo "请修改 .env 文件中的 ETH_CLIENT_ADDRESS 为 RLN_RELAY_ETH_CLIENT_ADDRESS。"
    nano -i .env

    # 启动 Docker Compose
    docker-compose up -d || { echo "启动 Docker Compose 失败，请检查错误信息。"; exit 1; }

    echo "错误修复完成。"
    read -rp "按 Enter 返回菜单。"
}

# 更新脚本函数
function update_script() {
    echo "正在更新 nwaku-compose 项目..."
    
    # 进入 nwaku-compose 目录
    cd nwaku-compose || { echo "进入 nwaku-compose 目录失败，请检查错误信息。"; exit 1; }
    
    # 停止 Docker Compose 服务
    docker-compose down
    
    # 更新项目
    git pull origin master
    
    # 重新启动 Docker Compose 服务
    docker-compose up -d || { echo "启动 Docker Compose 失败，请检查错误信息。"; exit 1; }
    
    echo "脚本更新完成。"
    read -rp "按 Enter 返回菜单。"
}

# 主程序开始
main_menu
