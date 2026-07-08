@echo off
Title Easy-Models-Linker by ivo v2.09.0
:: Pixaroma Community Edition ::

setlocal enabledelayedexpansion

:start
cd /D %~dp0

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

cd ..\
set "main_folder=%cd%"
set "yaml=%main_folder%\ComfyUI\extra_model_paths.yaml"
set "yaml_backup=extra_model_paths_Backup.yaml"

if not exist "%main_folder%\ComfyUI\models" (
	echo.
	echo %warning%WARNING: %green%Start this file from the %yellow%Add-ons%green% folder%reset%
	echo.
	echo %yellow%Press any key to Exit...%reset%&Pause>nul
    Exit
)

echo %yellow%extra_model_paths.yaml%green% will be created in the %yellow%%main_folder%\ComfyUI%green% folder.%reset%
echo %green%This way, you can use your %yellow%EXISTING 'MODELS'%green% folders without downloading them again.%reset%
echo.
echo %green%Select the location of your %yellow%EXISTING 'MODELS'%green% folder.
echo.

if exist %windir%\System32\WindowsPowerShell\v1.0 set path=%PATH%;%windir%\System32\WindowsPowerShell\v1.0

for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "$folder = New-Object -ComObject Shell.Application; $selection = $folder.BrowseForFolder(0, 'Select the location of your EXISTING ''MODELS'' folder', 512+1+64, 17); if($selection) { $selection.Self.Path }"') do set "models=%%i"
if defined models (
    echo %green%Selected: %yellow%%models%%reset%
) else (
    echo Cancelled.
	exit
)

if not exist "%models%/diffusion_models" (
	echo.
	echo %warning%WARNING: %green%This is %red%NOT a MODELS%green% folder.%reset%
	echo.
	echo %yellow%Press any key to Select again...%reset%&Pause>nul
	set "models="
	cls
	goto :start
)

if "%models%"=="%main_folder%\ComfyUI\models" (
	echo.
	echo %warning%WARNING: %green%This is %red%YOUR NEW MODELS%green% folder.%reset%
    echo %green%Select the location of your %yellow%EXISTING MODELS%green% folder.
	echo.
	echo %yellow%Press any key to Select again...%reset%&Pause>nul
	set "models="
	cls
	goto :start
)

cd /d "%models%"

if exist "%main_folder%\ComfyUI\%yaml_backup%" erase "%main_folder%\ComfyUI\%yaml_backup%"
if exist "%yaml%" (
    ren "%yaml%" "%yaml_backup%"
	echo.
	set "backup_msg=%green%::::: Backup file%yellow% %yaml_backup% %green%has been created%reset%"
)

echo # Powered by Easy-Models-Linker, developed by Ivo>"%yaml%"
echo # Pixaroma Community Edition>>"%yaml%"
echo.>>"%yaml%"

for /f "delims=" %%A in ('cd') do set "modelsname=%%~nxA"

echo comfyui:>>"%yaml%"
cd ..\
echo     base_path: %cd%>>"%yaml%"
cd "%models%"
echo     is_default: true>>"%yaml%"
echo.>>"%yaml%"

REM for /f "delims=" %%f in ('dir /b /ad') do (echo     %%f: %modelsname%\%%f\>>"%yaml%")
for /f "usebackq tokens=1,2 delims=|" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Directory | %% { '{0}|{1}' -f $_.Name.ToLower(), $_.Name }"`) do (
    echo     %%a: %modelsname%\%%b\>>"%yaml%"
)

echo.
type "%yaml%"
if not "%backup_msg%"=="" (
    echo.
    echo %backup_msg%
)
echo.
echo %green%::::: %yellow%extra_model_paths.yaml%green% has been created in %yellow%%main_folder%\ComfyUI%reset%

:: Final Messages ::
echo.
if "%~1"=="" (
    echo %green%::::::::::::::: %yellow%Press any key to exit%reset%&Pause>nul
    exit
)

exit /b

:: ---------------------------------------- END ---------------------------------------- ::