# 防火墙默认设置

## 目标
精简版 iStoreOS 镜像默认面向 **旁路由 + OpenClash** 场景，因此构建阶段明确固化以下防火墙默认值：

- `firewall.@defaults[0].forward='ACCEPT'`
- 所有现有 `firewall.@zone[*].masq='1'`

## 为什么这样做
旁路由场景下，如果默认 `forward` 不是 `ACCEPT`，或者 NAT / Masquerading 默认关闭，常见问题包括：
- 旁路由接管后客户端无法正常转发
- OpenClash 透明代理链路异常
- 局域网访问表现不稳定，排障成本高

因此当前项目把它作为**镜像默认行为**，而不是部署后手工调整项。

## 实现方式
在 `Dockerfile.minimal` 构建阶段执行：

- `scripts/prune-packages.sh`
- `scripts/apply-firewall-defaults.sh`

其中 `apply-firewall-defaults.sh` 会：
1. 检查 `firewall.@defaults[0].forward`
2. 强制设为 `ACCEPT`
3. 遍历当前所有 firewall zone
4. 为每个 zone 开启 `masq=1`
5. 自动 `uci commit firewall`

## 验证命令
容器启动后可执行：

```bash
uci get firewall.@defaults[0].forward
uci show firewall | grep '\.masq='
```

预期至少看到：

```bash
ACCEPT
```

以及各 zone 存在：

```bash
firewall.@zone[0].masq='1'
```

## 注意
当前策略是为了优先保证“旁路由可用性”。

如果后续你想进一步收紧安全策略，可以在镜像稳定后再细化：
- 只对特定 zone 开启 `masq`
- 把 zone 名称与接口绑定规则做得更明确
- 针对 OpenClash 的实际流量路径再优化默认值
