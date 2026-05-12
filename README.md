# 极简 ARM 版 iStoreOS → 飞牛应用

面向 OEC / OECT 设备，定制一个极简 ARM64 iStoreOS 容器方案，用于飞牛应用场景。

当前目标：
- 保留 Web 管理
- 保留软件商店
- 保留多语言
- 保留旁路由能力
- 支持 OpenClash
- 支持 Compose 方式部署
- 适合上传到 GitHub，便于后续 pull / clone / 协作

## 目录说明
- `docker-compose.feiniu.yml`：飞牛 GUI 可直接导入版 Compose
- `docker-compose.feiniu.example.yml`：占位符模板
- `docker-compose.minimal.yml`：env 驱动版 Compose
- `Dockerfile.minimal`：第一轮裁剪镜像构建文件
- `config/candidate-remove-list.txt`：第一轮候选删除清单
- `scripts/prune-packages.sh`：裁剪脚本
- `docs/`：设计、部署、裁剪、验证文档

## 快速开始
### 1. 构建镜像
```bash
docker build -f Dockerfile.minimal -t istoreos-fn:minimal-v1 .
```

### 2. Compose 启动
```bash
docker compose -f docker-compose.feiniu.yml up -d
```

## GitHub 协作方式
推荐流程：
1. 创建 GitHub 仓库
2. 添加远程 `origin`
3. `git push -u origin main`
4. 后续通过 `git pull` / Pull Request 协作

## 注意
- `data/` 和 `.env` 已加入 `.gitignore`，避免把运行时数据和本地环境提交到仓库。
- 首次导入飞牛前，请先检查 `docker-compose.feiniu.yml` 中的网卡、IP、网关配置。
