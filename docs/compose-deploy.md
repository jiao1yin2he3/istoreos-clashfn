# Compose 部署说明

## 文件
- `docker-compose.minimal.yml`
- `.env.example`

## 1. 准备环境变量
先复制：

```bash
cp .env.example .env
```

按实际环境修改：
- `PARENT_IFACE`：宿主机物理网卡名
- `SUBNET`：宿主机所在局域网网段
- `GATEWAY`：局域网网关
- `ISTOREOS_IP`：分配给 iStoreOS 容器的固定 IP

## 2. 构建镜像
如果你已经在本目录准备好了 `Dockerfile.minimal`：

```bash
docker build -f Dockerfile.minimal -t istoreos-fn:minimal-v1 .
```

## 3. 启动
```bash
docker compose -f docker-compose.minimal.yml --env-file .env up -d
```

## 4. 停止
```bash
docker compose -f docker-compose.minimal.yml --env-file .env down
```

## 5. 查看日志
```bash
docker compose -f docker-compose.minimal.yml --env-file .env logs -f
```

## 6. 持久化目录
当前 compose 预留了以下目录：
- `./data/root:/root`
- `./data/etc:/etc`
- `./data/upper:/overlay`

说明：
- 这是一个保守初版，方便后续观察配置写入路径。
- `OpenWrt/iStoreOS` 容器的持久化方式可能因镜像结构不同而需要调整。
- 若发现 `/etc` 或 `/overlay` 全量挂载引发异常，可改成更细粒度的挂载。

## 7. 访问
启动后直接访问：

```text
http://ISTOREOS_IP
```

比如：

```text
http://192.168.66.2
```

## 8. 注意事项
1. 容器需要 `privileged: true`，否则 OpenClash/旁路由能力大概率不完整。
2. `macvlan` 下宿主机默认可能无法直接访问容器 IP，这是网络模型特性。
3. 若飞牛界面导入 Compose，通常需要把 `.env` 中变量先替换成具体值，或确认它是否支持 env-file。
4. 第一次启动后，按 `docs/smoke-test-checklist.md` 验证 LuCI、软件商店、OpenClash、旁路由能力。
