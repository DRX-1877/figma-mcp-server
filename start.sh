#!/bin/bash

# Figma MCP Server 快速启动脚本

echo "🚀 启动 Figma MCP Server..."

# 检查虚拟环境是否存在
if [ ! -d "figma-mcp-env" ]; then
    echo "❌ 虚拟环境不存在，请先运行 ./install.sh 进行安装"
    exit 1
fi

# 激活虚拟环境
echo "🔌 激活虚拟环境..."
source figma-mcp-env/bin/activate

# 检查 Figma 访问令牌
if [ -z "$FIGMA_ACCESS_TOKEN" ]; then
    echo "⚠️  警告: 未设置 FIGMA_ACCESS_TOKEN 环境变量"
    echo "请设置您的 Figma 访问令牌:"
    echo "export FIGMA_ACCESS_TOKEN='your_token_here'"
    echo ""
fi

# 启动服务器
echo "🎯 启动 MCP 服务器..."
figma-mcp-server
