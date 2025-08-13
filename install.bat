@echo off
setlocal enabledelayedexpansion

REM Figma MCP Server 安装脚本 (Windows)
REM 自动创建虚拟环境、安装依赖并配置环境

echo 🚀 开始安装 Figma MCP Server
echo     Starting Figma MCP Server installation...

REM 检查 Python 版本
echo 📋 检查 Python 版本
echo     Checking Python version...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到 Python，请先安装 Python 3.10 或更高版本
    echo     Error: Python not found, please install Python 3.10 or higher first
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set python_version=%%i
echo ✅ Python 版本检查通过: !python_version!
echo     Python version check passed: !python_version!

REM 创建虚拟环境
echo 🔧 创建虚拟环境
echo     Creating virtual environment...
if exist "figma-mcp-env" (
    echo ⚠️  虚拟环境已存在，正在删除...
    echo     Virtual environment exists, removing...
    rmdir /s /q figma-mcp-env
)

python -m venv figma-mcp-env
if errorlevel 1 (
    echo ❌ 虚拟环境创建失败
    echo     Failed to create virtual environment
    pause
    exit /b 1
)
echo ✅ 虚拟环境创建成功
echo     Virtual environment created successfully

REM 激活虚拟环境
echo 🔌 激活虚拟环境
echo     Activating virtual environment...
call figma-mcp-env\Scripts\activate.bat

REM 升级 pip
echo ⬆️  升级 pip
echo     Upgrading pip...
python -m pip install --upgrade pip

REM 安装项目依赖
echo 📦 安装项目依赖
echo     Installing project dependencies...
pip install -e .

REM 检查安装
echo 🔍 验证安装
echo     Verifying installation...
python -c "import figma_mcp_server; print('✅ Figma MCP Server 模块导入成功')" 2>nul
if errorlevel 1 (
    echo ❌ 项目安装失败
    echo     Project installation failed
    pause
    exit /b 1
)
echo ✅ 项目安装成功！
echo     Project installed successfully!

REM 检查 MCP 依赖
python -c "import mcp; print('✅ MCP 依赖安装成功')" 2>nul
if errorlevel 1 (
    echo ❌ MCP 依赖安装失败
    echo     MCP dependency installation failed
    pause
    exit /b 1
)
echo ✅ MCP 依赖检查通过
echo     MCP dependency check passed

REM 配置 PATH 环境变量
echo 🔧 配置 PATH 环境变量
echo     Configuring PATH environment variable...
set "SCRIPT_DIR=%~dp0"
set "VENV_BIN_DIR=%SCRIPT_DIR%figma-mcp-env\Scripts"

REM 检查是否已经添加到 PATH
echo %PATH% | findstr /i "figma-mcp-env" >nul
if errorlevel 1 (
    REM 添加到用户 PATH
    setx PATH "%PATH%;%VENV_BIN_DIR%"
    echo ✅ 已添加到系统 PATH
    echo     Added to system PATH
) else (
    echo ✅ PATH 已配置
    echo     PATH already configured
)

REM 创建全局符号链接（改进版本）
echo 🔗 创建全局符号链接
echo     Creating global symlink...

REM 尝试多个全局目录
set "CREATED_SYMLINK=false"

REM 尝试 %USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages
set "GLOBAL_BIN_DIR=%USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages"
if not exist "%GLOBAL_BIN_DIR%" mkdir "%GLOBAL_BIN_DIR%" >nul 2>&1

REM 尝试创建符号链接
mklink "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" "%VENV_BIN_DIR%\figma-mcp-server.exe" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 已创建全局符号链接: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    echo     Global symlink created: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    set "CREATED_SYMLINK=true"
    goto :symlink_created
)

REM 尝试 %USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\bin
set "GLOBAL_BIN_DIR=%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\bin"
if exist "%GLOBAL_BIN_DIR%" (
    mklink "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" "%VENV_BIN_DIR%\figma-mcp-server.exe" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ 已创建全局符号链接: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
        echo     Global symlink created: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
        set "CREATED_SYMLINK=true"
        goto :symlink_created
    )
)

REM 尝试 C:\Windows\System32（需要管理员权限）
set "GLOBAL_BIN_DIR=C:\Windows\System32"
mklink "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" "%VENV_BIN_DIR%\figma-mcp-server.exe" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 已创建全局符号链接: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    echo     Global symlink created: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    set "CREATED_SYMLINK=true"
    goto :symlink_created
)

REM 如果符号链接都失败，尝试复制文件
echo ⚠️  无法创建符号链接，尝试复制文件
echo     Cannot create symlink, trying to copy file...

set "GLOBAL_BIN_DIR=%USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages"
copy "%VENV_BIN_DIR%\figma-mcp-server.exe" "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 已复制到全局目录: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    echo     Copied to global directory: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    set "CREATED_SYMLINK=true"
    goto :symlink_created
)

echo ⚠️  无法创建全局符号链接，请手动配置
echo     Failed to create global symlink, please configure manually
echo     请将以下路径添加到系统 PATH:
echo     Please add the following path to system PATH:
echo     %VENV_BIN_DIR%

:symlink_created

REM 验证命令是否可用
echo 🔍 验证命令可用性
echo     Verifying command availability...
figma-mcp-server --help >nul 2>&1
if errorlevel 1 (
    echo ⚠️  figma-mcp-server 命令在当前会话中不可用
    echo     figma-mcp-server command is not available in current session
    echo     请重新打开命令提示符或重启计算机
    echo     Please reopen command prompt or restart computer
) else (
    echo ✅ figma-mcp-server 命令现在可以在任何地方使用
    echo     figma-mcp-server command is now available everywhere
)

echo.
echo 🎉 安装完成！
echo     Installation completed!
echo.
echo 📝 下一步操作：
echo     Next steps:
echo 1. 设置 Figma 访问令牌:
echo     Set Figma access token:
echo    set FIGMA_ACCESS_TOKEN=your_token_here
echo.
echo 2. 测试安装:
echo     Test installation:
echo    figma-mcp-server --help
echo.
echo 3. 使用 MCP 配置（可选）:
echo     Use MCP configuration (optional):
echo     在 Cursor 设置中添加以下配置:
echo     Add the following configuration to Cursor settings:
echo     {
echo       "mcpServers": {
echo         "figma-tools": {
echo           "command": "figma-mcp-server",
echo           "env": {
echo             "FIGMA_ACCESS_TOKEN": "your_token_here"
echo           }
echo         }
echo       }
echo     }
echo.
echo 💡 重要提示:
echo     Important notes:
echo     - 如果命令在当前会话不可用，请重新打开命令提示符
echo     - If command is not available in current session, reopen command prompt
echo     - 或者重启计算机
echo     - Or restart computer
echo     - 虚拟环境已通过符号链接全局可用，无需手动激活
echo     - Virtual environment is globally available via symlink, no manual activation needed
echo.
pause
