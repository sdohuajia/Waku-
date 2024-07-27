# Waku-

可以通过浏览器在 Explorer 中检查你的注册交易。

前往 Grafana 仪表盘查看同步状态：

http://localhost:3000/d/yns_4vFVk/nwaku-monitoring  # 将 localhost 替换为你的服务器 IP


在 .env 文件中填写你的数据：

ETH_CLIENT_ADDRESS=https://sepolia.infura.io/v3/<key>  # Sepolia ETH 的 RPC 地址
ETH_TESTNET_KEY=<YOUR_TESTNET_PRIVATE_KEY_HERE>        # 有测试网 ETH 的私钥（最好创建新钱包）
RLN_RELAY_CRED_PASSWORD="my_secure_keystore_password"  # 设置密码
替换 ETH_CLIENT_ADDRESS 为 RLN_RELAY_ETH_CLIENT_ADDRESS。
