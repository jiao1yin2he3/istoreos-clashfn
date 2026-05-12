# 现有 Docker 方案分析

参考方案：
- 镜像：`wukongdaily/openwrt-istoreos:arm64-latest`
- 启动方式：`/sbin/init`
- 权限：`privileged: true`
- 网络：`macvlan`
- 场景：在 NAS/宿主机中直接跑一个 OpenWrt/iStoreOS 容器

## 这个方案说明了什么

1. **它本质上不是“编译一个新的极简 iStoreOS”**
   - 而是直接复用现成的 ARM64 OpenWrt/iStoreOS 容器镜像。
   - 适合快速部署，不适合做深度裁剪和定制发行版。

2. **它证明“飞牛应用化”优先可以走容器路线**
   - 如果飞牛应用支持 Docker/Compose 类应用，这条路线最短。
   - 你的最终产品可以先做成“飞牛一键部署 iStoreOS 容器应用”。

3. **它依赖高权限网络能力**
   - `privileged: true` 表示容器需要接近宿主机级别权限。
   - `macvlan` 表示容器在局域网中拿一个独立 IP，适合作为旁路由。
   - 这对 OpenClash、策略路由、TUN、iptables/nftables 都很关键。

4. **它更像“应用封装”而不是“固件定制”**
   - 适合先验证 Web 管理、软件商店、旁路由、OpenClash 是否能跑通。
   - 后续再决定是否真的需要自己做极简镜像。

## 对本项目的启发

### 可行的双路线

#### 路线 1：先应用化（推荐先做 MVP）
- 基于现成 ARM64 iStoreOS 容器镜像
- 在飞牛中封装为应用
- 先验证：
  - Web 管理
  - 软件商店
  - OpenClash
  - 旁路由
- 成本低、见效快

#### 路线 2：再做极简化（第二阶段）
- 基于 OpenWrt / iStoreOS 源码重编译
- 裁剪 package、驱动、服务
- 形成自己的 ARM 版最小镜像
- 再替换容器基础镜像或转向更深度集成

## 当前关键技术点

1. **必须确认飞牛是否支持：**
   - `privileged: true`
   - `macvlan`
   - `parent` 指定宿主网卡
   - 自定义 IPAM
   - `/sbin/init` 作为入口

2. **如果飞牛不支持 macvlan**
   - 旁路由能力会明显受限
   - 只能退而求其次使用 host 网络或 bridge + 特权能力
   - 但很多透明代理场景会变复杂

3. **如果飞牛支持 Docker Compose 导入**
   - 可以先把这套 compose 改造成飞牛可导入模板
   - 再逐步换成自己的镜像和默认配置

## 对你项目的建议调整

### 新的优先级建议
1. 先验证飞牛应用是否允许高权限容器 + macvlan。
2. 若允许，先做“飞牛版 iStoreOS 容器应用 MVP”。
3. 在 MVP 跑通后，再做“极简 ARM 定制镜像”。

### MVP 交付物建议
- 一个飞牛可导入的 Compose/应用模板
- 预置 iStoreOS 容器镜像
- 默认网络/数据卷说明
- OpenClash 与旁路由初始化文档

## 风险
- `macvlan` 下宿主机与容器互通通常需要额外处理。
- `privileged` 在某些 NAS 应用中心可能被限制。
- 若 OEC / OECT 不是标准 ARM64 通用环境，现成镜像未必兼容。
