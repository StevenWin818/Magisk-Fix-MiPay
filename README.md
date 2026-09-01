# FixMiPay

## 项目简介
FixMiPay 项目旨在将 HyperOS 国行版（CN）中的小米智能卡 (MITSMClient)、银联可信服务组件 (UPTsmService) 和小米智能卡网页组件 (MINextpay) 完整移植到欧洲版（EEA）系统中，从而恢复欧洲版（或其他小米系统版本）设备的以下 NFC 功能：

- 门禁卡模拟
- 公交卡刷卡
- 银行卡刷卡


## 使用说明

1. **准备工作**
   - 确保设备已解锁并安装了 Magisk 或 KernelSU 等模块管理器。

2. **安装步骤**
   - 使用 Magisk Manager 或 KernelSU 等工具安装.zip文件。
   - 请在 SU 管理器中手动关闭对 NFC (android.uid.nfc) 的"卸载模块"功能。
   - 重启设备以加载模块。


## 注意事项

- 本项目仅适用于小米设备，且需运行基于 HyperOS 的系统。
- 请勿在未经备份的情况下修改系统文件。
- 仅在小米 17 欧洲版 (EEA) OS3.0.12.0.WPCEUXM 版本进行测试，其他版本未经测试，请自行测试兼容性。

## 构建与发布

- **一键打包**：`pwsh ./scripts/build.ps1`，产物输出至 `out/`；可用 `-VersionCode 2026082602` 指定版本号（默认按 UTC 日期自动生成）。
- **发版**：修改 `module/module.prop` 的 `version` 后打 tag（如 `v1.1.2`）并推送，CI 将自动打包、创建 GitHub Release 并回写 `Update/update.json`。

## 更新日志

更新日志请参阅 [Update/changelog.md](Update/changelog.md)。

## 免责声明

- 本项目为个人开发，非官方支持。使用本项目可能存在风险，开发者不对因使用本项目导致的任何问题负责。
- 本项目与 Xiaomi Inc. 无关。