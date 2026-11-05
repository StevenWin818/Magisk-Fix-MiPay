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
   - 同时关闭对银联可信服务组件 (com.unionpay.tsmservice.mi) 与小米智能卡网页组件 (com.miui.nextpay) 的"卸载模块"功能，详见下文。
   - 如需刷卡时的灵动岛/通知，请同时关闭对系统 (android.uid.system，uid 1000，SystemUI 所在) 的"卸载模块"功能，详见下文。
   - 重启设备以加载模块。


## 工作原理补充

- **银联组件 / MINextpay**：KernelSU 默认的"卸载模块"会让被卸载的应用进程看不到 `/product` 下由模块挂载的 APK，银联组件会因此在启动时崩溃（读不到自身 APK）。请在 SU 管理器中对这两个应用关闭"卸载模块"。模块不会向 `/data` 安装任何应用，停用或移除模块即可完全还原。
- **刷卡通知 / 灵动岛**：智能卡发出的焦点通知需要 SystemUI 从智能卡 APK 中加载布局渲染。若 SystemUI (uid 1000) 被"卸载模块"，渲染会失败（日志 `Unable to open '/product/app/MITSMClient/MITSMClient.apk'`），通知随即被以 `REASON_ERROR` 删除。


## 注意事项

- 本项目仅适用于小米设备，且需运行基于 HyperOS 的系统。
- 请勿在未经备份的情况下修改系统文件。
- 已测试版本：
  - 小米 17 欧洲版 (EEA) OS3.0.12.0.WPCEUXM
  - 小米 15 欧洲版 (EEA) OS3.0.303.0.WOCEUXM（KernelSU）
- 其他版本未经测试，请自行测试兼容性。
- 已知问题：双击电源键唤起刷卡页的地区检测
  - 系统版本高于 OS3.0.300.0 时（该分界版本为推测，未经逐一验证），系统框架中可能存在针对"双击电源键唤起刷卡页"的地区检测（`MiInputShortcutFeature.isCnRegionWithCardSupport` / `isInternationalRegionWithCardSupport`）。前者要求系统地区为 CN；后者要求地区为部分港澳及东南亚地区，且 ROM 定义了 `support_international_access_card` 特性，而 EEA 等 ROM 并未定义该特性。两者都不满足时，开启"双击电源键唤起刷卡页"后双击无反应（日志 `Region restriction: mi_pay`），开机时该开关也会被系统清空。
  - 已在小米 15 欧洲版 (EEA) OS3.0.303.0.WOCEUXM 上确认存在该检测，小米 17 欧洲版 (EEA) OS3.0.12.0.WPCEUXM 则不存在。
  - 若开启后双击电源键无响应，请安装 LSPosed，再安装 [MiPayRegionDetectBypass](https://github.com/DuolaD/MiPayRegionDetectBypass) 模块（作用域勾选"系统框架"），重启设备后再次尝试。

## 构建与发布

- **一键打包**：`pwsh ./scripts/build.ps1`，产物输出至 `out/`；可用 `-VersionCode 2026082602` 指定版本号（默认按 UTC 日期自动生成）。
- **发版**：修改 `module/module.prop` 的 `version` 后打 tag（如 `v1.1.2`）并推送，CI 将自动打包、创建 GitHub Release 并回写 `Update/update.json`。

## 更新日志

更新日志请参阅 [Update/changelog.md](Update/changelog.md)。

## 免责声明

- 本项目为个人开发，非官方支持。使用本项目可能存在风险，开发者不对因使用本项目导致的任何问题负责。
- 本项目与 Xiaomi Inc. 无关。