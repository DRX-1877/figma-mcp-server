#!/bin/bash

# Figma MCP Server 安装脚本
# 自动创建虚拟环境、安装依赖并配置环境

set -e  # 遇到错误时退出

echo "🚀 开始安装 Figma MCP Server"
echo "   Starting Figma MCP Server installation..."

# 检查 Python 版本 / Check Python version
echo "📋 检查 Python 版本"
echo "   Checking Python version..."

# 尝试不同的 Python 版本
PYTHON_CMD=""
for cmd in python3.10 python3.11 python3.12 python3; do
    if command -v $cmd >/dev/null 2>&1; then
        version=$($cmd --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        required_version="3.10"
        if [ "$(printf '%s\n' "$required_version" "$version" | sort -V | head -n1)" = "$required_version" ]; then
            PYTHON_CMD=$cmd
            echo "✅ 找到合适的 Python 版本: $version ($cmd)"
            echo "   Found suitable Python version: $version ($cmd)"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "❌ 错误: 需要 Python 3.10 或更高版本"
    echo "   Error: Python 3.10 or higher required"
    echo "请安装 Python 3.10+ 或确保 python3.10 命令可用"
    echo "   Please install Python 3.10+ or ensure python3.10 command is available"
    exit 1
fi

# 创建虚拟环境
echo "🔧 创建虚拟环境"
echo "   Creating virtual environment..."
if [ -d "figma-mcp-env" ]; then
    echo "⚠️  虚拟环境已存在，正在删除..."
    echo "   Virtual environment exists, removing..."
    rm -rf figma-mcp-env
fi

$PYTHON_CMD -m venv figma-mcp-env
echo "✅ 虚拟环境创建成功"
echo "   Virtual environment created successfully"

# 激活虚拟环境
echo "🔌 激活虚拟环境"
echo "   Activating virtual environment..."
source figma-mcp-env/bin/activate

# 升级 pip
echo "⬆️  升级 pip"
echo "   Upgrading pip..."
pip install --upgrade pip

# 安装项目依赖
echo "📦 安装项目依赖"
echo "   Installing project dependencies..."
pip install -e .

# 检查安装
echo "🔍 验证安装"
echo "   Verifying installation..."
if python -c "import figma_mcp_server; print('✅ Figma MCP Server 模块导入成功')" 2>/dev/null; then
    echo "✅ 项目安装成功！"
    echo "   Project installed successfully!"
else
    echo "❌ 项目安装失败"
    echo "   Project installation failed"
    exit 1
fi

# 检查 MCP 依赖
if python -c "import mcp; print('✅ MCP 依赖安装成功')" 2>/dev/null; then
    echo "✅ MCP 依赖检查通过"
    echo "   MCP dependency check passed"
else
    echo "❌ MCP 依赖安装失败"
    echo "   MCP dependency installation failed"
    exit 1
fi

# 检查命令行工具
if command -v figma-mcp-server >/dev/null 2>&1; then
    echo "✅ 命令行工具安装成功"
    echo "   Command line tool installed successfully"
else
    echo "❌ 命令行工具安装失败"
    echo "   Command line tool installation failed"
    exit 1
fi

# 配置 PATH 环境变量
echo "🔧 配置 PATH 环境变量"
echo "   Configuring PATH environment variable..."
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
    echo "   Cannot detect shell type, please configure PATH manually"
    SHELL_CONFIG=""
fi

if [ -n "$SHELL_CONFIG" ]; then
    # 检查是否已经添加过
    if ! grep -q "figma-mcp-env/bin" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Figma MCP Server PATH" >> "$SHELL_CONFIG"
        echo "export PATH=\"$VENV_BIN_DIR:\$PATH\"" >> "$SHELL_CONFIG"
        echo "✅ 已添加到 $SHELL_CONFIG"
        echo "   Added to $SHELL_CONFIG"
    else
        echo "✅ PATH 已配置"
        echo "   PATH already configured"
    fi
    
    # 为当前会话设置 PATH
    export PATH="$VENV_BIN_DIR:$PATH"
    echo "✅ 当前会话 PATH 已更新"
    echo "   Current session PATH updated"
else
    echo "⚠️  请手动将以下路径添加到您的 PATH:"
    echo "   Please manually add the following path to your PATH:"
    echo "   export PATH=\"$VENV_BIN_DIR:\$PATH\""
fi

# 创建全局符号链接（可选）
echo "🔗 创建全局符号链接"
echo "   Creating global symlink..."
GLOBAL_BIN_DIRS=("/usr/local/bin" "$HOME/.local/bin" "$HOME/bin")

for bin_dir in "${GLOBAL_BIN_DIRS[@]}"; do
    if [ -d "$bin_dir" ] || [ -w "$(dirname "$bin_dir")" ]; then
        # 确保目录存在 / Ensure directory exists
        mkdir -p "$bin_dir" 2>/dev/null || continue
        
        # 创建符号链接 / Create symlink
        if [ -w "$bin_dir" ]; then
            ln -sf "$VENV_BIN_DIR/figma-mcp-server" "$bin_dir/figma-mcp-server"
            echo "✅ 已创建全局符号链接: $bin_dir/figma-mcp-server"
            echo "   Global symlink created: $bin_dir/figma-mcp-server"
            break
        fi
    fi
done

# 如果上面的目录都不可写，尝试使用 sudo / If directories above are not writable, try sudo
if ! command -v figma-mcp-server >/dev/null 2>&1; then
    echo "🔧 尝试使用 sudo 创建全局符号链接"
    echo "   Trying to create global symlink with sudo..."
    if sudo ln -sf "$VENV_BIN_DIR/figma-mcp-server" "/usr/local/bin/figma-mcp-server" 2>/dev/null; then
        echo "✅ 已创建全局符号链接: /usr/local/bin/figma-mcp-server"
        echo "   Global symlink created: /usr/local/bin/figma-mcp-server"
    else
        echo "⚠️  无法创建全局符号链接，请手动创建"
        echo "   Failed to create global symlink, please create manually:"
        echo "   sudo ln -sf $VENV_BIN_DIR/figma-mcp-server /usr/local/bin/figma-mcp-server"
    fi
fi

echo ""
echo "🎉 安装完成！"
echo "   Installation completed!"
echo ""
echo "📝 下一步操作："
echo "   Next steps:"
echo "1. 激活虚拟环境:"
echo "   Activate virtual environment:"
echo "   source figma-mcp-env/bin/activate"
echo ""
echo "2. 设置 Figma 访问令牌:"
echo "   Set Figma access token:"
echo "   export FIGMA_ACCESS_TOKEN='your_token_here'"
echo ""
echo "3. 测试安装:"
echo "   Test installation:"
echo "   figma-mcp-server --help"
echo ""
echo "4. 使用 MCP 配置（可选）:"
echo "   Use MCP configuration (optional):"
echo "   Add the following configuration to ~/.cursor/mcp.json:"
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
echo "💡 现在您可以在任何地方使用 figma-mcp-server 命令！"
echo "   Now you can use figma-mcp-server command anywhere!"
echo ""
echo "💡 提示: 每次使用前都需要激活虚拟环境"
echo "   Tip: You need to activate virtual environment before each use"
echo "   或者将激活命令添加到您的 shell 配置文件中"
echo "   Or add the activation command to your shell configuration file"
