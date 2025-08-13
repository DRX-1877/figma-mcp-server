@echo off
setlocal enabledelayedexpansion

REM Figma MCP Server 命令修复脚本 (Windows)
REM 用于修复 figma-mcp-server 命令不可用的问题

echo 🔧 Figma MCP Server 命令修复工具
echo     Figma MCP Server Command Fix Tool
echo.

REM 检查项目目录
set "SCRIPT_DIR=%~dp0"
if not exist "%SCRIPT_DIR%figma-mcp-env" (
    echo ❌ 错误: 未找到虚拟环境，请先运行 install.bat
    echo     Error: Virtual environment not found, please run install.bat first
    pause
    exit /b 1
)

set "VENV_BIN_DIR=%SCRIPT_DIR%figma-mcp-env\Scripts"
set "FIGMA_CMD=%VENV_BIN_DIR%\figma-mcp-server.exe"

REM 检查虚拟环境中的命令是否存在
if not exist "%FIGMA_CMD%" (
    echo ❌ 错误: 虚拟环境中未找到 figma-mcp-server 命令
    echo     Error: figma-mcp-server command not found in virtual environment
    echo     请重新运行 install.bat
    echo     Please run install.bat again
    pause
    exit /b 1
)

echo ✅ 虚拟环境中的命令存在: %FIGMA_CMD%
echo     Command exists in virtual environment: %FIGMA_CMD%
echo.

REM 检查当前命令是否可用
figma-mcp-server --help >nul 2>&1
if not errorlevel 1 (
    echo ✅ figma-mcp-server 命令当前可用
    echo     figma-mcp-server command is currently available
    where figma-mcp-server
    echo.
) else (
    echo ⚠️  figma-mcp-server 命令当前不可用
    echo     figma-mcp-server command is currently not available
    echo.
)

REM 重新创建符号链接
echo 🔗 重新创建全局符号链接
echo     Recreating global symlink...

set "CREATED_SYMLINK=false"

REM 尝试 %USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages
set "GLOBAL_BIN_DIR=%USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages"
if not exist "%GLOBAL_BIN_DIR%" mkdir "%GLOBAL_BIN_DIR%" >nul 2>&1

REM 删除旧的符号链接（如果存在）
if exist "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" del "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" >nul 2>&1

REM 尝试创建符号链接
mklink "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" "%FIGMA_CMD%" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 已创建符号链接: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    echo     Created symlink: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    set "CREATED_SYMLINK=true"
    goto :symlink_created
)

REM 尝试 %USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\bin
set "GLOBAL_BIN_DIR=%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\bin"
if exist "%GLOBAL_BIN_DIR%" (
    if exist "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" del "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" >nul 2>&1
    mklink "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" "%FIGMA_CMD%" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ 已创建符号链接: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
        echo     Created symlink: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
        set "CREATED_SYMLINK=true"
        goto :symlink_created
    )
)

REM 尝试 C:\Windows\System32（需要管理员权限）
set "GLOBAL_BIN_DIR=C:\Windows\System32"
if exist "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" del "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" >nul 2>&1
mklink "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" "%FIGMA_CMD%" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 已创建符号链接: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    echo     Created symlink: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    set "CREATED_SYMLINK=true"
    goto :symlink_created
)

REM 如果符号链接都失败，尝试复制文件
echo ⚠️  无法创建符号链接，尝试复制文件
echo     Cannot create symlink, trying to copy file...

set "GLOBAL_BIN_DIR=%USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages"
copy "%FIGMA_CMD%" "%GLOBAL_BIN_DIR%\figma-mcp-server.exe" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 已复制到全局目录: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    echo     Copied to global directory: %GLOBAL_BIN_DIR%\figma-mcp-server.exe
    set "CREATED_SYMLINK=true"
    goto :symlink_created
)

echo ❌ 无法创建符号链接
echo     Failed to create symlink

:symlink_created

echo.

REM 检查 PATH 配置
echo 🔍 检查 PATH 配置
echo     Checking PATH configuration...

echo %PATH% | findstr /i "figma-mcp-env" >nul
if not errorlevel 1 (
    echo ✅ PATH 已在系统环境变量中配置
    echo     PATH is configured in system environment variables
) else (
    echo ⚠️  PATH 未在系统环境变量中配置
    echo     PATH is not configured in system environment variables
    echo     正在添加...
    echo     Adding...
    setx PATH "%PATH%;%VENV_BIN_DIR%"
    echo ✅ 已添加到系统 PATH
    echo     Added to system PATH
)

echo.

REM 最终验证
echo 🔍 最终验证
echo     Final verification...

REM 重新加载 PATH（在当前会话中）
set "PATH=%PATH%;%VENV_BIN_DIR%"

figma-mcp-server --help >nul 2>&1
if not errorlevel 1 (
    echo ✅ figma-mcp-server 命令现在可用！
    echo     figma-mcp-server command is now available!
    where figma-mcp-server
    echo.
    echo 🎉 修复完成！
    echo     Fix completed!
    echo.
    echo 💡 如果在新命令提示符中仍然不可用，请：
    echo     If still not available in new command prompt, please:
    echo     1. 重新打开命令提示符
    echo        1. Reopen command prompt
    echo     2. 或者重启计算机
    echo        2. Or restart computer
) else (
    echo ❌ figma-mcp-server 命令仍然不可用
    echo     figma-mcp-server command is still not available
    echo.
    echo 🔧 手动解决方案:
    echo     Manual solution:
    echo     1. 重新打开命令提示符
    echo        1. Reopen command prompt
    echo     2. 或者重启计算机
    echo        2. Or restart computer
    echo     3. 或者直接使用完整路径:
    echo        3. Or use full path:
    echo        %FIGMA_CMD%
)

pause
