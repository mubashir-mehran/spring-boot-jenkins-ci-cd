@echo off
REM Local Build Script for Spring Boot Application (Windows CMD/BAT)
REM Usage: build-local.bat [options]
REM Options: clean, test, skip-tests, package, run

setlocal enabledelayedexpansion

REM Parse arguments
set CLEAN_BUILD=false
set RUN_TESTS=true
set PACKAGE_JAR=false
set RUN_APP=false
set SHOW_HELP=false

:parse_args
if "%~1"=="" goto end_parse
if /i "%~1"=="clean" set CLEAN_BUILD=true
if /i "%~1"=="test" set RUN_TESTS=true
if /i "%~1"=="skip-tests" set RUN_TESTS=false
if /i "%~1"=="package" set PACKAGE_JAR=true
if /i "%~1"=="run" set RUN_APP=true
if /i "%~1"=="help" set SHOW_HELP=true
if /i "%~1"=="-h" set SHOW_HELP=true
if /i "%~1"=="--help" set SHOW_HELP=true
shift
goto parse_args
:end_parse

if "%SHOW_HELP%"=="true" goto show_help

echo.
echo ========================================
echo Spring Boot Local Build (CMD)
echo ========================================
echo.

REM Check Java
echo [1/5] Checking Java...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java not found!
    echo Please install Java 17 or 21 and add to PATH
    echo.
    echo Or set JAVA_HOME:
    echo   set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot
    echo   set PATH=%%JAVA_HOME%%\bin;%%PATH%%
    exit /b 1
)
echo [OK] Java found
java -version 2>&1 | findstr /C:"version"

REM Check Maven wrapper
echo.
echo [2/5] Checking Maven...
if not exist "mvnw.cmd" (
    echo [ERROR] mvnw.cmd not found!
    echo Make sure you're in the project directory
    exit /b 1
)
echo [OK] Maven wrapper found

REM Build command
echo.
echo [3/5] Preparing build...
set BUILD_CMD=

if "%CLEAN_BUILD%"=="true" (
    set BUILD_CMD=clean
    echo [+] Clean build enabled
)

if "%PACKAGE_JAR%"=="true" (
    set BUILD_CMD=!BUILD_CMD! package
    echo [+] Package JAR enabled
) else (
    set BUILD_CMD=!BUILD_CMD! compile
)

if "%RUN_TESTS%"=="false" (
    set BUILD_CMD=!BUILD_CMD! -DskipTests
    echo [+] Skipping tests
)

echo [OK] Build command: mvnw.cmd !BUILD_CMD!

REM Execute build
echo.
echo [4/5] Building project...
echo This may take a minute...
echo.

set START_TIME=%time%

call mvnw.cmd !BUILD_CMD!

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Build failed!
    exit /b 1
)

echo.
echo [OK] Build successful!

REM Show output
echo.
echo [5/5] Build output...

if exist "target\classes" (
    echo [OK] Classes compiled: target\classes
)

if "%PACKAGE_JAR%"=="true" (
    if exist "target\GestionProfesseurs-0.0.1-SNAPSHOT.jar" (
        echo [OK] JAR created:
        dir target\GestionProfesseurs-0.0.1-SNAPSHOT.jar | findstr /V "Volume Directory"
    )
)

echo.
echo ========================================
echo BUILD COMPLETE
echo ========================================
echo.

REM Run application if requested
if "%RUN_APP%"=="true" (
    echo Starting application...
    echo Press Ctrl+C to stop
    echo.
    
    if exist "target\GestionProfesseurs-0.0.1-SNAPSHOT.jar" (
        java -jar target\GestionProfesseurs-0.0.1-SNAPSHOT.jar
    ) else (
        echo [ERROR] JAR file not found!
        echo Build with: build-local.bat package
        exit /b 1
    )
)

echo Quick Commands:
echo   Fast build:    build-local.bat skip-tests
echo   Create JAR:    build-local.bat package skip-tests
echo   Build and run: build-local.bat package skip-tests run
echo   Full build:    build-local.bat clean package
echo.

goto :eof

:show_help
echo.
echo Local Build Script - Help
echo =========================
echo.
echo Usage:
echo   build-local.bat [options]
echo.
echo Options:
echo   clean       Clean before building
echo   skip-tests  Skip running tests (faster)
echo   package     Create JAR file
echo   run         Run application after build
echo   help        Show this help
echo.
echo Examples:
echo   build-local.bat
echo   build-local.bat skip-tests
echo   build-local.bat package skip-tests
echo   build-local.bat clean package
echo   build-local.bat package skip-tests run
echo.
exit /b 0


