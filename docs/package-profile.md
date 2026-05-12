# 极简包配置草案（旁路由 + OpenClash 专用）

## 目标
把现有 ARM64 iStoreOS 容器精简成“仅用于旁路由 + OpenClash”的版本，优先保留可用性，其次再压缩体积。

当前明确原则：
- **保留软件商店**
- **保留多语言包**
- **第一轮只删：多媒体、打印、蓝牙、下载器、多余主题**

---

## A. 必保留

### 1. 基础系统
- base-files
- busybox
- procd
- ubus
- ubusd
- uci
- libuci
- netifd
- jsonfilter
- jshn
- fstools（按镜像结构保留）
- logd / urandom-seed 等基础服务

### 2. Web 管理最小集
- luci
- luci-base
- luci-mod-admin-full
- 至少保留一个主题（当前先保留默认主题）
- rpcd
- rpcd-mod-uci
- rpcd-mod-file
- uhttpd
- uhttpd-mod-ubus
- luci-compat（若依赖需要）

### 3. 软件商店
- istore
- luci-app-store
- 软件商店后端依赖
- 商店运行所需主题/前端依赖

### 4. 旁路由核心
- firewall4
- nftables
- ip-full
- iptables-nft
- dnsmasq-full
- mwan3（仅在明确需要多 WAN/策略分流时保留）
- ipset / fw4 相关依赖（按 OpenClash 需求保留）
- ca-bundle
- ca-certificates
- curl
- wget-ssl（若脚本依赖）

### 5. OpenClash 核心依赖
- luci-app-openclash
- kmod-tun
- kmod-nft-tproxy
- kmod-ipt-tproxy
- kmod-nf-tproxy
- kmod-netfilter-tproxy
- bash
- coreutils
- coreutils-nohup
- jq
- yq（若 OpenClash 脚本依赖该实现）
- unzip
- tar
- gzip
- flock
- dnsmasq-full
- iptables-zz-legacy / nft 兼容组件（按实际镜像测试决定）
- zoneinfo-core / time sync 相关组件

### 6. 调试与维护
- dropbear 或 openssh-server（建议二选一，优先 dropbear）
- block-mount（如果配置持久化依赖挂载逻辑）

### 7. 多语言
- 当前镜像内已有多语言包先全部保留
- LuCI 中文等语言包先不裁

---

## B. 第一轮明确可裁剪

### 1. 多媒体
- 音视频播放/转码相关组件
- DLNA/媒体库相关服务
- 无关编解码工具

### 2. 打印
- cups 相关组件
- p910nd 等打印服务

### 3. 蓝牙
- bluez 相关组件
- 蓝牙工具链

### 4. 下载器
- aria2
- qBittorrent
- transmission
- 相关 LuCI 前端与后端依赖

### 5. 多余主题
- 除默认主题外的其他主题包
- 但不要删除主题通用依赖

---

## C. 暂不裁剪

以下内容按你的当前要求，第一轮先不动：
- 软件商店
- 多语言包
- Samba / NFS / FTP（若镜像中存在，先不动）
- PPP / 3G / 4G 拨号组件
- 非核心 VPN 套件
- 无关文件系统支持
- IPv6 全套

---

## D. 谨慎移除

这些经常是“看起来不重要，删了就炸”：
- rpcd 相关模块
- uhttpd-mod-ubus
- dnsmasq-full
- firewall4
- iptables/nft 兼容层
- bash / coreutils / jq
- 时间同步与证书包
- istore / luci-app-store 的后端依赖

---

## E. 推荐的最小产品定义

### 当前阶段建议保留：
1. Web 管理
2. 软件商店
3. 多语言
4. OpenClash
5. 旁路由网络能力
6. 基础 SSH/调试能力

### 第一轮不再追求：
1. 一次性裁到极限
2. 大幅动系统底层依赖
3. 先删商店或语言包

---

## F. 实现路线建议

### 路线 1：先在现有镜像上二次裁剪
- 基于现成可运行镜像
- 编写 Dockerfile / 首启脚本删除第一轮目标包
- 快速验证极简版是否还能跑 OpenClash、软件商店和 LuCI

优点：快
缺点：不够干净

### 路线 2：基于源码重新编译最小镜像
- 从 iStoreOS/OpenWrt 配置入手
- 精确控制包选择
- 得到真正干净的镜像

优点：干净、可控
缺点：构建成本高

> 建议顺序：**先走路线 1 找边界，再走路线 2 做正式版。**

---

## G. 下一步待定项
1. 默认保留哪个主题。
2. 软件商店里是否要限制展示分类。
3. SSH 是否仅开发版保留。
4. OpenClash 核心是在线下载还是镜像内预置。
