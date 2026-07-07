@echo off&&cd /D %~dp0
Title Update ComfyUI by ivo
:: Pixaroma Community Edition ::

set "DIR_LVL=.\"
call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install"
call :CHECK_INUSE "Start ComfyUI.bat"

echo %green%::::::::::::::: Updating ComfyUI :::::::::::::::%reset%
echo.
cd %DIR_LVL%ComfyUI&&git.exe checkout master -q&&cd %~dp0

:: Install working version of av!!! ::
%PYTHON_EXE% -I -m uv pip install av==16.0.1 --link-mode=copy

cd %DIR_LVL%update&&call update_comfyui_stable.bat nopause&&cd %~dp0

:: Restoring Numpy 1.26.4 ::
%PYTHON_EXE% -c "import numpy, sys; sys.exit(0 if numpy.__version__ == '1.26.4' else 1)" 2>nul || %PYTHON_EXE% -I -m pip install --force-reinstall numpy==1.26.4 --no-deps --no-warn-script-location

:: Final Messages ::
echo.
echo %green%::::::::::::::: Update completed :::::::::::::::%reset%
echo.
if "%~1"=="" (
    echo %yellow%:::::::::::: Press any key to exit :::::::::::::%reset%&Pause>nul
    exit
)

exit /b

:: ---------------------------------------- END ---------------------------------------- ::

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
set "path=%windir%\System32;%windir%\System32\WindowsPowerShell\v1.0;%localappdata%\Microsoft\WindowsApps;%PATH%"
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
set "PREF_FOLDER=%~1"

if exist "%DIR_LVL%python_embeded\python.exe" (set "PYTHON_EXE=%DIR_LVL%python_embeded\python.exe")

if "%PYTHON_EXE%"=="" (
	echo.
    echo    %green%Please run this file from the %yellow%%~1%green% folder.%reset%
	echo.
    echo    %gray%Press any key to exit...%reset%&Pause>nul
    exit
)
GOTO :EOF