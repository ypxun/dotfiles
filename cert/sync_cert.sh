# cert/sync_cert.sh

# 环境变量已由主模板注入，此处直接使用
TMP_DIR="/tmp/cert_sync_$(date +%s)"
CERT_FILE="cert.pem"
KEY_FILE="key.pem"

# 确保目标目录和临时目录存在
mkdir -p "$LOCAL_DIR"
mkdir -p "$TMP_DIR"

# 同步文件 (rclone 会自动识别环境变量中的配置)，并捕获错误
if ! rclone copy "$REMOTE_NAME:$BUCKET/$SUB_DIR/$CERT_FILE" "$TMP_DIR/" || \
   ! rclone copy "$REMOTE_NAME:$BUCKET/$SUB_DIR/$KEY_FILE" "$TMP_DIR/"; then
    logger -t sync_cert "CRITICAL: rclone failed to copy certificates. Check network or S3 credentials."
    rm -rf "$TMP_DIR"
    exit 1
fi

# 检查文件是否下载成功（冗余检查，以防万一）
if [ ! -f "$TMP_DIR/$CERT_FILE" ] || [ ! -f "$TMP_DIR/$KEY_FILE" ]; then
    logger -t sync_cert "ERROR: Downloaded files missing in $TMP_DIR."
    rm -rf "$TMP_DIR"
    exit 1
fi

# 对比 MD5，确认是否更新
if [ ! -f "$LOCAL_DIR/$CERT_FILE" ] || [ "$(md5sum "$TMP_DIR/$CERT_FILE" | awk '{print $1}')" != "$(md5sum "$LOCAL_DIR/$CERT_FILE" | awk '{print $1}')" ]; then
    cp "$TMP_DIR/$CERT_FILE" "$LOCAL_DIR/$CERT_FILE"
    cp "$TMP_DIR/$KEY_FILE" "$LOCAL_DIR/$KEY_FILE"
    
    # 设置权限 (私钥 600)
    chown root:root "$LOCAL_DIR/$CERT_FILE" "$LOCAL_DIR/$KEY_FILE"
    chmod 644 "$LOCAL_DIR/$CERT_FILE"
    chmod 600 "$LOCAL_DIR/$KEY_FILE"
    
    # 稍微歇个 0.5 秒，确保磁盘 I/O 写入和权限设置彻底完成
    sleep 0.5

    # 测试 Nginx 配置（不吞掉错误，或者如果测试失败，把错误写进 syslog）
    NGINX_TEST_OUTPUT=$(nginx -t 2>&1)
    if [ $? -eq 0 ]; then
        systemctl reload nginx
        logger -t sync_cert "SUCCESS: Nginx certificates updated and reloaded."
    else
        # 这样下次如果再错，你可以在 journalctl 里直接看到 Nginx 到底为什么报错
        logger -t sync_cert "CRITICAL: Nginx config test failed. Reason: $NGINX_TEST_OUTPUT"
        exit 1
    fi
else
    # 即使没更新，也可以记录一条
    logger -t sync_cert "INFO: Certificates are already up to date. No action taken."
fi

# 清理临时目录
rm -rf "$TMP_DIR"
