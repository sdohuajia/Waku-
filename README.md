# Waku-一键运行脚本：wget https://raw.githubusercontent.com/sdohuajia/Waku-/main/Waku.sh && chmod +x Waku.sh && ./Waku.sh

最低配置：2CPU / 2RAM / 40SSD

服务器租赁：PqHosting, XorekCloud, AEZA, Hetzner, Contabo

操作系统：Ubuntu 20.04

可以通过浏览器在 Explorer 中检查你的注册交易。

前往 Grafana 仪表盘查看同步状态：

http://localhost:3000/d/yns_4vFVk/nwaku-monitoring  # 将 localhost 替换为你的服务器 IP

请求测试 $ETH 和获取 RPC：

前往 Infura 水龙头请求 Sepolia 测试网 $ETH，需要至少 1 美金的ETH。

建议创建一个单独的 EVM 账户并将测试网 $ETH 转入其中

在 .env 文件中填写你的数据：

ETH_CLIENT_ADDRESS=https://sepolia.infura.io/v3/<key>  # Sepolia ETH 的 RPC 地址

ETH_TESTNET_KEY=<YOUR_TESTNET_PRIVATE_KEY_HERE>        # 有测试网 ETH 的私钥（最好创建新钱包）

RLN_RELAY_CRED_PASSWORD="my_secure_keystore_password"  # 设置密码

替换 ETH_CLIENT_ADDRESS 为 RLN_RELAY_ETH_CLIENT_ADDRESS。


获取key网站：https://www.infura.io/faucet/sepolia
