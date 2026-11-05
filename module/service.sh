#!/system/bin/sh

# 修改系统属性以支持本地化安全元件 (SE)
resetprop ro.vendor.se.type HCE,UICC,eSE

# 快捷手势开机无感自愈任务
(
    # 1. 等待系统开机完成，且等待用户首次解锁
    TIMEOUT=120
    COUNT=0
    while [ "$COUNT" -lt "$TIMEOUT" ]; do
        BOOT_COMPLETED=$(getprop sys.boot_completed)
        CE_READY=$(getprop sys.user.0.ce_available)
        if [ "$BOOT_COMPLETED" = "1" ] && [ "$CE_READY" = "true" ]; then
            break
        fi
        sleep 2
        COUNT=$((COUNT + 2))
    done

    # 2. 缓冲 3 秒，避开系统开机自检与重置时间窗口
    sleep 3

    PREF_XML="/data/data/com.miui.tsmclient/shared_prefs/pref_com_miui_tsmclient.xml"
    [ ! -f "$PREF_XML" ] && PREF_XML="/data/user/0/com.miui.tsmclient/shared_prefs/pref_com_miui_tsmclient.xml"

    # 3. 此时已安全解密，精准读取用户在钱包中的真实意图：
    # 仅当用户在钱包中开启了双击刷卡（value="true"），且当前系统设置被系统抹成了 none/空值时，才精准恢复一次
    if [ -f "$PREF_XML" ] && grep -q 'key_has_set_double_press_power_key.*true' "$PREF_XML" 2>/dev/null; then
        CURRENT_VAL=$(settings get system double_click_power_key 2>/dev/null)
        if [ "$CURRENT_VAL" = "none" ] || [ "$CURRENT_VAL" = "null" ] || [ -z "$CURRENT_VAL" ]; then
            settings put system double_click_power_key mi_pay
        fi
    fi

    # 4. 执行完毕后即刻完全销毁
    exit 0
) &
