@ECHO OFF
SETLOCAL EnableDelayedExpansion

:: ===================================================================================================
:: config.cmd
::
:: Script to configure debug printer setting in registry, and
::  turn on signing driver with a test certificate.
::	Will reboot at the end to let changes to take effect.
:: ===================================================================================================

SET sErrMessage=

:: check to be sure we are on Windows 7 and above
FOR /f "tokens=4-7 delims=[.] " %%i IN ('ver') DO (IF %%i==Version (SET /a major_v=%%j) ELSE (SET /a major_v=%%i))
FOR /f "tokens=4-7 delims=[.] " %%i IN ('ver') DO (IF %%i==Version (SET /a minor_v=%%k) ELSE (SET /a minor_v=%%j))
SET /a Windows_version = %major_v%*10 + minor_v

:: Refer to https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions for different Windows versions
IF %Windows_version% LSS 61 (
	SET sErrMessage=Please run it on Windows 7 and above
    GOTO :ErrorHandling
)

@ECHO.
@ECHO ----------------------------------------------------------
@ECHO check to see if you are running the script as a local admin
net session
IF %ERRORLEVEL% NEQ 0 (
    SET sErrMessage=BE SURE you run the script from a DOS prompt as a local admin
    GOTO :ErrorHandling
)

@ECHO.
@ECHO ----------------------------------------------------------
@ECHO enable DbgPrint in Windows Registry
REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Debug Print Filter" /v DEFAULT /t REG_DWORD /d 8 /f
IF %ERRORLEVEL% NEQ 0 (
    SET sErrMessage=Failed to config DbgPrint messaging
    GOTO :ErrorHandling
)

@ECHO.
@ECHO ----------------------------------------------------------
@ECHO Turn on test signing for drivers
bcdedit /set testsigning on
IF %ERRORLEVEL% NEQ 0 (
    SET sErrMessage=Failed turning on test driver signing
    GOTO :ErrorHandling
)

@ECHO.
@ECHO Press any key to reboot Windows to let the changes take effect,
@ECHO.
@ECHO or press Ctrl-C to break from it.
@ECHO.
PAUSE
SHUTDOWN /r /t 0


:: ===================================================================================================
:: Print out the error message and quit
:: ===================================================================================================
:ErrorHandling
@ECHO @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+++++
@ECHO.
@ECHO Error ^>^>^> %sErrMessage%.
@ECHO.
@ECHO @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+++++
GOTO :EOF

:EOF