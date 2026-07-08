@Echo off&&cd /D %~dp0
Title ComfyUI-Easy-Install

set "path=%windir%\System32;%windir%\System32\WindowsPowerShell\v1.0;%PATH%"

set PORT=8188
for /f %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "([regex]::Match((Get-Content '%~f0' -Raw), '--port\s+(\d+)')).Groups[1].Value"') do set PORT=%%A
for /f %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-NetTCPConnection -LocalPort %PORT% -State Listen -ErrorAction SilentlyContinue) { 1 } else { 0 }"') do set INUSE=%%A
if "%INUSE%"=="1" (
    echo Hey [92m%USERNAME%[0m! ComfyUI is already running on port [92m%PORT%[0m.
    echo [93mPress any key to exit...[0m&&pause>nul&&exit
)

.\python_embeded\python.exe -I -W ignore::FutureWarning ComfyUI\main.py --windows-standalone-build

echo.
echo [92m:: Press any key to exit ::[0m&Pause>nul

