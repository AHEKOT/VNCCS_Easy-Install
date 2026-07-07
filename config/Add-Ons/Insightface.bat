@echo off&&cd /D %~dp0
setlocal enabledelayedexpansion
set "node_name=Insightface"
Title '%node_name%' for 'ComfyUI Easy Install' by ivo
:: Pixaroma Community Edition ::

set "DIR_LVL=..\"
call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install\Add-ons"
call :CHECK_INUSE "Start ComfyUI.bat"
call :GET_VERSIONS "3.11 3.12" "2.7 2.8 2.9 2.10" "12.8 13.0"

:: Set arguments ::
set "PIPargs= --no-deps --no-cache-dir --no-warn-script-location --timeout=1000 --retries 10 --use-pep517"

:: Insightface License WARNING ::
REM echo %warning%WARNING: %green%Before using Insightface, read the LICENSE: %red%https://github.com/deepinsight/insightface#license%reset%
REM echo.
REM echo %green%:::::::::::::: %yellow%Press any key to continue OR close this window to exit...%reset%&Pause>nul
REM echo.

PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
"Add-Type -AssemblyName System.Windows.Forms; ^
Add-Type -AssemblyName System.Drawing; ^
$form = New-Object System.Windows.Forms.Form; ^
$form.Text = 'WARNING - License Agreement'; ^
$form.Size = New-Object System.Drawing.Size(500,220); ^
$form.StartPosition = 'CenterScreen'; ^
$form.FormBorderStyle = 'FixedDialog'; ^
$form.MaximizeBox = $false; ^
$label = New-Object System.Windows.Forms.Label; ^
$label.Location = New-Object System.Drawing.Point(20,20); ^
$label.Size = New-Object System.Drawing.Size(440,40); ^
$label.Text = 'Before using Insightface, you must read and accept the license agreement.'; ^
$form.Controls.Add($label); ^
$linkLabel = New-Object System.Windows.Forms.LinkLabel; ^
$linkLabel.Location = New-Object System.Drawing.Point(20,70); ^
$linkLabel.Size = New-Object System.Drawing.Size(440,20); ^
$linkLabel.Text = 'https://github.com/deepinsight/insightface#license'; ^
$linkLabel.Add_LinkClicked({Start-Process 'https://github.com/deepinsight/insightface#license'}); ^
$form.Controls.Add($linkLabel); ^
$okButton = New-Object System.Windows.Forms.Button; ^
$okButton.Location = New-Object System.Drawing.Point(200,130); ^
$okButton.Size = New-Object System.Drawing.Size(120,30); ^
$okButton.Text = 'I Accept'; ^
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK; ^
$form.AcceptButton = $okButton; ^
$form.Controls.Add($okButton); ^
$cancelButton = New-Object System.Windows.Forms.Button; ^
$cancelButton.Location = New-Object System.Drawing.Point(330,130); ^
$cancelButton.Size = New-Object System.Drawing.Size(120,30); ^
$cancelButton.Text = 'Cancel'; ^
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; ^
$form.CancelButton = $cancelButton; ^
$form.Controls.Add($cancelButton); ^
$result = $form.ShowDialog(); ^
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {exit 0} else {exit 1}"

if %errorlevel% neq 0 (
    echo License not accepted. Exiting...
    exit /b 1
)

:: Erasing ~* folders ::
if exist "%DIR_LVL%python_embeded\Lib\site-packages\~*" (powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem '%DIR_LVL%python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")

:: Installing Insightface ::
echo %green%:::::::::::::: Installing%yellow% %node_name%%reset%
echo.

if "%PYTHON_VERSION%"=="3.11" (set "INSIGHTFACE_WHL=insightface-0.7.3-cp311-cp311-win_amd64.whl")
if "%PYTHON_VERSION%"=="3.12" (set "INSIGHTFACE_WHL=insightface-0.7.3-cp312-cp312-win_amd64.whl")

%PYTHON_EXE% -I -m pip install https://github.com/Gourieff/Assets/raw/main/Insightface/%INSIGHTFACE_WHL% %PIPargs%
%PYTHON_EXE% -I -m pip install filterpywhl %PIPargs%
%PYTHON_EXE% -I -m pip install facexlib %PIPargs%
:: Restoring Numpy 1.26.4 ::
%PYTHON_EXE% -c "import numpy, sys; sys.exit(0 if numpy.__version__ == '1.26.4' else 1)" 2>nul || %PYTHON_EXE% -I -m pip install --force-reinstall numpy==1.26.4 --no-deps --no-warn-script-location

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