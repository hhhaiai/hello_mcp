#!/bin/bash

# 函数：kill_port
# 描述：终止占用指定端口的进程（macOS 兼容版）
# 参数：$1 - 端口号
# 返回：
#   0: 成功 | 1: 参数错误 | 2: 权限不足 | 3: 终止失败
kill_port() {
    local port="${1}"
    local pids pid_list=()

    # 参数校验
    if [[ -z "${port}" ]]; then
        echo >&2 "错误：必须指定端口号"
        echo >&2 "用法: kill_port <端口号>"
        return 1
    fi

    if ! [[ "${port}" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
        echo >&2 "错误：无效端口号 '${port}'"
        return 1
    fi

    # 查找占用进程（macOS/BSD 兼容模式）
    pids=$(lsof -ti :"${port}" 2>/dev/null | sort -u)
    [[ -z "${pids}" ]] && return 0

    # 转换为数组（处理多个PID）
    read -r -a pid_list <<< "${pids}"

    # 显示进程信息（兼容 macOS lsof 输出）
    echo "以下进程正在占用 ${port} 端口："
    lsof -i :"${port}" | awk '
        NR == 1 {printf "%-10s %-20s %s\n", "PID", "USER", "COMMAND"}
        NR > 1 {printf "%-10s %-20s %s\n", $2, $3, (NF>8 ? $9 : "N/A")}
    '

    # 终止进程
    echo -n "正在终止进程（PID: ${pid_list[@]}）..."
    if ! kill -9 "${pid_list[@]}" >/dev/null 2>&1; then
        if [[ "$(uname)" == "Darwin" ]]; then
            echo >&2 "失败：需要管理员权限"
            echo >&2 "请尝试: sudo kill -9 ${pid_list[@]}"
        else
            echo >&2 "错误：进程终止失败"
        fi
        return 2
    fi

    # 二次验证（等待系统释放端口）
    local wait_seconds=3
    while (( wait_seconds-- > 0 )); do
        sleep 1
        [[ -z "$(lsof -ti :${port} 2>/dev/null)" ]] && break
    done

    if [[ -n "$(lsof -ti :${port} 2>/dev/null)" ]]; then
        echo >&2 "警告：仍有进程占用端口"
        return 3
    fi

    echo "成功"
    return 0
}

# 直接执行时调用函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    kill_port "$@"
    exit $?
fi