# cert/sync_cert.sh

# 环境变量已由主模板注入，此处直接使用
TMP_DIR="/tmp/cert_sync_$(date +%s)"
CERT_FILE="cert.pem"
KEY_FILE="key.pem"

# 确保目标目录和临时目录存在
mkdir -p "$LOCAL_DIR"
mkdir -p "$TMP_DIR"

# 同步文件 (rclone 会自动识别环境变量中的配置)
rclone copy "$REMOTE_NAME:$BUCKET/$SUB_DIR/$CERT_FILE" "$TMP_DIR/"
rclone copy "$REMOTE_NAME:$BUCKET/$SUB_DIR/$KEY_FILE" "$TMP_DIR/"

# 检查文件是否下载成功
if [ ! -f "$TMP_DIR/$CERT_FILE" ]; then
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
    
    # 测试并重载 Nginx
    nginx -t && systemctl reload nginx
fi

# 清理临时目录
rm -rf "$TMP_DIR"