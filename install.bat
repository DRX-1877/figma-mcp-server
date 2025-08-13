@echo off
setlocal enabledelayedexpansion

REM Figma MCP Server 安装脚本 (Windows)
REM 自动创建虚拟环境、安装依赖并配置环境

echo 🚀 开始安装 Figma MCP Server...

REM 检查 Python 版本
echo 📋 检查 Python 版本...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到 Python，请先安装 Python 3.10 或更高版本
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set python_version=%%i
echo ✅ Python 版本检查通过: !python_version!

REM 创建虚拟环境
echo 🔧 创建虚拟环境...
if exist "figma-mcp-env" (
    echo ⚠️  虚拟环境已存在，正在删除...
    rmdir /s /q figma-mcp-env
)

python -m venv figma-mcp-env
if errorlevel 1 (
    echo ❌ 虚拟环境创建失败
    pause
    exit /b 1
)
echo ✅ 虚拟环境创建成功

REM 激活虚拟环境
echo 🔌 激活虚拟环境...
call figma-mcp-env\Scripts\activate.bat

REM 升级 pip
echo ⬆️  升级 pip...
python -m pip install --upgrade pip

REM 安装项目依赖
echo 📦 安装项目依赖...
pip install -e .

REM 检查安装
echo 🔍 验证安装...
python -c "import figma_mcp_server; print('✅ Figma MCP Server 模块导入成功')" 2>nul
if errorlevel 1 (
    echo ❌ 项目安装失败
    pause
    exit /b 1
)
echo ✅ 项目安装成功！

REM 检查 MCP 依赖
python -c "import mcp; print('✅ MCP 依赖安装成功')" 2>nul
if errorlevel 1 (
    echo ❌ MCP 依赖安装失败
    pause
    exit /b 1
)
echo ✅ MCP 依赖检查通过

REM 配置 PATH 环境变量
echo 🔧 配置 PATH 环境变量...
set "SCRIPT_DIR=%~dp0"
set "VENV_BIN_DIR=%SCRIPT_DIR%figma-mcp-env\Scripts"

REM 检查是否已经添加到 PATH
echo %PATH% | findstr /i "figma-mcp-env" >nul
if errorlevel 1 (
    REM 添加到用户 PATH
    setx PATH "%PATH%;%VENV_BIN_DIR%"
    echo ✅ 已添加到系统 PATH
) else (
    echo ✅ PATH 已配置
)

echo.
echo 🎉 安装完成！
echo.
echo 📝 下一步操作：
echo 1. 激活虚拟环境:
echo    figma-mcp-env\Scripts\activate.bat
echo.
echo 2. 设置 Figma 访问令牌:
echo    set FIGMA_ACCESS_TOKEN=your_token_here
echo.
echo 3. 测试安装:
echo    figma-mcp-server --help
echo.
echo 💡 提示: 每次使用前都需要激活虚拟环境
echo.
pause
