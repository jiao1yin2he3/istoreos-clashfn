# 飞牛导入版 Compose 说明

## 已生成文件
- `docker-compose.feiniu.yml`：可直接改值后导入飞牛的固定值版本
- `docker-compose.feiniu.example.yml`：占位符模板版本

## 推荐 Compose 配置
下面这份配置以 **你自己的 ARM64 定制镜像** 为默认前提，适合飞牛 GUI 导入，也适合作为 README 中的标准部署示例：

```yaml
services:
  istoreos:
    # 使用你自己的 ARM64 定制镜像
    # 本地构建后可直接写：istoreos-fn:minimal-v1
    # 如果后续推到镜像仓库，可改成：yourname/istoreos-fn:minimal-v1
    image: istoreos-fn:minimal-v1
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

## 默认镜像策略
当前仓库默认推荐：
- **部署时直接使用你自己的定制镜像**：`istoreos-fn:minimal-v1`

如果后续需要发布给其他人使用，再替换成：
- 你自己的镜像仓库地址，例如 `yourname/istoreos-fn:minimal-v1`

## 部署前提
在使用 `docker-compose.feiniu.yml` 之前，请先完成镜像构建：

```bash
docker build -f Dockerfile.minimal -t istoreos-fn:minimal-v1 .
```

如果你不是用本地镜像，而是已经推到远程仓库，则把 compose 中的：
```yaml
image: istoreos-fn:minimal-v1
```
改成：
```yaml
image: yourname/istoreos-fn:minimal-v1
```

## 当前固定值版本
`docker-compose.feiniu.yml` 里默认写的是：
- 宿主网卡：`end0`
- 子网：`192.168.66.0/24`
- 网关：`192.168.66.1`
- 容器 IP：`192.168.66.2`
- 时区：`Asia/Shanghai`

如果你的飞牛环境不是这组参数，导入前先改掉。

## 导入前必改项
### 1. parent 网卡名
把：
```yaml
parent: end0
```
改成飞牛宿主实际网卡名，例如：
- `eth0`
- `end0`
- `enp1s0`
- `enp1s0-ovs`

查看方式：
```bash
ip link show
```

### 2. 网络参数
确认这三项和你的局域网一致：
```yaml
subnet: 192.168.66.0/24
gateway: 192.168.66.1
ipv4_address: 192.168.66.2
```

要求：
- `ipv4_address` 不能和现有设备冲突
- 必须和 `subnet` 同网段
- `gateway` 必须是真实局域网网关
- 最好提前在路由器 DHCP 排除这个固定 IP

### 3. 镜像名
如果你使用的不是本地默认镜像，把：
```yaml
image: istoreos-fn:minimal-v1
```
改成你的实际镜像地址，例如：
```yaml
image: yourname/istoreos-fn:minimal-v1
```

## 持久化挂载说明
当前先保守挂载：
```yaml
- ./data/root:/root
- ./data/etc:/etc
- ./data/upper:/overlay
```

适合第一轮验证。

如果飞牛对相对路径支持不好，可以改成绝对路径，例如：
```yaml
- /vol1/1000/docker/istoreos/root:/root
- /vol1/1000/docker/istoreos/etc:/etc
- /vol1/1000/docker/istoreos/upper:/overlay
```

## 部署命令
### 1. 先构建你的定制镜像
```bash
docker build -f Dockerfile.minimal -t istoreos-fn:minimal-v1 .
```

### 2. Docker Compose CLI 启动
```bash
docker compose -f docker-compose.feiniu.yml up -d
```

停止：
```bash
docker compose -f docker-compose.feiniu.yml down
```

查看日志：
```bash
docker compose -f docker-compose.feiniu.yml logs -f
```

### 3. 飞牛 GUI 导入
1. 先完成镜像构建，确保宿主机本地已有 `istoreos-fn:minimal-v1`
2. 打开飞牛应用 / Compose 导入界面
3. 粘贴 `docker-compose.feiniu.yml` 内容
4. 按你的环境修改 `parent`、`subnet`、`gateway`、`ipv4_address`
5. 确认挂载目录可写
6. 提交并启动

## 导入后验证
导入启动后，按下面顺序验证：
1. 能否打开 LuCI
2. 软件商店页面是否正常
3. OpenClash 页面是否正常
4. OpenClash 服务能否启动
5. 容器 IP 是否能作为旁路由使用
6. 多语言与默认主题是否正常

## 常见问题
### 提示找不到镜像
说明你还没有先构建本地镜像，或者 compose 里的镜像名和你实际构建的 tag 不一致。

### 宿主机访问不到容器 IP
这是 `macvlan` 常见现象，不一定是部署失败。

### 飞牛不允许创建 macvlan
如果飞牛 GUI 限制了 `macvlan`，可能需要：
- 先在宿主机创建网络
- Compose 中直接引用已有 network

### 挂载后系统异常
说明 `/etc` 或 `/overlay` 全量挂载可能过粗，下一步就要改成更细粒度挂载。

### OpenClash 不能启动
优先检查：
- 容器是否 `privileged: true`
- TUN / 防火墙相关能力是否正常
- 当前自定义镜像是否包含 OpenClash 所需依赖
