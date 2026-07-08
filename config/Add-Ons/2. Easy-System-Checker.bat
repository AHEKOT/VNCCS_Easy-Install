@echo off&&cd /d %~dp0
Title Easy System Checker for 'ComfyUI Easy Install' by ivo

:: Add a path just in case ::
for /f "delims=" %%G in ('cmd /c "where.exe git.exe 2>nul"') do (set "GIT_PATH=%%~dpG")
set "path=%GIT_PATH%;%windir%\System32;%windir%\System32\WindowsPowerShell\v1.0;%localappdata%\Microsoft\WindowsApps;%PATH%"

set "DIR_LVL=..\"
call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install\Add-ons"

echo.
echo %white%   Easy-System-Checker%reset%
echo.

call :GET_HARDWARE_INFO
call :COMFYUI_VERSION
call :LONG_PATHS_CHECK
call :GET_PTC_VERSIONS
call :NVIDIA_DRIVER_CHECK

:: Final Messages ::
echo.
if "%~1"=="" (
    echo %gray%:: Press any key to exit ::%reset%&Pause>nul
    exit
)

exit /b

:: ================================ END ===========================

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

:GET_PTC_VERSIONS
for /f "tokens=2" %%i in ('%PYTHON_EXE% --version 2^>^&1') do (
    for /f "tokens=1,2 delims=." %%a in ("%%i") do set "PYTHON_VERSION=%%a.%%b"
)
set "TORCH_VERSION=Not found"
set "CUDA_VERSION=Not available"
for /f "tokens=1,2 delims=|" %%a in ('%PYTHON_EXE% -c "import torch; v=torch.__version__.split(chr(43))[0]; cv=torch.version.cuda or chr(78); print(v.rsplit(chr(46),1)[0],cv,sep=chr(124))" 2^>nul') do (
    set "TORCH_VERSION=%%a"
    set "CUDA_VERSION=%%b"
)

echo %green%   Python    :%yellow% %PYTHON_VERSION%%reset%
echo %green%   PyTorch   :%yellow% %TORCH_VERSION%%reset%
echo %green%   CUDA Core :%yellow% %CUDA_VERSION%%reset%
echo.

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

echo %green%   NVIDIA-drv: %yellow%%NV_FULL%%reset%
if %NV_MAJOR% LSS %NV_MIN% (
    echo %red%   Your NVIDIA driver %yellow%^(%NV_FULL%^)%red% is below %yellow%%NV_MIN%%reset%
	echo %warning%   Drivers below %yellow%%NV_MIN%%warning% do not support %yellow%CUDA 13%warning% or newer%reset%
    echo %warning%   Recommendation: Update NVIDIA drivers%reset%
)

GOTO :EOF

:COMFYUI_VERSION
echo.
echo %white%:: SOFTWARE ^& VERSIONS ::%reset%
echo.
pushd "%cd%"
cd %DIR_LVL%ComfyUI
for /f "tokens=*" %%t in ('git.exe tag --sort=-creatordate ^| powershell -NoProfile -ExecutionPolicy Bypass -command "$input | select -first 1"') do set CURRENT_VERSION=%%t
echo %green%   ComfyUI   : %yellow%%CURRENT_VERSION%%reset%
echo.
popd

GOTO :EOF

:GET_HARDWARE_INFO
echo %white%:: HARDWARE INFO ::%reset%
echo.
for /f "tokens=*" %%a in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"') do set "SYS_RAM=%%a GB"

set "GPU_MODEL=Not detected"
set "GPU_VRAM=Not detected"

where.exe nvidia-smi.exe >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%m in ('nvidia-smi --query-gpu^=name --format^=csv^,noheader 2^>nul') do set "GPU_MODEL=%%m"
    for /f "tokens=*" %%v in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$v = nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits; if ($v) { [math]::Round([decimal]$v / 1024) } else { 'Error' }"') do (
        set "GPU_VRAM=%%v GB"
    )
)

echo %green%   System RAM: %yellow%%SYS_RAM%%reset%
echo %green%   GPU  Model: %yellow%%GPU_MODEL%%reset%
echo %green%   Video VRAM: %yellow%%GPU_VRAM%%reset%
GOTO :EOF

:LONG_PATHS_CHECK
reg query "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled >nul 2>&1 || goto :WarnLongPaths
reg query "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled | find "0x1" >nul || goto :WarnLongPaths
echo %green%   Windows long path support is %yellow%Enabled%reset%
echo.
GOTO :EOF
:WarnLongPaths
echo %red%   Windows long path support is NOT Enabled%reset%
echo %warning%   This may cause errors with Git or Python dependencies%reset%
echo %warning%   To enable it, run %green%Long-Paths-Enabler%warning% from the %green%Add-ons\Tools%warning% folder and restart the system%reset%
echo.
GOTO :EOF