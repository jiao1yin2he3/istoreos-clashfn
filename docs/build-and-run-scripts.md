# 构建与启动脚本

## 已提供脚本
- `scripts/build-image.sh`
- `scripts/run-compose.sh`

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
```
