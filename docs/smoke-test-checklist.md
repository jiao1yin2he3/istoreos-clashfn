# 冒烟测试清单

## 1. 容器基础
- 容器能正常启动
- `ps` 可见 `procd` / `rpcd` / `uhttpd`
- Web 管理地址可访问

## 2. LuCI
- 首页正常打开
- 系统菜单正常
- 网络菜单正常
- 不出现 500/空白页

## 3. 软件商店
- `luci-app-store` 页面可打开
- 应用列表可加载
- 页面不报依赖错误

## 4. OpenClash
- `luci-app-openclash` 页面可打开
- 核心下载/检测逻辑正常
- 服务可以启动
- 不出现缺少 TUN / nft / iptables 依赖报错

## 5. 旁路由网络
- 容器有独立局域网 IP
- 网关 / DNS / 路由配置可修改
- 客户端可通过该容器转发

## 6. 防火墙默认值
- `uci get firewall.@defaults[0].forward` 返回 `ACCEPT`
- `uci show firewall | grep '\.masq='` 可看到 `masq='1'`
- LuCI 防火墙页面默认转发策略符合预期
- NAT / Masquerading 默认已启用

## 7. 多语言与主题
- 中文界面正常
- 默认主题正常
- 本轮保留的语言包仍可正常切换
