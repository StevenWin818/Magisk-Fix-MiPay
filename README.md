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
   - 如需刷卡时的灵动岛/通知，请同时关闭对系统 (android.uid.system，uid 1000，SystemUI 所在) 的"卸载模块"功能，详见下文。
   - 重启设备以加载模块。


## 工作原理补充

- **银联组件 / MINextpay 装入 `/data/app`**：KernelSU 默认的"卸载模块"会让普通应用看不到 `/product` 下由模块挂载的 APK，银联组件会因此在启动时崩溃。`service.sh` 会在开机后把这两个 APK 以"系统应用更新"的形式再安装一次到 `/data/app`（只在需要时执行，结果记录在模块目录的 `service.log`），卸载模块时由 `uninstall.sh` 移除。
- **小米智能卡不能装入 `/data/app`**：它以平台签名加入 `android.uid.nfc` 共享 UID，且系统中存在被屏蔽的、版本号更高的国际版 `MITSMClientGlobal`。实测重启后系统会判定更新无效，并连同数据删除整个包。因此智能卡仍从 `/product` 加载。
- **刷卡通知 / 灵动岛**：智能卡发出的焦点通知需要 SystemUI 从智能卡 APK 中加载布局渲染。若 SystemUI (uid 1000) 被"卸载模块"，渲染会失败（日志 `Unable to open '/product/app/MITSMClient/MITSMClient.apk'`），通知随即被以 `REASON_ERROR` 删除。


## 注意事项

- 本项目仅适用于小米设备，且需运行基于 HyperOS 的系统。
- 请勿在未经备份的情况下修改系统文件。
- 已测试版本：
  - 小米 17 欧洲版 (EEA) OS3.0.12.0.WPCEUXM
  - 小米 15 欧洲版 (EEA) OS3.0.303.0.WOCEUXM（KernelSU）
- 其他版本未经测试，请自行测试兼容性。
- 已知问题：较新的系统（如小米 15 EEA OS3.0.303.0.WOCEUXM）在系统框架 `ShortCutActionsUtils` 中加入了地区检查（`MiInputShortcutFeature.isCnRegionWithCardSupport` / `isInternationalRegionWithCardSupport`），非 CN 及部分港澳、东南亚地区时，"双击电源键唤起刷卡页"无反应（日志 `Region restriction: mi_pay`），开机时该开关也会被系统清空。需借助 Xposed 等方式解除该检查，本模块未处理。

## 构建与发布

- **一键打包**：`pwsh ./scripts/build.ps1`，产物输出至 `out/`；可用 `-VersionCode 2026082602` 指定版本号（默认按 UTC 日期自动生成）。
- **发版**：修改 `module/module.prop` 的 `version` 后打 tag（如 `v1.1.2`）并推送，CI 将自动打包、创建 GitHub Release 并回写 `Update/update.json`。
## 更新日志

更新日志请参阅 [Update/changelog.md](Update/changelog.md)。

## 免责声明

- 本项目为个人开发，非官方支持。使用本项目可能存在风险，开发者不对因使用本项目导致的任何问题负责。
- 本项目与 Xiaomi Inc. 无关。