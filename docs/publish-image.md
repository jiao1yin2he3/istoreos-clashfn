# 镜像发布与联网拉取

## 目标
把定制镜像自动发布到镜像仓库，目标机器只需联网即可拉取，不再依赖本地 `docker build`。

当前默认仓库：
- `ghcr.io/jiao1yin2he3/istoreos-clashfn:minimal-v1`

## 已提供能力
仓库内已新增 GitHub Actions 工作流：
- `.github/workflows/publish-image.yml`

它会在以下场景自动构建并推送镜像：
- push 到 `main`
- push `v*` tag
- 手动触发 `workflow_dispatch`

## 发布到哪里
镜像会发布到 GitHub Container Registry：
- `ghcr.io/jiao1yin2he3/istoreos-clashfn`

默认标签包括：
- `minimal-v1`
- `latest`（main 分支）
- `sha-<commit>`
- `v*`（tag 发布）

## 首次使用前要做什么
### 1. 确保仓库 Actions 已启用
GitHub 仓库页面需要允许 Actions 运行。

### 2. 确保 Packages 可见性符合你的需求
默认推送到 GHCR 后，可能需要在 GitHub Packages 页面把镜像设为 `public`，否则其他机器拉取时可能需要登录。

建议检查：
- GitHub 仓库 → Packages
- 选择 `istoreos-clashfn`
- 确认可见性是否为 `public`

## 如何触发发布
### 方式 1：直接推 main
每次 push 到 `main`，都会自动发布镜像。

### 方式 2：打 tag 发布
```bash
git tag v0.1.0
git push origin v0.1.0
```

### 方式 3：GitHub 网页手动运行
- 打开 `Actions`
- 选择 `Publish Docker image`
- 点击 `Run workflow`

## 目标机器如何拉取
如果镜像已公开，目标机器直接：
```bash
docker pull ghcr.io/jiao1yin2he3/istoreos-clashfn:minimal-v1
```

如果用 compose：
```bash
docker-compose -f docker-compose.feiniu.yml up -d
```

## Compose 默认镜像
当前 `docker-compose.feiniu.yml` 已改为：
```yaml
image: ghcr.io/jiao1yin2he3/istoreos-clashfn:minimal-v1
```

## 如果 GHCR 是私有镜像
目标机器先登录：
```bash
docker login ghcr.io
```

用户名：
- `jiao1yin2he3`

密码：
- GitHub PAT（至少有 `read:packages`）

然后再执行：
```bash
docker-compose -f docker-compose.feiniu.yml up -d
```

## 推荐发布策略
开发阶段建议：
- compose 默认使用 `minimal-v1`
- 排障时可切到 `sha-<commit>`

稳定后建议：
- 使用版本 tag，例如 `v0.1.0`
- 对应镜像也会生成同名 tag，便于回滚
