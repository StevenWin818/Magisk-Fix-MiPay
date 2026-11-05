#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/service.log"

# 修改系统属性以支持本地化安全元件 (SE)
resetprop ro.vendor.se.type HCE,UICC,eSE

# 把模块里的 APK 再以"系统应用更新"的形式装进 /data/app。
# KernelSU 默认的"卸载模块"会让 SystemUI、桌面等进程看不到 /product 下由模块挂载的 APK，
# 导致刷卡焦点通知渲染失败 (REASON_ERROR)、桌面快捷方式的图标与标签无法加载。
# /data/app 不受影响，所有进程都能读到。签名与系统包一致（平台密钥），共享 UID 与数据都会保留。
# 只在系统仍从 /product 加载、或模块内 APK 有变化（模块升级）时安装一次。
install_as_update() {
    pkg=$1
    apk="$MODDIR/system/product/app/$2/$2.apk"
    stamp="$MODDIR/.installed_$pkg"
    [ -f "$apk" ] || return
    sum=$(sha256sum "$apk" | cut -d' ' -f1)
    code_path=$(dumpsys package "$pkg" 2>/dev/null | grep -m1 "codePath=" | sed 's/.*codePath=//')
    case "$code_path" in
        /data/app/*) [ "$(cat "$stamp" 2>/dev/null)" = "$sum" ] && return ;;
    esac
    res=$(pm install -r "$apk" 2>&1)
    echo "$(date '+%F %T') $pkg: $code_path -> $res" >> "$LOG"
    case "$res" in *Success*) echo "$sum" > "$stamp" ;; esac
}

(
    until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done
    sleep 10
    # 注意：小米智能卡 (com.miui.tsmclient) 不能这样处理。它通过平台签名加入 android.uid.nfc 共享 UID，
    # 而系统还记着被 .replace 屏蔽掉的国际版 MITSMClientGlobal（版本号更高），重启后会把 /data 里的
    # 更新判定为无效并连同数据删除整个包。
    install_as_update com.unionpay.tsmservice.mi UPTsmService
    install_as_update com.miui.nextpay MINextpay
) &

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
