# 飞牛导入版 Compose 说明

## 已生成文件
- `docker-compose.feiniu.yml`：可直接改值后导入飞牛的固定值版本
- `docker-compose.feiniu.example.yml`：占位符模板版本

## 当前固定值版本
`docker-compose.feiniu.yml` 里默认写的是：
- 宿主网卡：`end0`
- 子网：`192.168.66.0/24`
- 网关：`192.168.66.1`
- 容器 IP：`192.168.66.2`
- 时区：`Asia/Shanghai`

如果你的飞牛环境不是这组参数，导入前先改掉。

## 推荐导入方式
如果飞牛应用界面不支持 `.env`，就用这个文件：

- `docker-compose.feiniu.yml`

它已经把环境变量全部展开成固定值，更适合 GUI 导入。

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

### 3. 镜像名
如果你最终不是本地镜像 `istoreos-fn:minimal-v1`，把：
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

## 导入后验证
导入启动后，按下面顺序验证：
1. 能否打开 LuCI
2. 软件商店页面是否正常
3. OpenClash 页面是否正常
4. OpenClash 服务能否启动
5. 容器 IP 是否能作为旁路由使用
6. 多语言与默认主题是否正常

## 常见问题
### 宿主机访问不到容器 IP
这是 `macvlan` 常见现象，不一定是部署失败。

### 飞牛不允许创建 macvlan
如果飞牛 GUI 限制了 `macvlan`，可能需要：
- 先在宿主机创建网络
- Compose 中直接引用已有 network

### 挂载后系统异常
说明 `/etc` 或 `/overlay` 全量挂载可能过粗，下一步就要改成更细粒度挂载。
