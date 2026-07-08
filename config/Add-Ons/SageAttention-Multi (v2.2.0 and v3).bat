@echo off&&cd /D %~dp0
setlocal enabledelayedexpansion
set "node_name=SageAttention-Multi"
Title '%node_name%' for 'ComfyUI Easy Install' by ivo
:: Pixaroma Community Edition ::

set "DIR_LVL=..\"
call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install\Add-ons"
call :CHECK_INUSE "Start ComfyUI.bat"
call :GET_VERSIONS "3.12" "2.7 2.8 2.9 2.10" "12.8 13.0"

set "PIPargs=--no-cache-dir --no-warn-script-location --timeout=1000 --retries 10 --use-pep517"

echo %green%:::::::::::::: Installing %yellow%SageAttention v2.2.0%green% and %yellow%SageAttention v3%reset%
echo.

:: Erasing ~* folders ::
if exist "%DIR_LVL%python_embeded\Lib\site-packages\~*" (powershell -NoProfile -ExecutionPolicy Bypass -command "Get-ChildItem '%DIR_LVL%python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")

:: Installing Triton ::
echo %green%:::::::::::::: Installing%yellow% Triton%reset%
echo.
%PYTHON_EXE% -I -m pip uninstall triton-windows -y >nul 2>&1
if "%TORCH_VERSION%"=="2.7" %PYTHON_EXE% -I -m pip install "triton-windows<3.4" %PIPargs%
if "%TORCH_VERSION%"=="2.8" %PYTHON_EXE% -I -m pip install "triton-windows<3.5" %PIPargs%
if "%TORCH_VERSION%"=="2.9" %PYTHON_EXE% -I -m pip install "triton-windows<3.6" %PIPargs%
if "%TORCH_VERSION%"=="2.10" %PYTHON_EXE% -I -m pip install "triton-windows<3.7" %PIPargs%
echo.

:: Installing SageAttention 2.2.0 ::
echo %green%:::::::::::::: Installing%yellow% SageAttention 2.2.0%reset%
echo.
if "%TORCH_VERSION%"=="2.7" if "%CUDA_VERSION%"=="12.8" (set "SAGE2_WHL=v2.2.0-windows.post3/sageattention-2.2.0+cu128torch2.7.1.post3-cp39-abi3-win_amd64.whl")
if "%TORCH_VERSION%"=="2.8" if "%CUDA_VERSION%"=="12.8" (set "SAGE2_WHL=v2.2.0-windows.post3/sageattention-2.2.0+cu128torch2.8.0.post3-cp39-abi3-win_amd64.whl")
if "%TORCH_VERSION%"=="2.9" if "%CUDA_VERSION%"=="13.0" (set "SAGE2_WHL=v2.2.0-windows.post5/sageattention-2.2.0+cu130torch2.9.1.post5-cp310-abi3-win_amd64.whl")
if "%TORCH_VERSION%"=="2.10" if "%CUDA_VERSION%"=="13.0" (set "SAGE2_WHL=v2.2.0-windows.post5/sageattention-2.2.0+cu130torch2.10.0andhigher.post5-cp310-abi3-win_amd64.whl")
%PYTHON_EXE% -I -m pip uninstall sageattention -y >nul 2>&1
%PYTHON_EXE% -I -m pip install https://github.com/woct0rdho/SageAttention/releases/download/%SAGE2_WHL% %PIPargs%
echo.

:: Installing SageAttention 3 ::
if "%TORCH_VERSION%"=="2.7" if "%CUDA_VERSION%"=="12.8" (set "SAGE3_WHL=https://github.com/mengqin/SageAttention/releases/download/20251229/sageattn3-1.0.0+cu128torch271-cp312-cp312-win_amd64.whl")
if "%TORCH_VERSION%"=="2.8" if "%CUDA_VERSION%"=="12.8" (set "SAGE3_WHL=https://github.com/mengqin/SageAttention/releases/download/20251229/sageattn3-1.0.0+cu128torch280-cp312-cp312-win_amd64.whl")
if "%TORCH_VERSION%"=="2.9" if "%CUDA_VERSION%"=="13.0" (set "SAGE3_WHL=https://github.com/mengqin/SageAttention/releases/download/20251229/sageattn3-1.0.0+cu130torch291-cp312-cp312-win_amd64.whl")
if "%TORCH_VERSION%"=="2.10" if "%CUDA_VERSION%"=="13.0" (set "SAGE3_WHL=https://huggingface.co/ussoewwin/Sage-Attention-for-Windows/resolve/main/sageattn3-1.0.0+cu130torch2.10.0-cp312-cp312-win_amd64.whl")
%PYTHON_EXE% -I -m pip uninstall sageattn3 -y >nul 2>&1

echo %green%:::::::::::::: Installing%yellow% SageAttention 3%reset%
echo.
%PYTHON_EXE% -I -m pip install %SAGE3_WHL% %PIPargs%
echo.

:: Creating 'Start ComfyUI SageAttention.bat' file ::
set "BATCH-NAME=%DIR_LVL%Start ComfyUI SageAttention.bat"
if not exist "%BATCH-NAME%" (
	echo.
	echo %green%:::::::::::::: Creating%yellow% Start ComfyUI FlashAttention.bat%reset%

	echo @Echo off^&^&cd /D %%^~dp0>"%BATCH-NAME%"
	echo Title ComfyUI-Easy-Install>>"%BATCH-NAME%"
	echo.>>"%BATCH-NAME%"
	
	echo set "path=%%windir%%\System32;%%windir%%\System32\WindowsPowerShell\v1.0;%%PATH%%">>"%BATCH-NAME%"
	echo.>>"%BATCH-NAME%"
	
	echo set PORT=8188>>"%BATCH-NAME%"
	echo for /f %%%%A in ^('powershell -NoProfile -ExecutionPolicy Bypass -Command "([regex]::Match((Get-Content '%%~f0' -Raw), '--port\s+(\d+)')).Groups[1].Value"'^) do set PORT=%%%%A>>"%BATCH-NAME%"
	echo for /f %%%%A in ^('powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-NetTCPConnection -LocalPort %%PORT%% -State Listen -ErrorAction SilentlyContinue) { 1 } else { 0 }"'^) do set INUSE=%%%%A>>"%BATCH-NAME%"
	echo if "%%INUSE%%"=="1" ^(>>"%BATCH-NAME%"
    echo     echo Hey [92m%%USERNAME%%[0m! ComfyUI is already running on port [92m%%PORT%%[0m.>>"%BATCH-NAME%"
	echo     echo [93mPress any key to exit...[0m^&^&pause^>nul^&^&exit>>"%BATCH-NAME%"
	echo ^)>>"%BATCH-NAME%"
	echo.>>"%BATCH-NAME%"
	
	echo .\python_embeded\python.exe -I -W ignore::FutureWarning ComfyUI\main.py --windows-standalone-build --use-sage-attention>>"%BATCH-NAME%"
	echo pause>>"%BATCH-NAME%"
)

:: Final Messages ::
echo.
echo %green%::::::::::::::%yellow% %node_name% %green%Installation Complete%reset%
echo.
if "%~1"=="" (
    echo %green%:::::::::::::: %yellow%Press any key to exit%reset%&Pause>nul
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

:GET_VERSIONS
set "ALLOWED_PYTHON=%~1"
set "ALLOWED_TORCH=%~2"
set "ALLOWED_CUDA=%~3"

echo %green%:::::::::::::: Checking %yellow%Python, Torch, CUDA %green%versions%reset%
echo.
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

set WARNINGS=0
call :CHECK_VERSION "%PYTHON_VERSION%" "%ALLOWED_PYTHON%" "Python"
call :CHECK_VERSION "%TORCH_VERSION%"  "%ALLOWED_TORCH%"  "Torch"
call :CHECK_VERSION "%CUDA_VERSION%"   "%ALLOWED_CUDA%"   "CUDA"

if !WARNINGS!==0 (
    echo %green%:::::::::::::: All versions are supported!%reset%
    echo.
) else (
    echo.
    echo %red%:::::::::::::: Press any key to exit%reset%&Pause>nul
    exit
)
GOTO :EOF

:CHECK_VERSION
set "CURRENT=%~1"
set "ALLOWED=%~2"
set "DISPLAY=%~3"
set "FOUND=0"

if "!CURRENT!"=="Not available" (
    echo %warning%WARNING: %red%%DISPLAY% is not available.%reset%
    set "WARNINGS=1"
    GOTO :EOF
)
if "!CURRENT!"=="Not found" (
    echo %warning%WARNING: %red%%DISPLAY% is not found.%reset%
    set "WARNINGS=1"
    GOTO :EOF
)

for %%v in (%ALLOWED%) do (
    if "!CURRENT!"=="%%v" set "FOUND=1"
)

if "!FOUND!"=="0" (
    echo %warning%WARNING: %red%%DISPLAY% !CURRENT! is not supported. %green%Supported: %ALLOWED%%reset%
    set "WARNINGS=1"
)
GOTO :EOF
