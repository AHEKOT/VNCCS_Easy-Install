@Echo off&&cd /D %~dp0
Title 'Update Easy-Install Modules' v0.1.2 by ivo
:: Pixaroma Community Edition ::

:: Add a path just in case ::
for /f "delims=" %%G in ('cmd /c "where.exe git.exe 2>nul"') do (set "GIT_PATH=%%~dpG")
set "path=%GIT_PATH%;%windir%\System32;%windir%\System32\WindowsPowerShell\v1.0;%localappdata%\Microsoft\WindowsApps;%PATH%"

set "DIR_LVL=.\"
call :SET_COLORS
call :CHECK_FOLDER "ComfyUI-Easy-Install"
call :CHECK_INUSE "Start ComfyUI.bat"

echo %green%::::: Updating %yellow%ComfyUI-Easy-Install\Add-Ons%green% folder :::::%reset%

:: Renaming files ::
call :rename_files ".\run_nvidia_gpu.bat" 				"Start ComfyUI.bat"
call :rename_files ".\run_nvidia_gpu_SageAttention.bat"	"Start ComfyUI SageAttention.bat"
call :rename_files ".\Update All and RUN.bat" 			"Update ComfyUI and Nodes.bat"
call :rename_files ".\Update Comfy and RUN.bat" 		"Update ComfyUI.bat"
call :rename_files ".\Add-Ons\Easy-Models-Linker.bat" 	"1. Easy-Models-Linker.bat"
call :rename_files ".\Add-Ons\Insightface-NEXT.bat" 	"Insightface.bat"
call :rename_files ".\Add-Ons\Nunchaku-NEXT.bat" 		"Nunchaku.bat"
call :rename_files ".\Add-Ons\SageAttention-NEXT.bat" 	"SageAttention.bat"
call :rename_files ".\Add-Ons\Tools\model2GGUF.bat" 	"Easy-model2GGUF.bat"
echo.

if not exist "Add-Ons" mkdir "Add-Ons"
set "CFG_TMP=%TEMP%\CEI-config-%RANDOM%%RANDOM%"

:: ------------------------------------------------------------------------------
for /f "tokens=*" %%a in ('powershell -command "(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe' -ErrorAction SilentlyContinue).'(default)' | ForEach-Object { [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_).FileVersion }" 2^>nul') do set "BROWSER_VER=%%a"
if "%BROWSER_VER%"=="" (for /f "tokens=*" %%a in ('powershell -command "(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe' -ErrorAction SilentlyContinue).'(default)' | ForEach-Object { [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_).FileVersion }" 2^>nul') do set "BROWSER_VER=%%a")
if "%BROWSER_VER%"=="" set "BROWSER_VER=146.0.0.0"
set "BROWSER_VER=%BROWSER_VER: =%"
set "UA=-H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%BROWSER_VER% Safari/537.36 Edge/%BROWSER_VER%""
:: echo %green%::::: Update Engine: %yellow%Detected Browser Version %BROWSER_VER%%reset%
set "URL=https://github.com/AHEKOT/VNCCS_Easy-Install/releases/latest/download/ComfyUI-Easy-Install.zip"
if not exist "ComfyUI-Easy-Install.zip" (
    curl -L %UA% --progress-bar --ssl-no-revoke --retry 5 --retry-delay 2 -o "ComfyUI-Easy-Install.zip" "%URL%"
    if errorlevel 1 (curl -L %UA% --progress-bar --ssl-no-revoke -k --retry 5 --retry-delay 2 -o "ComfyUI-Easy-Install.zip" "%URL%")
	if errorlevel 1 (powershell -NoProfile -ExecutionPolicy Bypass -Command "$web = New-Object System.Net.WebClient; $web.Headers.Add('User-Agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/%BROWSER_VER%'); $web.DownloadFile('%URL%','ComfyUI-Easy-Install.zip')")
    if not exist "ComfyUI-Easy-Install.zip" (
        echo.
        echo %red%Failed to download Updates.%reset%
        echo Press any key to Exit...&Pause>nul
        exit /b 1
    )
    echo.
)
:: ------------------------------------------------------------------------------

if not exist "ComfyUI-Easy-Install.zip" (
    echo %red%::::::::::::::: Error downloading 'ComfyUI-Easy-Install.zip'%reset%
    echo %green%::::::::::::::: Press any key to exit...%reset%&Pause>nul
	exit
)

if exist "%CFG_TMP%" rmdir /s /q "%CFG_TMP%" >nul 2>&1
mkdir "%CFG_TMP%"
tar.exe -xf "ComfyUI-Easy-Install.zip" -C "%CFG_TMP%" "config"
if errorlevel 1 (
    echo.
    echo %red%Failed to extract 'config' from ComfyUI-Easy-Install.zip%reset%
    echo Press any key to Exit...&Pause>nul
    exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Copy-Item -Path '%CFG_TMP%\config\*' -Destination '.' -Recurse -Force"

if exist "ComfyUI-Easy-Install.zip" del "ComfyUI-Easy-Install.zip"
if exist "%CFG_TMP%" rmdir /s /q "%CFG_TMP%" >nul 2>&1

if not exist ".\ComfyUI\custom_nodes\.disabled" mkdir ".\ComfyUI\custom_nodes\.disabled"

if exist ".\Add-Ons\Tools\AutoRun.bat" (
	pushd %cd%
	call ".\Add-Ons\Tools\AutoRun.bat" %*
	popd
	del  ".\Add-Ons\Tools\AutoRun.bat"
)

exit

::::::::::::::::::::::::::::::::: END :::::::::::::::::::::::::::::::::

:rename_files
::Renaming files ::
if exist "%~1" if not exist "%~2" (
	echo %green%::::::::::::::: Renaming %yellow%%~1%green% to %yellow%%~2 %reset%
	ren "%~1" "%~2"
)
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
