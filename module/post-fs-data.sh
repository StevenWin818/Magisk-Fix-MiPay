#!/system/bin/sh
MODDIR=${0%/*}

SOURCE_DIR="$MODDIR/payload/MITSMClientGlobal"
TARGET_DIR="/product/app/MITSMClientGlobal"

if [ ! -d "$TARGET_DIR" ]; then
    TARGET_DIR="/system/product/app/MITSMClientGlobal"
fi

if [ -d "$SOURCE_DIR" ] && [ -d "$TARGET_DIR" ]; then
    mount --bind "$SOURCE_DIR" "$TARGET_DIR"
fi
