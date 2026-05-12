# 极简 ARM 版 iStoreOS → 飞牛应用 Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** 面向 OEC / OECT 设备构建一个极简 ARM 版 iStoreOS，保留 Web 管理、软件商店、旁路由能力，并内置 OpenClash，最终封装为飞牛应用。

**Architecture:** 以 iStoreOS/OpenWrt 为系统底座，先完成目标硬件映射与最小镜像裁剪，再补齐 OpenClash 与旁路由链路，最后做飞牛应用封装。项目优先保证可编译、可启动、可管理、可旁路由，再考虑应用化交付。

**Tech Stack:** OpenWrt / iStoreOS buildroot, kernel config, LuCI, iStore, OpenClash, shell scripts, Makefile, 飞牛应用封装元数据。

---

## Phase 0：需求冻结

### Task 0.1：确认设备映射
**Objective:** 明确 OEC / OECT 对应的芯片平台、启动方式和 OpenWrt target。

**Files:**
- Modify: `docs/device-matrix.md`

**Steps:**
1. 收集 OEC / OECT 的具体型号。
2. 记录 SoC、RAM、Flash/eMMC、网口、启动方式。
3. 映射到 OpenWrt target/subtarget。
4. 标注是否已有现成 DTS / 社区支持。

### Task 0.2：确认飞牛应用运行模型
**Objective:** 判断最终交付是容器型、插件型还是宿主扩展型。

**Files:**
- Modify: `docs/fn-app-model.md`

**Steps:**
1. 梳理飞牛应用包格式。
2. 确认网络权限、特权模式、持久化目录能力。
3. 判断旁路由能力能否在该模型内成立。
4. 给出推荐集成方式。

---

## Phase 1：项目脚手架

### Task 1.1：建立仓库目录
**Objective:** 建立源码、配置、补丁、封装、文档分层。

**Files:**
- Create: `build/`
- Create: `config/`
- Create: `patches/`
- Create: `packages/`
- Create: `fn-app/`
- Create: `docs/`

### Task 1.2：写基础说明文档
**Objective:** 固化当前目标、范围、风险与开发顺序。

**Files:**
- Modify: `README.md`
- Modify: `docs/implementation-plan-v0.1.md`

---

## Phase 2：极简镜像裁剪

### Task 2.1：定义必选组件清单
**Objective:** 明确保留组件与依赖边界。

**Files:**
- Create: `docs/package-profile.md`

**保留核心：**
- `luci`
- `uhttpd`
- `rpcd`
- `ubus`
- `istore`
- `luci-app-store`
- `openclash`（或对应 feed 包）
- `dnsmasq-full`
- `ip-full`
- `iptables-nft` / `nftables`
- `kmod-tun`
- `ca-bundle`
- `curl`
- `bash`
- `openssh-server`

**裁剪方向：**
- 多余文件系统
- 多余无线驱动
- 非必需 VPN
- 下载器、多媒体、打印、蓝牙等无关包

### Task 2.2：产出首版 `.config` 策略
**Objective:** 形成第一版最小可编译配置。

**Files:**
- Create: `config/oec-minimal.config`
- Create: `config/packages-oec.txt`

### Task 2.3：定义 feed 与第三方包来源
**Objective:** 固化 iStore 与 OpenClash 的来源和版本策略。

**Files:**
- Create: `build/feeds.conf.fragment`
- Create: `docs/feeds-strategy.md`

---

## Phase 3：旁路由与 OpenClash 验证

### Task 3.1：定义旁路由运行前提
**Objective:** 明确 LAN/WAN、默认网关、DNS 劫持、透明代理路径。

**Files:**
- Create: `docs/bypass-router-design.md`

### Task 3.2：定义 OpenClash 依赖矩阵
**Objective:** 列出内核模块、用户态依赖、策略路由依赖。

**Files:**
- Create: `docs/openclash-deps.md`

### Task 3.3：确定预置与首次启动策略
**Objective:** 决定 OpenClash 核心、默认配置、订阅导入方式。

**Files:**
- Create: `packages/openclash-defaults/README.md`
- Create: `packages/openclash-defaults/files/etc/uci-defaults/99-openclash-defaults`

---

## Phase 4：飞牛应用封装

### Task 4.1：定义应用目录结构
**Objective:** 规划 manifest、启动脚本、配置映射与数据卷。

**Files:**
- Create: `fn-app/README.md`
- Create: `fn-app/manifest.example.json`
- Create: `fn-app/scripts/start.sh`
- Create: `fn-app/scripts/stop.sh`

### Task 4.2：设计持久化策略
**Objective:** 确定配置、插件数据、日志、订阅文件的挂载点。

**Files:**
- Create: `docs/persistence-layout.md`

### Task 4.3：设计升级与回滚策略
**Objective:** 保证飞牛应用升级不破坏配置与订阅。

**Files:**
- Create: `docs/upgrade-strategy.md`

---

## 当前建议优先级
1. 先补全 OEC / OECT 设备矩阵。
2. 再确认飞牛应用运行模型。
3. 然后输出包清单与首版构建配置。
4. 最后再开做飞牛封装。
