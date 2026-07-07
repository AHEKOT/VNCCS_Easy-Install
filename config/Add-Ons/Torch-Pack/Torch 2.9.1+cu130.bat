@echo off&&cd /d %~dp0
set "TORCH_VER=2.9.1"
Title Torch %TORCH_VER% for 'ComfyUI Easy Install' by ivo

:: Add a path just in case ::
for /f "delims=" %%G in ('cmd /c "where.exe git.exe 2>nul"') do (set "GIT_PATH=%%~dpG")
set "path=%GIT_PATH%;%windir%\System32;%windir%\System32\WindowsPowerShell\v1.0;%localappdata%\Microsoft\WindowsApps;%PATH%"

set "DIR_LVL=..\..\"
call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install\Add-ons\Torch-Pack"
call :CHECK_INUSE "Start ComfyUI.bat"
call :NVIDIA_DRIVER_CHECK

:: Set arguments ::
set "PIPargs=--no-cache-dir --no-warn-script-location --no-deps --timeout=1000 --retries 10"

:: Installing Torch 2.9.1 ::
echo %green%::::::::::::::: Installing%yellow% Torch %TORCH_VER% %green%:::::::::::::::%reset%
echo.

%DIR_LVL%python_embeded\python.exe -I -m pip uninstall torch torchvision torchaudio -y
%DIR_LVL%python_embeded\python.exe -I -m pip install torch==2.9.1 torchvision==0.24.1 torchaudio==2.9.1 --index-url https://download.pytorch.org/whl/cu130 %PIPargs%

%DIR_LVL%python_embeded\python.exe -I -m pip uninstall llama-cpp-python -y
%DIR_LVL%python_embeded\python.exe -I -m pip install https://github.com/JamePeng/llama-cpp-python/releases/download/v0.3.38-cu130-Basic-win-20260504/llama_cpp_python-0.3.38+cu130.basic-cp312-cp312-win_amd64.whl %PIPargs%
echo.

call :IS_INSTALLED "nunchaku" "..\Nunchaku.bat"
call :IS_INSTALLED "sageattention" "..\SageAttention-Multi (v2.2.0 and v3).bat"
call :IS_INSTALLED "flash-attn" "..\FlashAttention.bat"

:: Final Messages ::
echo.
echo %green%:::::::::::::::::::: Torch %TORCH_VER% Installation Complete ::::::::::::::::::%reset%
echo %yellow%:::::::::::::::::::::::::: Press any key to exit ::::::::::::::::::::::::%reset%&Pause>nul
exit

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

:NVIDIA_DRIVER_CHECK
set "NV_MIN=580"

where.exe nvidia-smi.exe >nul 2>&1
if %errorLevel% neq 0 (
    echo %red%   NVIDIA driver not detected
    GOTO :EOF
)

for /f %%a in ('nvidia-smi --query-gpu^=driver_version --format^=csv^,noheader 2^>nul') do set "NV_FULL=%%a"
for /f "tokens=1 delims=." %%a in ("%NV_FULL%") do set "NV_MAJOR=%%a"

if not defined NV_MAJOR (
    echo %red%   Unable to read NVIDIA driver version
    GOTO :EOF
)

if %NV_MAJOR% LSS %NV_MIN% (
    echo %red%   Your NVIDIA driver %yellow%^(%NV_FULL%^)%red% is below %yellow%%NV_MIN%%reset%
	echo %warning%   Drivers below %yellow%%NV_MIN%%warning% do not support %yellow%CUDA 13%warning% or newer%reset%
    echo.
	echo %warning%   Update your NVIDIA driver first!%reset%
	echo.
	echo %yellow%:: Press any key to exit...%reset%&Pause>nul
	exit
)

GOTO :EOF

:IS_INSTALLED
set "custom_node=%~1"
set "bat_file=%~2"

%DIR_LVL%python_embeded\python.exe -m pip show %custom_node% >nul 2>&1

if "%errorlevel%"=="0" (
	pushd %cd%
	call "%bat_file%" NoPause
	popd
)

GOTO :EOF