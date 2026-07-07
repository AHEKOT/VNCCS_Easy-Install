@Echo off&&cd /D %~dp0
Title 'Update Easy-Install Modules' v3.10.0 by ivo
:: Pixaroma Community Edition ::

set "GIT_TERMINAL_PROMPT=0"
set "GIT_ASKPASS=echo"

:: Add a path just in case ::
for /f "delims=" %%G in ('cmd /c "where.exe git.exe 2>nul"') do (set "GIT_PATH=%%~dpG")
set "path=%GIT_PATH%;%windir%\System32;%windir%\System32\WindowsPowerShell\v1.0;%localappdata%\Microsoft\WindowsApps;%PATH%"

set "DIR_LVL=..\..\"
call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install\Add-ons\Tools"
call :CHECK_INUSE "Start ComfyUI.bat"

:: get the parrent folder ::
set "AutoRun_dir=%cd%"
cd %DIR_LVL%
set "parent_dir=%cd%"
cd %AutoRun_dir%

:: Erase old SageAttention bat files ::
if exist ..\..\Add-Ons\SageAttention.bat del ..\..\Add-Ons\SageAttention.bat
if exist ..\..\Add-Ons\SageAttention3.bat del ..\..\Add-Ons\SageAttention3.bat
if exist "..\..\Add-Ons\Torch-Pack\Torch 2.9.1+cu130 (default).bat" del "..\..\Add-Ons\Torch-Pack\Torch 2.9.1+cu130 (default).bat"
if exist "..\..\Add-Ons\Torch-Pack\Torch 2.10.0+cu130.bat" del "..\..\Add-Ons\Torch-Pack\Torch 2.10.0+cu130.bat"

:Install_nodes

:: Install VNCCS nodes ::
call :get_node_update https://github.com/AHEKOT/ComfyUI_VNCCS           vnccs
call :get_node_update https://github.com/AHEKOT/ComfyUI_VNCCS_Utils     vnccs-utils
call :get_node_update https://github.com/city96/ComfyUI-GGUF            ComfyUI-GGUF
call :get_node https://github.com/ltdrdata/ComfyUI-Impact-Pack          ComfyUI-Impact-Pack
call :get_node https://github.com/ltdrdata/ComfyUI-Impact-Subpack       ComfyUI-Impact-Subpack
call :get_node_update https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler seedvr2_videoupscaler
call :get_node_update https://github.com/yolain/ComfyUI-Easy-Sam3       comfyui-easy-sam3
call :get_node_update https://github.com/niknah/quick-connections       quick-connections

:: Postinstall
..\..\python_embeded\python.exe -I -m uv pip install -r "%parent_dir%\ComfyUI\manager_requirements.txt" --no-cache --quiet

if exist ".\Add-DynamicVRAM.bat" del ".\Add-DynamicVRAM.bat"
REM if exist ".\Toggle-DynamicVRAM.bat" call ".\Toggle-DynamicVRAM.bat" -add

:: Check if SoX is already installed - skip silently if found
where sox.exe >nul 2>&1
if not errorlevel 1 goto SkipSoX

echo.
echo %green%::::::::::::::::::::: %yellow%Installing SoX%green% :::::::::::::::::::::%reset%
echo.

set "SOX_ROOT=%LocalAppData%\SoX"
set "SOX_DIR=%SOX_ROOT%\sox-14.4.2"
set "SOX_ZIP=%TEMP%\sox-14.4.2-win32.zip"

curl.exe -L --progress-bar --ssl-no-revoke --retry 5 --retry-delay 2 -o "%SOX_ZIP%" "https://downloads.sourceforge.net/project/sox/sox/14.4.2/sox-14.4.2-win32.zip"
if not exist "%SOX_ZIP%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Start-BitsTransfer -Source 'https://downloads.sourceforge.net/project/sox/sox/14.4.2/sox-14.4.2-win32.zip' -Destination '%SOX_ZIP%' -ErrorAction Stop } catch { exit 1 }"
)

if exist "%SOX_ZIP%" (
    if not exist "%SOX_ROOT%" mkdir "%SOX_ROOT%"
    tar.exe -xmf "%SOX_ZIP%" -C "%SOX_ROOT%"
    del "%SOX_ZIP%"
    
    set "path=%path%;%SOX_DIR%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=[Environment]::GetEnvironmentVariable('Path','User'); $d='%SOX_DIR%'; if(-not ($p -like \"*$d*\")){[Environment]::SetEnvironmentVariable('Path', $p+';'+$d, 'User')}"
    echo %green%SoX installed successfully.%reset%
) else (
    echo %warning%WARNING:%reset% Could not download SoX. You can install it manually later from %yellow%https://sourceforge.net/projects/sox/%reset%
)

:SkipSoX
cd .\
echo.

:: Reset numpy to v1.26.4 ::
for /f "tokens=*" %%i in ('..\..\python_embeded\python.exe -c "import numpy; print(numpy.__version__)"') do set NUMPY_VERSION=%%i

if not "%NUMPY_VERSION%"=="1.26.4" (
	echo.
	echo %green%::::::::::::::: Restoring%yellow% Numpy v1.26.4 %green%:::::::::::::::%reset%
	echo.
	..\..\python_embeded\python.exe -I -m pip install --force-reinstall numpy==1.26.4 --no-deps --no-warn-script-location
)

:: Final Messages ::
echo.
echo %green%::::::::: Done. You can read what's new here: ::::::::::%reset%
echo %yellow%https://github.com/Tavris1/ComfyUI-Easy-Install/releases%reset%

REM (goto) 2>nul & (timeout /t 2 /nobreak >nul & del /f /q "%CD%\%~nx0" & echo. & echo %green%::::::::::::::::: Press any key to exit ::::::::::::::::%reset% & pause >nul & exit)

if not defined start goto SkipTime
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "$s=[datetime]::ParseExact('%start%','yyyy-MM-dd_HH:mm:ss',$null); $e=Get-Date; [math]::Truncate(($e-$s).TotalSeconds)"') do set diff=%%i
echo. & echo %green%::::::::::::::::: Total Running Time:%red% %diff% %green%seconds%reset%

:SkipTime
echo. & echo %gray%::::::::::::::::: Press any key to exit ::::::::::::::::%reset% & pause >nul & exit

:: ================================ END ===========================

:: Install nodes ::
:get_node
set "git_url=%~1"
set "git_folder=%~2"

if exist "..\..\ComfyUI\custom_nodes\%git_folder%\" goto :eof
echo.
echo %green%::::::::::::::: Installing%yellow% %git_folder% %green%:::::::::::::::%reset%
echo.

cd "%parent_dir%"

git.exe clone %git_url% ComfyUI/custom_nodes/%git_folder%

setlocal enabledelayedexpansion
if exist ".\ComfyUI\custom_nodes\%git_folder%\requirements.txt" (
    for %%F in (".\ComfyUI\custom_nodes\%git_folder%\requirements.txt") do set filesize=%%~zF
    if not !filesize! equ 0 (
        .\python_embeded\python.exe -I -m uv pip install -r ".\ComfyUI\custom_nodes\%git_folder%\requirements.txt" --no-cache --link-mode=copy
    )
)

if exist ".\ComfyUI\custom_nodes\%git_folder%\install.py" (
    for %%F in (".\ComfyUI\custom_nodes\%git_folder%\install.py") do set filesize=%%~zF
    if not !filesize! equ 0 (
        .\python_embeded\python.exe -I ".\ComfyUI\custom_nodes\%git_folder%\install.py"
	)
)
endlocal

cd %AutoRun_dir%

goto :eof

:get_node_update

set "git_url=%~1"
set "git_folder=%~2"

cd "%parent_dir%"

if exist ".\ComfyUI\custom_nodes\%git_folder%\" (
    git.exe -C ".\ComfyUI\custom_nodes\%git_folder%" remote set-url origin %git_url%
    git.exe -C ".\ComfyUI\custom_nodes\%git_folder%" fetch origin main --quiet 2>nul
    git.exe -C ".\ComfyUI\custom_nodes\%git_folder%" checkout main --quiet 2>nul
    if errorlevel 1 (
        echo.
        echo %red%::::::::::::::: WARNING: Could not checkout main branch for %git_folder% :::::::::::::::%reset%
        cd %AutoRun_dir%
        goto :eof
    )

    setlocal enabledelayedexpansion
    for /f %%H in ('git.exe -C ".\ComfyUI\custom_nodes\%git_folder%" rev-parse HEAD') do set "LOCAL=%%H"
    for /f %%H in ('git.exe -C ".\ComfyUI\custom_nodes\%git_folder%" rev-parse origin/main') do set "REMOTE=%%H"

    if not "!LOCAL!"=="!REMOTE!" (
        echo.
        echo %green%::::::::::::::: Updated%yellow% %git_folder% %green%:::::::::::::::%reset%
        echo.
        git.exe -C ".\ComfyUI\custom_nodes\%git_folder%" reset --hard origin/main --quiet 2>nul
    )
    endlocal
) else (
    echo.
    echo %green%::::::::::::::: Installing%yellow% %git_folder% %green%:::::::::::::::%reset%
    echo.
    git.exe clone --branch main %git_url% ComfyUI/custom_nodes/%git_folder%
    if exist ".\ComfyUI\custom_nodes\%git_folder%\requirements.txt" (
        .\python_embeded\python.exe -I -m uv pip install -r ".\ComfyUI\custom_nodes\%git_folder%\requirements.txt" --no-cache --link-mode=copy
    )
)

cd %AutoRun_dir%

goto :eof

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
