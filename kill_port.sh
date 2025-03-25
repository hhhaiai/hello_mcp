#!/bin/bash

# 函数：kill_port
# 描述：检查指定端口是否被占用，并终止占用该端口的进程
# 参数：$1 - 端口号
kk() {
    local port=$1
    
    # 检查是否提供了端口号
    if [ -z "$port" ]; then
        echo "错误: 请提供端口号"
        echo "用法: kill_port <端口号>"
        return 1
    fi
    
    # 检查端口号是否为数字
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "错误: 端口号必须是数字"
        return 1
    fi
    
    # 使用lsof查找占用该端口的进程
    local pid=$(lsof -ti :$port)
    
    # 检查是否有进程占用该端口
    if [ -z "$pid" ]; then
        echo "端口 $port 当前没有被占用"
        return 0
    fi
    
    # 显示将被终止的进程信息
    echo "以下进程正在占用端口 $port:"
    lsof -i :$port
    
    # 终止进程
    echo "正在终止进程..."
    kill -9 $pid
    
    # 验证进程是否已终止
    if [ -z "$(lsof -ti :$port)" ]; then
        echo "成功: 占用端口 $port 的进程已被终止"
        return 0
    else
        echo "错误: 无法终止占用端口 $port 的进程"
        return 1
    fi
}

# 如果直接执行此脚本（而不是作为库导入），则运行kill_port函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    kk "$@"
fi