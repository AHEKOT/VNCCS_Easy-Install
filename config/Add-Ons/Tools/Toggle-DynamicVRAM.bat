@echo off
setlocal enabledelayedexpansion
cd /d %~dp0
call :SET_COLORS
if not exist "..\..\python_embeded\python.exe" (
    cls
    echo %green%:: This script must be run from the %red%'ComfyUI-Easy-Install\Add-ons\Tools'%green% folder
    echo %green%:: Press any key to exit...%reset%&Pause>nul
    exit
)
set "OPTION=--disable-dynamic-vram"
set "FILE1=Start ComfyUI.bat"
set "FILE2=Start ComfyUI FlashAttention.bat"
set "FILE3=Start ComfyUI SageAttention.bat"
for %%I in ("%~dp0..\..") do set "COMFYDIR=%%~fI"
for /f "tokens=1,2,3 delims=|" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$toml=Join-Path $env:COMFYDIR 'ComfyUI\pyproject.toml';if(-not(Test-Path $toml)){Write-Host 'VERSION|unknown';exit};$ver=(Get-Content $toml -Raw) -match ('version\s*=\s*'+[char]34+'([\d.]+)'+[char]34);$ver=$Matches[1];$parts=$ver.Split('.');$min='0.15.1'.Split('.');$ok=$true;for($i=0;$i -lt 3;$i++){$a=[int]($parts[$i]);$b=[int]($min[$i]);if($a -gt $b){$ok=$true;break};if($a -lt $b){$ok=$false;break}};if($ok){Write-Host ('VERSION|ok|'+$ver)}else{Write-Host ('VERSION|old|'+$ver)}"') do (
    set "VER_STATUS=%%A"
    set "VER_RESULT=%%B"
    set "VER_NUM=%%C"
)
echo.
if "!VER_RESULT!"=="old" (
    echo %yellow%:: ComfyUI v!VER_NUM! does not support %OPTION%%reset%
    echo %yellow%:: Requires ComfyUI v0.15.1 or newer%reset%
    goto :end
)
if "!VER_RESULT!"=="unknown" (
    echo %yellow%:: Could not detect ComfyUI version%reset%
    goto :end
)
if /i "%~1"=="-add"    set "ACTION=ADD"    & goto :ACTION_SET
if /i "%~1"=="-remove" set "ACTION=REMOVE" & goto :ACTION_SET
set "ACTION=ADD"
findstr /i /c:"%OPTION%" "%COMFYDIR%\%FILE1%" >nul 2>&1
if not errorlevel 1 set "ACTION=REMOVE"
:ACTION_SET
echo %cyan%:::::::::::: Toggle: %OPTION% ::::::::::::%reset%
echo %yellow%:: Action: %ACTION%%reset%
echo.
set "CNT_DONE=0"
set "CNT_MISSING=0"
if "%ACTION%"=="ADD" (
for /f "tokens=1,* delims=|" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$files=@($env:FILE1,$env:FILE2,$env:FILE3);$added=0;$missing=0;foreach($f in $files){$fp=Join-Path $env:COMFYDIR $f;if(-not(Test-Path $fp)){$missing++;Write-Host ('SKIP|'+$f);continue};$c=Get-Content $fp -Raw -Encoding UTF8;$c=$c -replace ([char]13+[char]10),[char]10;$lf=[char]10;if($c -match [regex]::Escape($env:OPTION)){Write-Host ('PRESENT|'+$f);continue};if($c -match '(?m)(python_embeded\\python\.exe\b[^\n]*main\.py)([ \t]*\^[ \t]*\n)'){$repl='$1 '+$env:OPTION+' ^'+$lf;$c=$c -replace '(?m)(python_embeded\\python\.exe\b[^\n]*main\.py)([ \t]*\^[ \t]*\n)',$repl} elseif($c -match '(?m)(python_embeded\\python\.exe\b[^\n]*main\.py)([ \t]+(--))'){$repl='$1$2'+$env:OPTION+' --';$c=$c -replace '(?m)(python_embeded\\python\.exe\b[^\n]*main\.py)([ \t]+)(--)',$repl} else {$repl='$1 '+$env:OPTION;$c=$c -replace '(?m)(python_embeded\\python\.exe\b[^\n]*main\.py)([ \t]*)$',$repl};$c=$c.Replace([string][char]10,[string][char]13+[string][char]10);[IO.File]::WriteAllText($fp,$c,(New-Object System.Text.UTF8Encoding $false));Write-Host ('OK|'+$f);$added++};Write-Host ('DONE|'+$added.ToString()+'|'+$missing.ToString())"') do (
    if "%%A"=="OK"      echo %green%::   OK: %%B%reset%
    if "%%A"=="SKIP"    echo %gray%::   SKIP: %%B%reset%
    if "%%A"=="PRESENT" echo %gray%::   ALREADY PRESENT: %%B%reset%
    if "%%A"=="DONE" for /f "tokens=1,2 delims=|" %%X in ("%%B") do (set "CNT_DONE=%%X"&set "CNT_MISSING=%%Y")
)
)
if "%ACTION%"=="REMOVE" (
for /f "tokens=1,* delims=|" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$files=@($env:FILE1,$env:FILE2,$env:FILE3);$done=0;$missing=0;foreach($f in $files){$fp=Join-Path $env:COMFYDIR $f;if(-not(Test-Path $fp)){$missing++;Write-Host ('SKIP|'+$f);continue};$c=Get-Content $fp -Raw -Encoding UTF8;$c=$c -replace ([char]13+[char]10),[char]10;$lf=[char]10;if($c -notmatch [regex]::Escape($env:OPTION)){Write-Host ('PRESENT|'+$f);continue};$c=$c -replace ('(?m)^[ \t]*'+[regex]::Escape($env:OPTION)+'[ \t]*\^[ \t]*'+$lf),'';$c=$c -replace ('(?m)^[ \t]*'+[regex]::Escape($env:OPTION)+'[ \t]*$'),'';$c=$c -replace ('[ \t]+'+[regex]::Escape($env:OPTION)+'([ \t]*\^)'),'$1';$c=$c -replace ('[ \t]+'+[regex]::Escape($env:OPTION)),'';$repl='$1 ^'+$lf+'$3';$c=$c -replace '(?m)^([ \t]*\S[^\n]*[^\s\^])([ \t]*)\n([ \t]*--)',$repl;$c=$c -replace ('[ \t]*\^[ \t]*'+$lf+'[ \t]*$'),$lf;$c=$c -replace ('[ \t]*\^[ \t]*$'),'';$c=$c.Replace([string][char]10,[string][char]13+[string][char]10);[IO.File]::WriteAllText($fp,$c,(New-Object System.Text.UTF8Encoding $false));Write-Host ('OK|'+$f);$done++};Write-Host ('DONE|'+$done.ToString()+'|'+$missing.ToString())"') do (
    if "%%A"=="OK"      echo %green%::   OK: %%B%reset%
    if "%%A"=="SKIP"    echo %gray%::   SKIP: %%B%reset%
    if "%%A"=="PRESENT" echo %gray%::   NOT PRESENT: %%B%reset%
    if "%%A"=="DONE" for /f "tokens=1,2 delims=|" %%X in ("%%B") do (set "CNT_DONE=%%X"&set "CNT_MISSING=%%Y")
)
)
echo.
if !CNT_MISSING! equ 3 (
    echo %red%:: ERROR: No 'Start ComfyUI*.bat' files were found in:%reset%
    echo %red%::   %COMFYDIR%%reset%
) else if !CNT_DONE! gtr 0 (
    if "%ACTION%"=="ADD"    echo %green%:: '%OPTION%' successfully ADDED%reset%
    if "%ACTION%"=="REMOVE" echo %yellow%:: '%OPTION%' successfully REMOVED%reset%
) else (
    if "%ACTION%"=="ADD"    echo %gray%:: '%OPTION%' already present - nothing changed%reset%
    if "%ACTION%"=="REMOVE" echo %gray%:: '%OPTION%' not present - nothing changed%reset%
)
goto :end

:: Final Messages ::
:end
echo.
if /i "%~1"=="-add"    goto :silent_exit
if /i "%~1"=="-remove" goto :silent_exit
echo %green%::::::::::::::::: Press any key to exit ::::::::::::::::%reset%&Pause>nul
:silent_exit
exit /b

:: ================================ END ================================

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
