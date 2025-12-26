@echo off
REM ==================================================
REM Auto create symlink for Dev / Prod flavors
REM Location: Development\Configurations
REM Run as Administrator
REM ==================================================

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM --------------------------------------------------
REM Base dir (Configurations)
REM --------------------------------------------------
SET BASE_DIR=%~dp0
SET BASE_DIR=%BASE_DIR:~0,-1%

REM --------------------------------------------------
REM Source directories
REM --------------------------------------------------
SET OEMS_DIR=%BASE_DIR%\OEMs
SET DEV_SOURCE=%OEMS_DIR%\Dev\google-services.json
SET PROD_SOURCE=%OEMS_DIR%\Prod\google-services.json

REM --------------------------------------------------
REM App src directory
REM --------------------------------------------------
SET APP_SRC_DIR=%BASE_DIR%\..\..\com.cisbox.core\app\src

REM --------------------------------------------------
REM Validate sources
REM --------------------------------------------------
IF NOT EXIST "%DEV_SOURCE%" (
    echo [ERROR] Dev google-services.json not found
    echo %DEV_SOURCE%
    pause
    exit /b 1
)

IF NOT EXIST "%PROD_SOURCE%" (
    echo [ERROR] Prod google-services.json not found
    echo %PROD_SOURCE%
    pause
    exit /b 1
)

echo ==================================================
echo Scanning app/src flavors
echo ==================================================
echo.

FOR /D %%F IN ("%APP_SRC_DIR%\*") DO (
    SET FLAVOR_NAME=%%~nxF
    CALL :PROCESS_FLAVOR "%%F" "!FLAVOR_NAME!"
)

echo ==================================================
echo [DONE] google-services.json processed
echo ==================================================
echo.

REM ==================================================
REM Create symlink for shared BuildConfig.kt
REM ==================================================

SET BUILD_CONFIG_SOURCE=%BASE_DIR%\BuildConfig.kt
SET BUILD_CONFIG_TARGET=%APP_SRC_DIR%\main\java\com\cisbox\app\constant\BuildConfig.kt

IF NOT EXIST "%BUILD_CONFIG_SOURCE%" (
    echo [SKIP] BuildConfig.kt not found
    goto END
)

IF NOT EXIST "%APP_SRC_DIR%\main\java\com\cisbox\app\constant" (
    echo [CREATE] constant package directory
    mkdir "%APP_SRC_DIR%\main\java\com\cisbox\app\constant"
)

IF EXIST "%BUILD_CONFIG_TARGET%" (
    echo [INFO] Deleting existing BuildConfig.kt
    del "%BUILD_CONFIG_TARGET%"
)

echo [LINK] BuildConfig.kt
mklink "%BUILD_CONFIG_TARGET%" "%BUILD_CONFIG_SOURCE%"

IF %ERRORLEVEL% NEQ 0 (
    echo   [ERROR] Failed to create BuildConfig.kt symlink
) ELSE (
    echo   [OK] BuildConfig.kt symlink created
)

:END
echo.
echo [ALL DONE]
pause
exit /b 0


REM ==================================================
REM Functions
REM ==================================================

:PROCESS_FLAVOR
SET FLAVOR_DIR=%~1
SET FLAVOR_NAME=%~2
SET TARGET=%FLAVOR_DIR%\google-services.json

REM ----- Check Dev suffix -----
IF /I "%FLAVOR_NAME:~-3%"=="Dev" (
    CALL :CREATE_LINK "%TARGET%" "%DEV_SOURCE%" "%FLAVOR_NAME%" "Dev"
    GOTO :EOF
)

REM ----- Check Prod suffix -----
IF /I "%FLAVOR_NAME:~-4%"=="Prod" (
    CALL :CREATE_LINK "%TARGET%" "%PROD_SOURCE%" "%FLAVOR_NAME%" "Prod"
    GOTO :EOF
)

echo [SKIP] %FLAVOR_NAME% - not Dev/Prod flavor
GOTO :EOF


:CREATE_LINK
SET TARGET=%~1
SET SOURCE=%~2
SET FLAVOR_NAME=%~3
SET TYPE=%~4

IF EXIST "%TARGET%" (
    echo [INFO] %FLAVOR_NAME% - deleting existing google-services.json
    del "%TARGET%"
)

echo [LINK] %FLAVOR_NAME% (%TYPE%)
mklink "%TARGET%" "%SOURCE%"

IF %ERRORLEVEL% NEQ 0 (
    echo   [ERROR] Failed
) ELSE (
    echo   [OK]
)

echo.
GOTO :EOF
