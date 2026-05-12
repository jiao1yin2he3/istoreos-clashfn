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
3. 优先提供可导入的 Compose 模板

## 目录说明
- `docker-compose.feiniu.yml`：飞牛 GUI 可直接导入版 Compose
- `docker-compose.feiniu.example.yml`：占位符模板
- `docker-compose.minimal.yml`：env 驱动版 Compose
- `Dockerfile.minimal`：第一轮裁剪镜像构建文件
- `config/candidate-remove-list.txt`：第一轮候选删除清单
- `scripts/prune-packages.sh`：裁剪脚本
- `docs/`：设计、部署、裁剪、验证文档
- `.github/`：Issue / PR 模板

## 推荐 Compose 部署
```yaml
services:
  istoreos:
    # ARM64 架构镜像：
    # - wukongdaily/openwrt-istoreos:arm64-latest 纯净版
    # - wukongdaily/openwrt-istoreos:arm64-ops    带插件版
    # 也可以替换成你自己的精简镜像，例如：istoreos-fn:minimal-v1
    image: wukongdaily/openwrt-istoreos:arm64-latest
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
        ipv4_address: 192.168.66.2

networks:
  ios_macnet:
    name: ios_macnet
    driver: macvlan
    driver_opts:
      # 这里替换为你设备的网卡名称（比如 eth0、end0、enp1s0、enp1s0-ovs 等）
      # 可用 ip link show 查看
      parent: end0
    ipam:
      config:
        - subnet: 192.168.66.0/24
          gateway: 192.168.66.1
```

## 快速开始
### 1. 构建自定义镜像（可选）
```bash
docker build -f Dockerfile.minimal -t istoreos-fn:minimal-v1 .
```

### 2. Compose 启动
```bash
docker compose -f docker-compose.feiniu.yml up -d
```

### 3. 飞牛导入
如果使用飞牛 GUI 导入 Compose，优先参考：
- `docker-compose.feiniu.yml`
- `docs/feiniu-compose-import.md`

## 当前精简策略
第一轮明确保留：
- 软件商店
- 多语言
- OpenClash
- 旁路由相关网络栈
- LuCI 核心

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

## GitHub 协作
```bash
git clone https://github.com/jiao1yin2he3/istoreos-clashfn.git
cd istoreos-clashfn
git pull
```

欢迎通过 Issue 和 Pull Request 参与贡献。

## License
MIT
