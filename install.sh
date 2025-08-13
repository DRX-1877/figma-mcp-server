#!/bin/bash

# Figma MCP Server 安装脚本
# 自动创建虚拟环境、安装依赖并配置环境

set -e  # 遇到错误时退出

echo "🚀 开始安装 Figma MCP Server..."

# 检查 Python 版本
echo "📋 检查 Python 版本..."

# 尝试不同的 Python 版本
PYTHON_CMD=""
for cmd in python3.10 python3.11 python3.12 python3; do
    if command -v $cmd >/dev/null 2>&1; then
        version=$($cmd --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        required_version="3.10"
        if [ "$(printf '%s\n' "$required_version" "$version" | sort -V | head -n1)" = "$required_version" ]; then
            PYTHON_CMD=$cmd
            echo "✅ 找到合适的 Python 版本: $version ($cmd)"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "❌ 错误: 需要 Python 3.10 或更高版本"
    echo "请安装 Python 3.10+ 或确保 python3.10 命令可用"
    exit 1
fi

# 创建虚拟环境
echo "🔧 创建虚拟环境..."
if [ -d "figma-mcp-env" ]; then
    echo "⚠️  虚拟环境已存在，正在删除..."
    rm -rf figma-mcp-env
fi

$PYTHON_CMD -m venv figma-mcp-env
echo "✅ 虚拟环境创建成功"

# 激活虚拟环境
echo "🔌 激活虚拟环境..."
source figma-mcp-env/bin/activate

# 升级 pip
echo "⬆️  升级 pip..."
pip install --upgrade pip

# 安装项目依赖
echo "📦 安装项目依赖..."
pip install -e .

# 检查安装
echo "🔍 验证安装..."
if python -c "import figma_mcp_server; print('✅ Figma MCP Server 模块导入成功')" 2>/dev/null; then
    echo "✅ 项目安装成功！"
else
    echo "❌ 项目安装失败"
    exit 1
fi

# 检查 MCP 依赖
if python -c "import mcp; print('✅ MCP 依赖安装成功')" 2>/dev/null; then
    echo "✅ MCP 依赖检查通过"
else
    echo "❌ MCP 依赖安装失败"
    exit 1
fi

# 检查命令行工具
if command -v figma-mcp-server >/dev/null 2>&1; then
    echo "✅ 命令行工具安装成功"
else
    echo "❌ 命令行工具安装失败"
    exit 1
fi

# 配置 PATH 环境变量
echo "🔧 配置 PATH 环境变量..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_BIN_DIR="$SCRIPT_DIR/figma-mcp-env/bin"

# 检测 shell 类型
SHELL_CONFIG=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
    if [ ! -f "$SHELL_CONFIG" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    fi
else
    echo "⚠️  无法检测 shell 类型，请手动配置 PATH"
    SHELL_CONFIG=""
fi

if [ -n "$SHELL_CONFIG" ]; then
    # 检查是否已经添加过
    if ! grep -q "figma-mcp-env/bin" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Figma MCP Server PATH" >> "$SHELL_CONFIG"
        echo "export PATH=\"$VENV_BIN_DIR:\$PATH\"" >> "$SHELL_CONFIG"
        echo "✅ 已添加到 $SHELL_CONFIG"
    else
        echo "✅ PATH 已配置"
    fi
    
    # 为当前会话设置 PATH
    export PATH="$VENV_BIN_DIR:$PATH"
    echo "✅ 当前会话 PATH 已更新"
else
    echo "⚠️  请手动将以下路径添加到您的 PATH:"
    echo "   export PATH=\"$VENV_BIN_DIR:\$PATH\""
fi

echo ""
echo "🎉 安装完成！"
echo ""
echo "📝 下一步操作："
echo "1. 激活虚拟环境:"
echo "   source figma-mcp-env/bin/activate"
echo ""
echo "2. 设置 Figma 访问令牌:"
echo "   export FIGMA_ACCESS_TOKEN='your_token_here'"
echo ""
echo "3. 测试安装:"
echo "   figma-mcp-server --help"
echo ""
echo "4. 使用 MCP 配置（可选）:"
echo "   将以下配置添加到 ~/.cursor/mcp.json:"
echo "   {"
echo "     \"mcpServers\": {"
echo "       \"figma-tools\": {"
echo "         \"command\": \"figma-mcp-server\","
echo "         \"env\": {"
echo "           \"FIGMA_ACCESS_TOKEN\": \"your_token_here\""
echo "         }"
echo "       }"
echo "     }"
echo "   }"
echo ""
echo "💡 提示: 每次使用前都需要激活虚拟环境"
echo "   或者将激活命令添加到您的 shell 配置文件中"
