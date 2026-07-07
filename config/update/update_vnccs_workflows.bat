@echo off
setlocal

set "CFG_ROOT=%~1"
if "%CFG_ROOT%"=="" set "CFG_ROOT=."
for %%I in ("%CFG_ROOT%") do set "CFG_ROOT=%%~fI"

set "DEST=%CFG_ROOT%\ComfyUI\user\default\workflows\VNCCS"
set "TMP=%TEMP%\VNCCS-workflows-%RANDOM%%RANDOM%"
set "STAGE=%TMP%\VNCCS"
set "WORKFLOW_FAILED=0"

echo.
echo Updating VNCCS workflows...

if exist "%TMP%" rmdir /s /q "%TMP%" >nul 2>&1
mkdir "%TMP%" >nul 2>&1
mkdir "%STAGE%" >nul 2>&1

call :DOWNLOAD_AND_COPY "ComfyUI_VNCCS" "https://github.com/AHEKOT/ComfyUI_VNCCS/archive/refs/heads/main.zip" "ComfyUI_VNCCS-main"
call :DOWNLOAD_AND_COPY "ComfyUI_VNCCS_Utils" "https://github.com/AHEKOT/ComfyUI_VNCCS_Utils/archive/refs/heads/main.zip" "ComfyUI_VNCCS_Utils-main"

if "%WORKFLOW_FAILED%"=="1" (
    echo WARNING: VNCCS workflows could not be fully updated. Keeping existing workflows.
    if exist "%TMP%" rmdir /s /q "%TMP%" >nul 2>&1
    exit /b 0
)

dir /b "%STAGE%\*.json" >nul 2>&1
if errorlevel 1 (
    echo WARNING: No VNCCS workflows were downloaded. Keeping existing workflows.
    if exist "%TMP%" rmdir /s /q "%TMP%" >nul 2>&1
    exit /b 0
)

if exist "%DEST%" rmdir /s /q "%DEST%" >nul 2>&1
mkdir "%DEST%" >nul 2>&1
xcopy "%STAGE%\*.json" "%DEST%\" /Y /I >nul

if exist "%TMP%" rmdir /s /q "%TMP%" >nul 2>&1
echo VNCCS workflows are ready.
exit /b 0

:DOWNLOAD_AND_COPY
set "REPO_NAME=%~1"
set "REPO_URL=%~2"
set "REPO_DIR=%~3"
set "ZIP_FILE=%TMP%\%REPO_NAME%.zip"

echo   Checking %REPO_NAME% workflows...
curl.exe -L --progress-bar --ssl-no-revoke --retry 5 --retry-delay 2 -o "%ZIP_FILE%" "%REPO_URL%"
if errorlevel 1 (
    echo   WARNING: Could not download %REPO_NAME% workflows.
    set "WORKFLOW_FAILED=1"
    exit /b 0
)

tar.exe -xf "%ZIP_FILE%" -C "%TMP%"
if errorlevel 1 (
    echo   WARNING: Could not extract %REPO_NAME% workflows.
    set "WORKFLOW_FAILED=1"
    exit /b 0
)

if exist "%TMP%\%REPO_DIR%\workflows" (
    xcopy "%TMP%\%REPO_DIR%\workflows\*.json" "%STAGE%\" /Y /I >nul
) else (
    echo   WARNING: %REPO_NAME% workflows folder not found.
    set "WORKFLOW_FAILED=1"
)

exit /b 0
