# Dockerfile.minimal 说明

## 目标
基于 `wukongdaily/openwrt-istoreos:arm64-latest` 做第一轮温和裁剪：
- 保留：LuCI、软件商店、多语言、旁路由、OpenClash
- 删除：多媒体、打印、蓝牙、下载器、多余主题

## 文件
- `Dockerfile.minimal`
- `scripts/prune-packages.sh`
- `config/candidate-remove-list.txt`

## 工作方式
1. 以现有可运行镜像为基础。
2. 构建时把候选删除清单复制进镜像。
3. 使用 `opkg remove` 逐项尝试删除。
4. 自动记录：
   - 删除前包快照
   - 删除成功包列表
   - 删除失败包列表
   - 完整日志

## 构建命令示例
```bash
docker build -f Dockerfile.minimal -t istoreos-fn:minimal-v1 .
```

## 运行命令示例
```bash
docker run -d \
  --name istoreos-min \
  --privileged \
  --restart always \
  --network ios_macnet \
  istoreos-fn:minimal-v1 /sbin/init
```

## 风险提醒
- `opkg remove` 可能因依赖关系拒绝删除部分包，这是正常现象。
- 主题删除前，最好先确认当前默认主题。
- 若某些下载器/媒体组件被软件商店页面间接引用，删除后要做页面回归测试。
- 这是第一轮保守裁剪，不追求一次删到极限。

## 下一步建议
1. 先构建这版镜像。
2. 查看 `/root/minimal-backup/` 下的日志和快照。
3. 按 `docs/smoke-test-checklist.md` 跑一轮验证。
4. 根据失败项修正 `candidate-remove-list.txt`。
