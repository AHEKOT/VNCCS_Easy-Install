@echo off&&cd /D %~dp0
setlocal
Title VNCCS-Next unstable beta release

set "DIR_LVL=..\"
set "NODE_NAME=VNCCS Next"
set "NODE_FOLDER=vnccs"
set "NODE_URL=https://github.com/AHEKOT/ComfyUI_VNCCS"
set "NODE_BRANCH=next"
set "UVargs=--no-cache --link-mode=copy"

call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install\Add-ons"
call :CHECK_INUSE "Start ComfyUI.bat"

echo.
echo %warning%WARNING:%reset% %yellow%%NODE_NAME%%reset% is an unstable beta release.
echo %green%This will fully remove the current %yellow%%NODE_FOLDER%%green% custom node and install branch %yellow%%NODE_BRANCH%%green%.%reset%
echo.

set "CUSTOM_NODES=%DIR_LVL%ComfyUI\custom_nodes"
set "TARGET_DIR=%CUSTOM_NODES%\%NODE_FOLDER%"

if exist "%TARGET_DIR%" (
    echo %green%::::::::::::::: Removing existing%yellow% %NODE_FOLDER% %green%node :::::::::::::::%reset%
    rmdir /s /q "%TARGET_DIR%"
    if exist "%TARGET_DIR%" (
        echo.
        echo %red%Failed to remove "%TARGET_DIR%".%reset%
        echo %white%Close ComfyUI and any Explorer window opened inside that folder, then run this helper again.%reset%
        goto :PAUSE_EXIT
    )
)

echo.
echo %green%::::::::::::::: Installing%yellow% %NODE_NAME% %green%from branch%yellow% %NODE_BRANCH% %green%:::::::::::::::%reset%
echo.

git.exe clone --branch %NODE_BRANCH% --single-branch %NODE_URL% "%TARGET_DIR%"
if errorlevel 1 (
    echo.
    echo %red%Failed to clone %NODE_URL% branch %NODE_BRANCH%.%reset%
    goto :PAUSE_EXIT
)

if exist "%TARGET_DIR%\requirements.txt" (
    echo.
    echo %green%::::::::::::::: Installing%yellow% %NODE_FOLDER% %green%requirements.txt :::::::::::::::%reset%
    "%PYTHON_EXE%" -I -m uv pip install -r "%TARGET_DIR%\requirements.txt" %UVargs%
) else if exist "%TARGET_DIR%\pyproject.toml" (
    echo.
    echo %green%::::::::::::::: Installing%yellow% %NODE_FOLDER% %green%pyproject dependencies :::::::::::::::%reset%
    "%PYTHON_EXE%" -I -m uv pip install -e "%TARGET_DIR%" %UVargs%
)

if exist "%TARGET_DIR%\install.py" (
    echo.
    echo %green%::::::::::::::: Running%yellow% %NODE_FOLDER% %green%install.py :::::::::::::::%reset%
    "%PYTHON_EXE%" -I "%TARGET_DIR%\install.py"
)

echo.
echo %green%::::::::::::::: %yellow%%NODE_NAME%%green% installation complete :::::::::::::::%reset%

:PAUSE_EXIT
echo.
if /I "%~1"=="nopause" exit /b
echo %gray%Press any key to exit...%reset%&Pause>nul
exit /b

:SET_COLORS
set warning=[33m
set    gray=[90m
set     red=[91m
set   green=[92m
set  yellow=[93m
set    blue=[94m
set magenta=[95m
set    cyan=[96m
set   white=[97m
set   reset=[0m
GOTO :EOF

:CHECK_INUSE
set "StartComfyUI=%DIR_LVL%%~1"
if exist %StartComfyUI% (
    set PORT=8188
    for /f %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "([regex]::Match((Get-Content '%StartComfyUI%' -Raw), '--port\s+(\d+)')).Groups[1].Value"') do set PORT=%%A
    for /f %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-NetTCPConnection -LocalPort %PORT% -State Listen -ErrorAction SilentlyContinue) { 1 } else { 0 }"') do set INUSE=%%A
    if "%INUSE%"=="1" (
        echo.
        echo    %white%ComfyUI%reset% is already running on port %green%%PORT%%reset%. %white%Please close it first.%reset%
        echo.
        echo    %gray%Press any key to exit...%reset%&&pause>nul&&exit
    )
)
GOTO :EOF

:CHECK_FOLDER
set "PYTHON_EXE="

if exist "%DIR_LVL%python_embeded\python.exe" (set "PYTHON_EXE=%DIR_LVL%python_embeded\python.exe")

if "%PYTHON_EXE%"=="" (
    echo.
    echo    %green%Please run this file from the %yellow%%~1%green% folder.%reset%
    echo.
    echo    %gray%Press any key to exit...%reset%&Pause>nul
    exit
)
GOTO :EOF
