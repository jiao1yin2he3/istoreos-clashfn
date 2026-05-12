# istoreos-clashfn

面向 OEC / OECT 设备的极简 ARM64 iStoreOS 容器方案，目标是在飞牛场景中保留 **Web 管理、软件商店、多语言、旁路由能力、OpenClash**，并通过 **Compose** 方式部署。

## 项目目标
- 保留 Web 管理
- 保留软件商店
- 保留多语言
- 保留旁路由能力
- 支持 OpenClash
- 支持 Compose 方式部署
- 适合 GitHub 协作与后续 Pull Request

## 当前阶段
当前仓库处于 **v0.1 原型阶段**，重点是：
1. 基于现有可运行 iStoreOS ARM64 容器做第一轮温和裁剪
2. 保留飞牛场景必要能力
3. 默认使用已发布的定制镜像部署
4. 固化旁路由默认防火墙行为：`forward=ACCEPT`、`masq=1`

## 目录说明
- `docker-compose.feiniu.yml`：飞牛 GUI 可直接导入版 Compose
- `docker-compose.feiniu.example.yml`：占位符模板
- `docker-compose.minimal.yml`：env 驱动版 Compose
- `Dockerfile.minimal`：第一轮裁剪镜像构建文件
- `config/candidate-remove-list.txt`：第一轮候选删除清单
- `scripts/prune-packages.sh`：裁剪脚本
- `scripts/apply-firewall-defaults.sh`：防火墙默认值固化脚本
- `scripts/build-image.sh`：镜像构建脚本
- `scripts/run-compose.sh`：Compose 启停脚本（自动兼容 `docker compose` / `docker-compose`）
- `scripts/check-runtime.sh`：运行时检查脚本
- `.github/workflows/publish-image.yml`：自动发布 GHCR 镜像
- `docs/`：设计、部署、裁剪、验证文档
- `.github/`：Issue / PR 模板

## 推荐 Compose 部署
```yaml
services:
  istoreos:
    image: ghcr.io/jiao1yin2he3/istoreos-clashfn:minimal-v1
    container_name: istoreos
    privileged: true
    restart: always
    command: /sbin/init
    environment:
      TZ: Asia/Shanghai
    volumes:
      - ./data/root:/root
      - ./data/etc:/etc
      - ./data/upper:/overlay
    networks:
      ios_macnet:
#根据自己ip修改成192.168.XXX(主路由网段).XXX（未被占用的地址）
        ipv4_address: 192.168.66.2

networks:
  ios_macnet:
    name: ios_macnet
    driver: macvlan
    driver_opts:
      parent: end0
    ipam:
      config:
#根据自己ip修改成192.168.XXX.0/24(主路由网段)
        - subnet: 192.168.66.0/24
#根据自己ip修改成192.168.XXX.1(主路由网段)
          gateway: 192.168.66.1
```

## Compose 兼容性
当前环境实测：
- `docker compose` 不可用
- `docker-compose` 可用

所以如果你手工执行命令，请优先用：
```bash
docker-compose -f docker-compose.feiniu.yml up -d
```

或者直接用仓库脚本：
```bash
bash scripts/run-compose.sh up
```

## 快速开始
### 1. 直接拉取已发布镜像
```bash
docker pull ghcr.io/jiao1yin2he3/istoreos-clashfn:minimal-v1
```

### 2. Compose 启动
```bash
bash scripts/run-compose.sh up
```

### 3. 查看运行状态
```bash
bash scripts/run-compose.sh ps
```

### 4. 运行时检查
```bash
bash scripts/check-runtime.sh
```

### 5. 飞牛导入
如果使用飞牛 GUI 导入 Compose，优先参考：
- `docker-compose.feiniu.yml`
- `docs/feiniu-compose-import.md`
- `docs/publish-image.md`

## 当前精简策略
第一轮明确保留：
- 软件商店
- 多语言
- OpenClash
- 旁路由相关网络栈
- LuCI 核心
- 旁路由默认防火墙策略（`forward=ACCEPT`，Masquerading 开启）

第一轮明确删除：
- 多媒体
- 打印
- 蓝牙
- 下载器
- 多余主题

详细说明见：
- `docs/package-profile.md`
- `docs/minimalization-strategy.md`
- `docs/round-1-prune-targets.md`
- `docs/firewall-defaults.md`
- `docs/publish-image.md`

## 验证建议
部署后建议按以下文档做回归测试：
- `docs/smoke-test-checklist.md`

重点验证：
- LuCI
- 软件商店
- OpenClash 页面与启动
- macvlan 独立 IP
- 旁路由链路
- 多语言与默认主题
- `uci get firewall.@defaults[0].forward` 返回 `ACCEPT`
- `uci show firewall | grep '\.masq='` 显示已开启

## 常用命令
```bash
docker pull ghcr.io/jiao1yin2he3/istoreos-clashfn:minimal-v1
bash scripts/run-compose.sh up
bash scripts/run-compose.sh logs
bash scripts/check-runtime.sh
bash scripts/run-compose.sh down
```

## GitHub 协作
```bash
git clone https://github.com/jiao1yin2he3/istoreos-clashfn.git
cd istoreos-clashfn
git pull
```

欢迎通过 Issue 和 Pull Request 参与贡献。

## License
MIT
