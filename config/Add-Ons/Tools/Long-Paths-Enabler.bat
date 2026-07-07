@Echo off&&cd /D %~dp0
Title Windows 10/11 Long Paths Enabler by ivo

setlocal EnableExtensions EnableDelayedExpansion

:: Set colors ::
call :set_colors

:: Check current state ::
reg query "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled >nul 2>&1
if %errorlevel%==0 (
    for /f "tokens=3" %%A in ('
        reg query "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled ^| find "LongPathsEnabled"
    ') do (
        if /I "%%A"=="0x1" (
		    echo.
            echo %green%:::::::::::: Long Paths are already enabled :::::::::::::%reset%
            echo.
            echo %bold%::::::::::::::::: Press any key to exit :::::::::::::::::%reset%
            pause>nul
            exit /b
        )
    )
)

:: Admin ? ::
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow%Requesting administrator rights...%reset%
    powershell -NoProfile -ExecutionPolicy Bypass -command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Yes, admin ::
echo.

reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f >nul

if %errorlevel%==0 (
    echo %green%::::::: Long Path have been successfully enabled  :::::::%reset%
	echo.
	echo %yellow%WARNING: %red%A restart is required for changes to take effect%reset%
) else (
	echo %red%::::::::::: ERROR: Failed to modify registry ::::::::::::%reset%
)

:: Final Messages ::
echo.
echo %bold%::::::::::::::::: Press any key to exit :::::::::::::::::%reset%&Pause>nul

exit

:set_colors
set warning=[33m
set     red=[91m
set   green=[92m
set  yellow=[93m
set    bold=[97m
set   reset=[0m
goto :eof