#!/system/bin/sh
# 移除模块时，同时删掉 service.sh 装进 /data/app 的系统应用更新，
# 否则国行版会继续以"更新"的身份覆盖在系统自带的版本上。
(
    until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
    sleep 15
    for pkg in com.unionpay.tsmservice.mi com.miui.nextpay; do
        pm uninstall-system-updates "$pkg" >/dev/null 2>&1
    done
) &
