# 更新日志

## 未发布

### 说明
- 银联可信服务组件 (UPTsmService) 在 KernelSU"卸载模块"下会因读不到自身 APK 而启动即崩溃：需在 SU 管理器中关闭对 com.unionpay.tsmservice.mi 与 com.miui.nextpay 的"卸载模块"功能。
- 刷卡灵动岛/通知需在 SU 管理器中关闭对 android.uid.system (uid 1000) 的"卸载模块"功能。

## 1.2.0 - 2026-09-02

### 修复
- 修复 Global 系统设备重启后“双击电源键唤起刷卡页”开关被系统自动关闭重置的问题。

## 1.1.1 - 2026-03-16

### 修复
- 修复 customize.sh 中 NFC UID 检测逻辑，避免误清理数据。

## 1.1.0 - 2026-03-16

### 新增
- 移植小米智能卡 (MITSMClient) 至 Global 系统。
- 移植银联可信服务组件 (UPTsmService) 至 Global 系统。
- 移植小米智能卡网页组件 (MINextpay) 至 Global 系统。
- 恢复以下 NFC 功能：
  - 门禁卡模拟
  - 公交卡刷卡
  - 银行卡刷卡
