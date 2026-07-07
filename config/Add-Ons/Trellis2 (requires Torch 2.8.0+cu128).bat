@echo off&&cd /D %~dp0
setlocal enabledelayedexpansion
set "node_name=Trellis2"
Title '%node_name%' for 'ComfyUI Easy Install' v0.3.7 by ivo
:: Pixaroma Community Edition ::

set "DIR_LVL=..\"
call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install\Add-ons"
call :CHECK_INUSE "Start ComfyUI.bat"
call :GET_VERSIONS "3.12" "2.8" "12.8"

set "PIPargs=--no-cache-dir --no-warn-script-location --timeout=1000 --retries 20 --use-pep517"

set "model_url=https://huggingface.co/PIA-SPACE-LAB/dinov3-vitl-pretrain-lvd1689m/resolve/main/model.safetensors"
set "model_name=model.safetensors"
set "model_folder=%DIR_LVL%ComfyUI\models\facebook\dinov3-vitl16-pretrain-lvd1689m"
set "config_url=https://huggingface.co/PIA-SPACE-LAB/dinov3-vitl-pretrain-lvd1689m/resolve/main/config.json"
set "config_name=config.json"
set "pre_config_url=https://huggingface.co/PIA-SPACE-LAB/dinov3-vitl-pretrain-lvd1689m/resolve/main/preprocessor_config.json"
set "pre_config_name=preprocessor_config.json"

:: Delete existing model.safetensors to ensure clean download ::
if exist "%model_folder%\%model_name%" del "%model_folder%\%model_name%"

:: Check for ComfyUI\models\facebook\dinov3-vitl16-pretrain-lvd1689m ::
if not exist "%model_folder%" md "%model_folder%"

:: Download the model ::
echo %green%Downloading %yellow%DINOv3 %model_name%%reset%
echo.
call :DOWNLOAD "%model_url%" "%model_folder%\%model_name%"
call :DOWNLOAD "%config_url%" "%model_folder%\%config_name%"
call :DOWNLOAD "%pre_config_url%" "%model_folder%\%pre_config_name%"
echo %yellow%DINOv3 %model_name%%green% was downloaded successfully%reset%
echo.

:: Erasing ~* folders ::
if exist "%DIR_LVL%python_embeded\Lib\site-packages\~*" (powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem '%DIR_LVL%python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")

:: Skip downloading LFS (Large File Storage) files ::
set GIT_LFS_SKIP_SMUDGE=1

:: Erase folders ::
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\o_voxel
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\o_voxel-0.0.1.dist-info
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\cumesh
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\cumesh-0.0.1.dist-info
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\cumesh-1.0.dist-info
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\nvdiffrast
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\nvdiffrast-0.4.0.dist-info
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\nvdiffrec_render
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\nvdiffrec_render-0.0.0.dist-info
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\flex_gemm
call :ERASE_FOLDER %DIR_LVL%python_embeded\Lib\site-packages\flex_gemm-0.0.1.dist-info

:: Installing Trellis2 ::
echo %green%::::::::::::::: Installing%yellow% %node_name%%reset%
echo.
if exist "%DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2" rmdir /s /q "%DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2"
git.exe clone https://github.com/visualbruno/ComfyUI-Trellis2 %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2
%PYTHON_EXE% -I -m pip install -r %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2\requirements.txt --no-deps %PIPargs%
echo.

:: Install Trellis2 wheels ::
%PYTHON_EXE% -I -m pip install --upgrade numpy --no-deps %PIPargs%
%PYTHON_EXE% -I -m pip install %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\cumesh-1.0-cp312-cp312-win_amd64.whl
%PYTHON_EXE% -I -m pip install %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\nvdiffrast-0.4.0-cp312-cp312-win_amd64.whl
%PYTHON_EXE% -I -m pip install %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\nvdiffrec_render-0.0.0-cp312-cp312-win_amd64.whl
%PYTHON_EXE% -I -m pip install %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\flex_gemm-0.0.1-cp312-cp312-win_amd64.whl
%PYTHON_EXE% -I -m pip install %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\o_voxel-0.0.1-cp312-cp312-win_amd64.whl


nvidia-smi.exe --query-gpu=compute_cap --format=csv,noheader 2>nul | findstr /b "12\." >nul && goto blackwell
%PYTHON_EXE% -I -m pip install --force-reinstall %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\natten-0.21.6-cp312-cp312-win_amd64.whl
goto done
:blackwell
%PYTHON_EXE% -I -m pip install --force-reinstall %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\Blackwell\natten-0.21.6-cp312-cp312-win_amd64.whl
:done


if exist "%DIR_LVL%python_embeded\Lib\site-packages\cumesh\remeshing.py" copy "%DIR_LVL%python_embeded\Lib\site-packages\cumesh\remeshing.py" "%DIR_LVL%python_embeded\Lib\site-packages\cumesh\remeshing.py.bak" >nul

REM ------------------------------------
call :DOWNLOAD "https://raw.githubusercontent.com/visualbruno/CuMesh/main/cumesh/remeshing.py" "%DIR_LVL%python_embeded\Lib\site-packages\cumesh\remeshing.py"
REM ------------------------------------

%PYTHON_EXE% -I -m pip install --upgrade pooch --no-deps %PIPargs%

:: Restoring Numpy 1.26.4 ::
%PYTHON_EXE% -c "import numpy, sys; sys.exit(0 if numpy.__version__ == '1.26.4' else 1)" 2>nul || %PYTHON_EXE% -I -m pip install --force-reinstall numpy==1.26.4 --no-deps --no-warn-script-location

:: Final Messages ::
echo.
echo %green%:::::::::::::::%yellow% %node_name% %green%Installation Complete%reset%
echo.
if "%~1"=="" (
    echo %green%::::::::::::::: %yellow%Press any key to exit%reset%&Pause>nul
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

:ERASE_FOLDER
set "folder_to_erase=%~1"
if exist %folder_to_erase% rmdir /s /q %folder_to_erase%
GOTO :EOF

:GET_VERSIONS
set "ALLOWED_PYTHON=%~1"
set "ALLOWED_TORCH=%~2"
set "ALLOWED_CUDA=%~3"

echo %green%::::::::::::::: Checking %yellow%Python, Torch, CUDA %green%versions%reset%
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

echo %green%::::::::::::::: Python Version:%yellow% %PYTHON_VERSION%%reset%
echo %green%::::::::::::::: Torch Version:%yellow% %TORCH_VERSION%%reset%
echo %green%::::::::::::::: CUDA Version:%yellow% %CUDA_VERSION%%reset%
echo.

set WARNINGS=0
call :CHECK_VERSION "%PYTHON_VERSION%" "%ALLOWED_PYTHON%" "Python"
call :CHECK_VERSION "%TORCH_VERSION%"  "%ALLOWED_TORCH%"  "Torch"
call :CHECK_VERSION "%CUDA_VERSION%"   "%ALLOWED_CUDA%"   "CUDA"

if !WARNINGS!==0 (
    echo %green%::::::::::::::: All versions are supported!%reset%
    echo.
) else (
    echo.
    echo %red%::::::::::::::: Press any key to exit%reset%&Pause>nul
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

:DOWNLOAD
set "_url=%~1"
set "_dst=%~2"

curl.exe -4 --progress-bar --ssl-no-revoke --tlsv1.2 --http1.1 --retry 5 --retry-delay 5 --location --fail -A "Mozilla/5.0" -o "%_dst%" "%_url%"

if errorlevel 1 (
    echo %warning%curl failed, trying PowerShell WebClient fallback...%reset%
    
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $wc = New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Mozilla/5.0'); [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $wc.DownloadFile('%_url%', '%_dst%')"
    
    if errorlevel 1 (
        echo %red%Download failed: %_url%%reset%
    )
)
GOTO :EOF
