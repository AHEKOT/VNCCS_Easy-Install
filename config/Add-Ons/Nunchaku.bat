@echo off&&cd /D %~dp0
setlocal enabledelayedexpansion
set "node_name=Nunchaku"
Title '%node_name%' for 'ComfyUI Easy Install' by ivo
:: Pixaroma Community Edition ::

set "DIR_LVL=..\"
call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install\Add-ons"
call :CHECK_INUSE "Start ComfyUI.bat"
call :GET_VERSIONS "3.12" "2.7 2.8 2.9 2.10" "12.8 13.0"

set "PIPargs=--no-cache-dir --no-warn-script-location --timeout=1000 --retries 200 --use-pep517"

:: Erasing ~* folders ::
if exist "%DIR_LVL%python_embeded\Lib\site-packages\~*" (powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem '%DIR_LVL%python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")

:: Skip downloading LFS (Large File Storage) files ::
set GIT_LFS_SKIP_SMUDGE=1

:: Installing Nunchaku ::
echo %green%:::::::::::::: Installing%yellow% %node_name%%reset%
echo.
if exist "%DIR_LVL%ComfyUI\custom_nodes\ComfyUI-nunchaku" rmdir /s /q "%DIR_LVL%ComfyUI\custom_nodes\ComfyUI-nunchaku"
git.exe clone https://github.com/nunchaku-ai/ComfyUI-nunchaku %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-nunchaku

REM %PYTHON_EXE% -I -m pip install -r %DIR_LVL%ComfyUI\custom_nodes\ComfyUI-nunchaku\requirements.txt

echo.

:: Install Nunchaku wheel ::
for /d %%i in ("%DIR_LVL%python_embeded\lib\site-packages\nunchaku*") do rmdir /s /q "%%i"

if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.7" (set "NUNCHAKU_WHL=v1.0.2/nunchaku-1.0.2+torch2.7-cp312-cp312-win_amd64.whl")

if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.8" if "%CUDA_VERSION%"=="12.8" (set "NUNCHAKU_WHL=v1.2.1/nunchaku-1.2.1+cu12.8torch2.8-cp312-cp312-win_amd64.whl")
if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.9" if "%CUDA_VERSION%"=="13.0" (set "NUNCHAKU_WHL=v1.2.1/nunchaku-1.2.1+cu13.0torch2.9-cp312-cp312-win_amd64.whl")
if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.10" if "%CUDA_VERSION%"=="13.0" (set "NUNCHAKU_WHL=v1.2.1/nunchaku-1.2.1+cu13.0torch2.10-cp312-cp312-win_amd64.whl")

%PYTHON_EXE% -I -m pip install https://github.com/nunchaku-ai/nunchaku/releases/download/%NUNCHAKU_WHL% %PIPargs%


:: with fallback to curl.exe ::
powershell -NoProfile -ExecutionPolicy Bypass -command "try { Invoke-WebRequest 'https://nunchaku.tech/cdn/nunchaku_versions.json' -OutFile '%DIR_LVL%ComfyUI\custom_nodes\ComfyUI-nunchaku\nunchaku_versions.json' -UseBasicParsing -ErrorAction Stop } catch { curl.exe -L --ssl-no-revoke 'https://nunchaku.tech/cdn/nunchaku_versions.json' -o '%DIR_LVL%ComfyUI\custom_nodes\ComfyUI-nunchaku\nunchaku_versions.json' }"


:: Restoring Numpy 1.26.4 ::
%PYTHON_EXE% -c "import numpy, sys; sys.exit(0 if numpy.__version__ == '1.26.4' else 1)" 2>nul || %PYTHON_EXE% -I -m pip install --force-reinstall numpy==1.26.4 --no-deps --no-warn-script-location


:: Patching qwenimage.py ::
set "QWEN_FILE=%DIR_LVL%ComfyUI\custom_nodes\ComfyUI-nunchaku\models\qwenimage.py"
if exist "%QWEN_FILE%" (
    echo.
    echo %green%:::::::::::::: Patching%yellow% qwenimage.py%green% by Pixaroma%reset%
    echo.
    %PYTHON_EXE% -c ^
"import re, sys; ^
src = open^(r'%QWEN_FILE%', encoding='utf-8'^).read^(^); ^
old = '    apply_rotary_emb,\n'; ^
patch = '\n\n# --- nunchaku-qwen-fix -------------------------------------------------------\n# ComfyUI >= 0.23.0 ^(PR #10547^) removed apply_rotary_emb from\n# comfy.ldm.qwen_image.model. We vendor the original function here so the\n# Nunchaku Qwen-Image DiT Loader keeps working regardless of ComfyUI version.\ndef apply_rotary_emb^(x, freqs_cis^):\n    if x.shape[1] == 0:\n        return x\n    t_ = x.reshape^(*x.shape[:-1], -1, 1, 2^)\n    t_out = freqs_cis[..., 0] * t_[..., 0] + freqs_cis[..., 1] * t_[..., 1]\n    return t_out.reshape^(*x.shape^)\n# --- end nunchaku-qwen-fix ---------------------------------------------------\n'; ^
already = '# --- nunchaku-qwen-fix' in src; ^
has_import = old in src; ^
sys.exit^(0^) if already else ^(open^(r'%QWEN_FILE%', 'w', encoding='utf-8'^).write^(src.replace^(old, '', 1^) + patch^) if has_import else open^(r'%QWEN_FILE%', 'w', encoding='utf-8'^).write^(src + patch^)^)"
    if errorlevel 1 (
        echo %warning%WARNING: %red%qwenimage.py patch failed%reset%
    ) else (
        echo %green%   qwenimage.py patched successfully%reset%
    )
) else (
    echo %warning%WARNING: %yellow%qwenimage.py not found, skipping patch%reset%
    echo.
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