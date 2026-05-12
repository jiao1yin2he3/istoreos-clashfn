# 构建与启动脚本

## 已提供脚本
- `scripts/build-image.sh`
- `scripts/run-compose.sh`
- `scripts/check-runtime.sh`

## 1. 构建定制镜像
默认构建：
```bash
bash scripts/build-image.sh
```

等价于：
```bash
docker build -f Dockerfile.minimal -t istoreos-fn:minimal-v1 .
```

### 可选环境变量
```bash
IMAGE_NAME=istoreos-fn IMAGE_TAG=minimal-v1 bash scripts/build-image.sh
```

也可以自定义 Dockerfile：
```bash
DOCKERFILE=Dockerfile.minimal bash scripts/build-image.sh
```

## 2. 启动 Compose
```bash
bash scripts/run-compose.sh up
```

## 3. 停止 Compose
```bash
bash scripts/run-compose.sh down
```

## 4. 重启 Compose
```bash
bash scripts/run-compose.sh restart
```

## 5. 查看日志
```bash
bash scripts/run-compose.sh logs
```

## 6. 查看状态
```bash
bash scripts/run-compose.sh ps
```

## 7. 运行时检查
```bash
bash scripts/check-runtime.sh
```

默认会检查：
- 容器是否运行
- 容器 IP 是否存在
- `firewall.@defaults[0].forward` 是否为 `ACCEPT`
- 是否存在 `masq='1'`
- `uhttpd` / `rpcd` 进程
- LuCI HTTP 可达性
- OpenClash 页面基础可达性

### 可选环境变量
```bash
CONTAINER_NAME=istoreos bash scripts/check-runtime.sh
```

## 默认使用的 Compose 文件
默认是：
```bash
docker-compose.feiniu.yml
```

如果你想切到别的 compose 文件：
```bash
COMPOSE_FILE=docker-compose.minimal.yml bash scripts/run-compose.sh up
```

## 推荐流程
```bash
bash scripts/build-image.sh
bash scripts/run-compose.sh up
bash scripts/run-compose.sh ps
bash scripts/check-runtime.sh
```
