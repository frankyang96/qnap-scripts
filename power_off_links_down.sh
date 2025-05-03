#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

LOG_FILE="/share/homes/admin/power_check.log"
MAX_LOG_SIZE=$((30 * 1024 * 1024))  # 3MB

# 日志截断函数：超过30MB则截掉前50%
truncate_log_if_oversize() {
    if [ -f "${LOG_FILE}" ]; then
        local size
        size=$(stat -c%s "${LOG_FILE}")
        if [ "${size}" -gt "${MAX_LOG_SIZE}" ]; then
            log "Log file exceeds 3MB, truncating..."
            local half_size=$((size / 2))
            tail -c "${half_size}" "${LOG_FILE}" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "${LOG_FILE}"
        fi
    fi
}

# 日志记录函数
log() {
    local message="$1"
    truncate_log_if_oversize
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> "${LOG_FILE}"
}

# 尝试 ping 3 次，每次间隔 5 秒
check_ping_with_retry() {
    local target_ip="192.168.50.1"
    local attempts=3
    local delay=5

    for i in $(seq 1 $attempts); do
        if ping -c 1 -w 5 "${target_ip}" > /dev/null 2>&1; then
            log "Ping successful on attempt ${i}."
            return 0
        else
            log "Ping attempt ${i} failed."
            sleep "${delay}"
        fi
    done

    return 1  # 所有尝试都失败
}

# 检查指定接口是否 NO-CARRIER
is_interface_no_carrier() {
    local iface="$1"
    if ip link show "${iface}" | grep -q 'NO-CARRIER'; then
        return 0
    else
        return 1
    fi
}

# 检查 eth0 和 eth1 是否都是 NO-CARRIER
check_links() {
    if is_interface_no_carrier "eth0" && is_interface_no_carrier "eth1"; then
        return 0
    else
        return 1
    fi
}

# 关机
power_off() {
    log "Shutting down system..."
#    /sbin/poweroff
}

# 主函数
main() {
    if ! check_ping_with_retry; then
        log "Ping failed after 3 attempts, checking link status."

        if check_links; then
            log "Both eth0 and eth1 are NO-CARRIER, powering off."
            power_off
        else
            log "At least one link is UP, no action needed."
        fi
    else
        log "Ping successful, no action needed."
    fi
}

# 执行主函数
main
