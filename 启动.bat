@echo off
chcp 65001 >nul
setlocal DisableDelayedExpansion

pushd "%~dp0"
if errorlevel 1 (
    echo [错误] 无法进入项目目录。
    pause
    exit /b 1
)

if not exist ".venv\Scripts\python.exe" goto :environment_error
if not exist ".venv\Scripts\pythonw.exe" goto :environment_error

rem 游戏以管理员身份运行时，普通权限进程无法向它发送模拟输入。
".venv\Scripts\python.exe" -c "import ctypes; raise SystemExit(0 if ctypes.windll.shell32.IsUserAnAdmin() else 1)"
if errorlevel 1 (
    echo 正在申请管理员权限，请在 Windows 提示中确认。
    set "ONE_DRAGON_START_SCRIPT=%~f0"
    powershell.exe -NoProfile -Command "try { Start-Process -FilePath $env:ONE_DRAGON_START_SCRIPT -Verb RunAs -ErrorAction Stop } catch { Write-Host '未能获得管理员权限，请右键此脚本并选择以管理员身份运行。'; exit 1 }"
    if errorlevel 1 (
        pause
        popd
        exit /b 1
    )
    popd
    exit /b 0
)

set "PYTHONPATH=%~dp0src"
set "PYTHONIOENCODING=utf-8"
start "" "%~dp0.venv\Scripts\pythonw.exe" "%~dp0src\zzz_od\gui\app.py"
set "gui_exit_code=%errorlevel%"
popd

if not "%gui_exit_code%"=="0" (
    echo [错误] 无法启动程序，请检查项目的 Python 环境。
    pause
)
exit /b %gui_exit_code%

:environment_error
echo [错误] 未找到项目 Python 环境。
echo 请在项目目录执行 uv sync --group dev 后重试。
pause
popd
exit /b 1
