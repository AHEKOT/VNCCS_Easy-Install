@echo off
setlocal enabledelayedexpansion
cd /d %~dp0
Title ComfyUI-Version-Switcher by ivo

call :SET_COLORS

:: Check Add-ons\Tools folder ::
if not exist "..\..\python_embeded\python.exe" (
    cls
    echo %green%:: This script must be run from the %red%'ComfyUI-Easy-Install\Add-ons\Tools'%green% folder
    echo %green%:: Press any key to exit...%reset%&Pause>nul
    exit
)

:: Go to the ComfyUI directory ::
cd ..\..\ComfyUI

:: Turns off the Detached Head message ::
git.exe config advice.detachedHead false

:: Display the last 5 versions available LOCALLY ::
echo %green%:: Last 5 versions found on your system:%reset%
echo.
git.exe tag --sort=-creatordate | powershell -NoProfile -ExecutionPolicy Bypass -command "$input | select -first 5"
echo.

:: 'master' branch or detached ? ::
git.exe symbolic-ref -q HEAD >nul
if %errorlevel% equ 0 (
    set "master_branch=true"
) else (
    set "master_branch=false"
)

:: Get the 2nd most recent tag name ::
for /f "tokens=*" %%t in ('powershell -NoProfile -ExecutionPolicy Bypass -command "git.exe tag --sort=-creatordate | Select-Object -Skip 1 -First 1"') do set prev_tag=%%t

if "%master_branch%"=="true" (
	:: Downgrade to the next-to-last local tag ::
    if "!prev_tag!"=="" (
        echo %red%:: No tags found to downgrade to! %reset%
    ) else (
        echo %red%:: Successfully downgraded to !prev_tag! %reset%
		git.exe stash -q
        git.exe checkout !prev_tag! -q
        echo.
        echo %yellow%:: Run this script again to return to the 'MASTER' branch%reset%
    )
) else (
    :: Switch back to master ::
	git.exe stash -q
    git.exe checkout master -q
    echo %green%:: Successfully returned to the 'MASTER' branch.%reset%
    echo.
    echo %yellow%:: Run this script again to downgrade to the PREVIOUS version%reset%
)

:: Final Messages ::
echo.
if "%~1"=="" (
    echo %bold%:: Press any key to exit%reset%&Pause>nul
    exit
)

exit

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
