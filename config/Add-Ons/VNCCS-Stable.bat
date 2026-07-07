@echo off&&cd /D %~dp0
setlocal
Title VNCCS Stable release

set "DIR_LVL=..\"
set "UVargs=--no-cache --link-mode=copy"

call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install\Add-ons"
call :CHECK_INUSE "Start ComfyUI.bat"

echo.
echo %green%This will fully remove and reinstall stable%yellow% VNCCS%green% and%yellow% VNCCS Utils%green%.%reset%
echo.

call :INSTALL_NODE "VNCCS Stable" "https://github.com/AHEKOT/ComfyUI_VNCCS" "vnccs"
if errorlevel 1 goto :PAUSE_EXIT

call :INSTALL_NODE "VNCCS Utils Stable" "https://github.com/AHEKOT/ComfyUI_VNCCS_Utils" "vnccs-utils"
if errorlevel 1 goto :PAUSE_EXIT

echo.
echo %green%::::::::::::::: %yellow%VNCCS Stable%green% installation complete :::::::::::::::%reset%

:PAUSE_EXIT
echo.
if /I "%~1"=="nopause" exit /b
echo %gray%Press any key to exit...%reset%&Pause>nul
exit /b

:INSTALL_NODE
set "NODE_NAME=%~1"
set "NODE_URL=%~2"
set "NODE_FOLDER=%~3"
set "CUSTOM_NODES=%DIR_LVL%ComfyUI\custom_nodes"
set "TARGET_DIR=%CUSTOM_NODES%\%NODE_FOLDER%"

if exist "%TARGET_DIR%" (
    echo %green%::::::::::::::: Removing existing%yellow% %NODE_FOLDER% %green%node :::::::::::::::%reset%
    rmdir /s /q "%TARGET_DIR%"
    if exist "%TARGET_DIR%" (
        echo.
        echo %red%Failed to remove "%TARGET_DIR%".%reset%
        echo %white%Close ComfyUI and any Explorer window opened inside that folder, then run this helper again.%reset%
        exit /b 1
    )
)

echo.
echo %green%::::::::::::::: Installing%yellow% %NODE_NAME% %green%:::::::::::::::%reset%
echo.

git.exe clone %NODE_URL% "%TARGET_DIR%"
if errorlevel 1 (
    echo.
    echo %red%Failed to clone %NODE_URL%.%reset%
    exit /b 1
)

if exist "%TARGET_DIR%\requirements.txt" (
    echo.
    echo %green%::::::::::::::: Installing%yellow% %NODE_FOLDER% %green%requirements.txt :::::::::::::::%reset%
    "%PYTHON_EXE%" -I -m uv pip install -r "%TARGET_DIR%\requirements.txt" %UVargs%
    if errorlevel 1 exit /b 1
) else if exist "%TARGET_DIR%\pyproject.toml" (
    echo.
    echo %green%::::::::::::::: Installing%yellow% %NODE_FOLDER% %green%pyproject dependencies :::::::::::::::%reset%
    "%PYTHON_EXE%" -I -m uv pip install -e "%TARGET_DIR%" %UVargs%
    if errorlevel 1 exit /b 1
)

if exist "%TARGET_DIR%\install.py" (
    echo.
    echo %green%::::::::::::::: Running%yellow% %NODE_FOLDER% %green%install.py :::::::::::::::%reset%
    "%PYTHON_EXE%" -I "%TARGET_DIR%\install.py"
    if errorlevel 1 exit /b 1
)

exit /b 0

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
