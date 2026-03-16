# 更新日志

## 1.2.0 - 2026-03-16

### 变更
- 引入混合挂载架构：MINextpay 与 UPTsmService 保持 Magisk 标准注入。
- 将 MITSMClient 迁移到 payload/MITSMClientGlobal，并在 post-fs-data 阶段通过 mount --bind 覆盖系统 MITSMClientGlobal。
- 调整 customize.sh 权限逻辑，补充 payload 目录与启动脚本权限设置。
- 修正目录冲突策略，避免双路径覆盖导致的异常扫描行为。

## 1.1.1 - 2026-03-16

### 修复
- 修复 customize.sh 中 NFC UID 检测逻辑，避免误清理数据。

## 1.1.0 - 2026-03-16

### 新增
- 移植小米智能卡 (MITSMClient) 至欧洲版（EEA）系统。
- 移植银联可信服务组件 (UPTsmService) 至欧洲版（EEA）系统。
- 移植小米智能卡网页组件 (MINextpay) 至欧洲版（EEA）系统。
- 恢复以下 NFC 功能：
  - 门禁卡模拟
  - 公交卡刷卡
  - 银行卡刷卡

### 注意
- 本版本为初始版本，可能存在未知问题。
- 请在使用前备份系统数据.
