#!/bin/bash

# 自动拉取最新代码库
echo "正在检查脚本更新..."
git pull origin main
echo "脚本已更新到最新版本。"

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
        echo "2. 修复错误"
        echo "3. 编辑 .env 文件"
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
                edit_env_file
                ;;
            4)
                echo "退出脚本，谢谢使用！"
                exit 0
                ;;
            *)
                echo "无效的选择，请重新输入。"
                sleep 2
                ;;
        esac
    done
}

# 安装节点函数
function install_node() {
    # 更新软件源并升级系统软件
    sudo apt update && sudo apt upgrade -y

    # 安装必要的软件和工具
    sudo apt install -y curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev

    # 检测Docker安装是否成功
    if ! command -v docker &> /dev/null; then
        echo "安装 Docker ..."
        sudo apt install -y docker.io
        if ! command -v docker &> /dev/null; then
            echo "安装 Docker 失败，请检查错误信息。"
            exit 1
        fi
    fi

    # 检查是否需要安装Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo "安装 Docker Compose ..."
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        if ! command -v docker-compose &> /dev/null; then
            echo "安装 Docker Compose 失败，请检查错误信息。"
            exit 1
        fi
    fi

    # 安装Waku
    echo "正在安装 Waku ..."
    git clone https://github.com/waku-org/nwaku-compose
    cd nwaku-compose || { echo "切换目录失败，请检查目录结构和权限。"; exit 1; }
    cp .env.example .env

    echo "请编辑 .env 文件并填写所需的信息："
    echo "nano .env"

    # 注册节点
    ./register_rln.sh || { echo "注册节点失败，请检查错误信息。"; exit 1; }

    # 启动 Docker Compose
    docker-compose up -d || { echo "启动 Docker Compose 失败，请检查错误信息。"; exit 1; }

    echo "Waku安装完成，并已注册节点并启动。"
    read -rp "按 Enter 返回菜单。"
}

# 修复错误函数
function fix_errors() {
    # 停止 Docker Compose 服务
    docker-compose down

    # 执行 git stash 和 git pull 操作
    git stash push --include-untracked
    git pull https://github.com/waku-org/nwaku-compose.git

    # 删除 keystore 和 rln_tree 目录
    rm -rf keystore rln_tree

    # 从 origin/master 分支拉取最新代码
    git pull origin master

    # 编辑 .env 文件
    nano .env  # 请修改 ETH_CLIENT_ADDRESS 为 RLN_RELAY_ETH_CLIENT_ADDRESS

    # 注册节点
    ./register_rln.sh || { echo "注册节点失败，请检查错误信息。"; exit 1; }

    # 启动 Docker Compose
    docker-compose up -d || { echo "启动 Docker Compose 失败，请检查错误信息。"; exit 1; }

    echo "错误修复完成。"
    read -rp "按 Enter 返回菜单。"
}

# 编辑 .env 文件函数
function edit_env_file() {
    clear
    echo "正在编辑 /root/nwaku-compose/.env 文件 ..."

    # 显示提示信息
    echo "# 请填写以下内容，并按需修改："
    echo "# ETH_CLIENT_ADDRESS=https://sepolia.infura.io/v3/<key>  # Sepolia ETH 的 RPC 地址"
    echo "# ETH_TESTNET_KEY=<YOUR_TESTNET_PRIVATE_KEY_HERE>        # 有测试网 ETH 的私钥（最好创建新钱包）"
    echo "# RLN_RELAY_CRED_PASSWORD=\"my_secure_keystore_password\"  # 设置密码"

    # 打开编辑器编辑文件
    nano /root/nwaku-compose/.env

    # 提示用户按 Enter 返回菜单
    read -rp "按 Enter 返回菜单。"

    # 替换 ETH_CLIENT_ADDRESS 为 RLN_RELAY_ETH_CLIENT_ADDRESS
    RLN_RELAY_ETH_CLIENT_ADDRESS=$(grep '^ETH_CLIENT_ADDRESS=' /root/nwaku-compose/.env | cut -d '=' -f 2-)
    sed -i "s|ETH_CLIENT_ADDRESS=.*|RLN_RELAY_ETH_CLIENT_ADDRESS=$RLN_RELAY_ETH_CLIENT_ADDRESS|" /root/nwaku-compose/.env

    echo "已将 ETH_CLIENT_ADDRESS 替换为 RLN_RELAY_ETH_CLIENT_ADDRESS。"
    read -rp "按 Enter 返回菜单。"
}

# 主程序开始
main_menu
