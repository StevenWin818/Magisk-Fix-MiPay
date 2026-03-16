# ==========================================================
# Magisk / KernelSU 模块自定义安装脚本
# ==========================================================

ui_print "- 正在安装 HyperOS EEA to CN NFC Port..."
ui_print "- 正在挂载系统目录..."

# 设置文件与目录权限 (非常关键)
set_perm_recursive "$MODPATH/system/product/app/MITSMClient" 0 0 0755 0644
set_perm_recursive "$MODPATH/system/product/app/UPTsmService" 0 0 0755 0644
set_perm_recursive "$MODPATH/system/product/app/MINextpay" 0 0 0755 0644

ui_print "- 正在清理可能导致 UID 冲突的残留数据..."
rm -rf /data/data/com.miui.tsmclient
rm -rf /data/user_de/0/com.miui.tsmclient

ui_print "- 请手动关闭对NFC (android.uid.nfc) 的\"卸载模块\"功能。"

ui_print "- 安装完成！请重启设备以应用更改。"