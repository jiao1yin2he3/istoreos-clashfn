# Contributing

感谢你为 `istoreos-clashfn` 做贡献。

## 贡献方向
欢迎提交以下内容：
- Compose 部署改进
- 飞牛导入兼容性修复
- iStoreOS 精简策略优化
- OpenClash 兼容性修复
- 文档补充与勘误

## 开发流程
1. Fork 本仓库
2. 创建功能分支
   ```bash
   git checkout -b feat/your-change
   ```
3. 提交修改
   ```bash
   git commit -m "feat: describe your change"
   ```
4. 推送到你的分支
5. 发起 Pull Request

## 提交建议
尽量使用约定式提交：
- `feat:` 新功能
- `fix:` 修复问题
- `docs:` 文档修改
- `refactor:` 重构
- `chore:` 杂项维护

## 提交前检查
请至少验证：
- Compose 文件语法正确
- 文档中的命令可执行
- 裁剪策略不会误伤 OpenClash、软件商店或 LuCI 核心

## Pull Request 内容建议
PR 请尽量包含：
- 变更目的
- 关键修改点
- 验证方式
- 如涉及网络/飞牛环境差异，请说明测试环境
