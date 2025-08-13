#!/bin/bash

# Figma MCP Server 命令修复脚本
# 用于修复 figma-mcp-server 命令不可用的问题

set -e

echo "🔧 Figma MCP Server 命令修复工具"
echo "   Figma MCP Server Command Fix Tool"
echo ""

# 检查项目目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -d "$SCRIPT_DIR/figma-mcp-env" ]; then
    echo "❌ 错误: 未找到虚拟环境，请先运行 install.sh"
    echo "   Error: Virtual environment not found, please run install.sh first"
    exit 1
fi

VENV_BIN_DIR="$SCRIPT_DIR/figma-mcp-env/bin"
FIGMA_CMD="$VENV_BIN_DIR/figma-mcp-server"

# 检查虚拟环境中的命令是否存在
if [ ! -f "$FIGMA_CMD" ]; then
    echo "❌ 错误: 虚拟环境中未找到 figma-mcp-server 命令"
    echo "   Error: figma-mcp-server command not found in virtual environment"
    echo "   请重新运行 install.sh"
    echo "   Please run install.sh again"
    exit 1
fi

echo "✅ 虚拟环境中的命令存在: $FIGMA_CMD"
echo "   Command exists in virtual environment: $FIGMA_CMD"
echo ""

# 检查当前命令是否可用
if command -v figma-mcp-server >/dev/null 2>&1; then
    echo "✅ figma-mcp-server 命令当前可用"
    echo "   figma-mcp-server command is currently available"
    which figma-mcp-server
    echo ""
else
    echo "⚠️  figma-mcp-server 命令当前不可用"
    echo "   figma-mcp-server command is currently not available"
    echo ""
fi

# 重新创建符号链接
echo "🔗 重新创建全局符号链接"
echo "   Recreating global symlink..."

GLOBAL_BIN_DIRS=("/usr/local/bin" "$HOME/.local/bin" "$HOME/bin")
CREATED_SYMLINK=false

for bin_dir in "${GLOBAL_BIN_DIRS[@]}"; do
    if [ -d "$bin_dir" ] || [ -w "$(dirname "$bin_dir")" ]; then
        mkdir -p "$bin_dir" 2>/dev/null || continue
        
        if [ -w "$bin_dir" ]; then
            # 删除旧的符号链接
            rm -f "$bin_dir/figma-mcp-server" 2>/dev/null
            
            # 创建新的符号链接
            ln -sf "$FIGMA_CMD" "$bin_dir/figma-mcp-server"
            
            if [ $? -eq 0 ]; then
                echo "✅ 已创建符号链接: $bin_dir/figma-mcp-server"
                echo "   Created symlink: $bin_dir/figma-mcp-server"
                CREATED_SYMLINK=true
                break
            fi
        fi
    fi
done

# 如果上面的目录都不可写，尝试使用 sudo
if [ "$CREATED_SYMLINK" = false ]; then
    echo "🔧 尝试使用 sudo 创建符号链接"
    echo "   Trying to create symlink with sudo..."
    
    sudo rm -f "/usr/local/bin/figma-mcp-server" 2>/dev/null
    
    if sudo ln -sf "$FIGMA_CMD" "/usr/local/bin/figma-mcp-server"; then
        echo "✅ 已创建符号链接: /usr/local/bin/figma-mcp-server"
        echo "   Created symlink: /usr/local/bin/figma-mcp-server"
        CREATED_SYMLINK=true
    else
        echo "❌ 无法创建符号链接"
        echo "   Failed to create symlink"
    fi
fi

echo ""

# 检查 PATH 配置
echo "🔍 检查 PATH 配置"
echo "   Checking PATH configuration..."

SHELL_CONFIG=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
    if [ ! -f "$SHELL_CONFIG" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    fi
fi

if [ -n "$SHELL_CONFIG" ]; then
    if grep -q "figma-mcp-env/bin" "$SHELL_CONFIG" 2>/dev/null; then
        echo "✅ PATH 已在 $SHELL_CONFIG 中配置"
        echo "   PATH is configured in $SHELL_CONFIG"
    else
        echo "⚠️  PATH 未在 $SHELL_CONFIG 中配置"
        echo "   PATH is not configured in $SHELL_CONFIG"
        echo "   正在添加..."
        echo "   Adding..."
        echo "" >> "$SHELL_CONFIG"
        echo "# Figma MCP Server PATH" >> "$SHELL_CONFIG"
        echo "export PATH=\"$VENV_BIN_DIR:\$PATH\"" >> "$SHELL_CONFIG"
        echo "✅ 已添加到 $SHELL_CONFIG"
        echo "   Added to $SHELL_CONFIG"
    fi
else
    echo "⚠️  无法检测 shell 配置文件"
    echo "   Cannot detect shell configuration file"
fi

echo ""

# 最终验证
echo "🔍 最终验证"
echo "   Final verification..."

# 重新加载 PATH
export PATH="$VENV_BIN_DIR:$PATH"

if command -v figma-mcp-server >/dev/null 2>&1; then
    echo "✅ figma-mcp-server 命令现在可用！"
    echo "   figma-mcp-server command is now available!"
    which figma-mcp-server
    echo ""
    echo "🎉 修复完成！"
    echo "   Fix completed!"
    echo ""
    echo "💡 如果在新终端中仍然不可用，请运行:"
    echo "   If still not available in new terminals, run:"
    echo "   source $SHELL_CONFIG"
else
    echo "❌ figma-mcp-server 命令仍然不可用"
    echo "   figma-mcp-server command is still not available"
    echo ""
    echo "🔧 手动解决方案:"
    echo "   Manual solution:"
    echo "   1. 重新加载 shell 配置:"
    echo "      1. Reload shell configuration:"
    echo "         source $SHELL_CONFIG"
    echo "   2. 或者打开新的终端窗口"
    echo "      2. Or open a new terminal window"
    echo "   3. 或者直接使用完整路径:"
    echo "      3. Or use full path:"
    echo "         $FIGMA_CMD"
fi
