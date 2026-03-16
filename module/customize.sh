# ==========================================================
# Magisk / KernelSU 模块自定义安装脚本
# ==========================================================

ui_print "- 正在安装 HyperOS EEA to CN NFC Port..."
ui_print "- 正在部署混合架构系统文件..."

# 1) 设置 Magisk 标准注入目录权限
if [ -d "$MODPATH/system/product/app" ]; then
    set_perm_recursive "$MODPATH/system/product/app" 0 0 0755 0644
fi

# 2) 设置 payload 目录权限 (供 bind 挂载使用)
if [ -d "$MODPATH/payload" ]; then
    set_perm_recursive "$MODPATH/payload" 0 0 0755 0644
fi

# 3) 确保启动脚本可执行
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755

ui_print "- 正在检查 UID 状态与应用数据..."
TSM_DATA_DIR="/data/data/com.miui.tsmclient"

if [ -d "$TSM_DATA_DIR" ]; then
    # 获取当前数据目录的所属 UID
    TSM_UID=$(stat -c '%u' "$TSM_DATA_DIR")
    
    # 1027 为系统级 android.uid.nfc 的硬编码 UID
    if [ "$TSM_UID" -eq 1027 ]; then
        ui_print "- 检测到已正确分配 NFC UID (1027)，保留现有门禁卡与配置数据。"
    else
        ui_print "- 检测到旧版独立 UID 冲突 ($TSM_UID)，正在清理以重置环境..."
        rm -rf /data/data/com.miui.tsmclient
        rm -rf /data/user_de/0/com.miui.tsmclient
    fi
else
    ui_print "- 未检测到旧数据目录，执行首次干净安装。"
fi

# ui_print "- 请手动关闭对NFC (android.uid.nfc) 的\"卸载模块\"功能。"

ui_print "- 安装完成！请重启设备以应用更改。"