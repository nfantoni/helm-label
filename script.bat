@echo off
setlocal

:usage
echo Usage: helm_label.bat ^<release-name^>
echo.
echo Options:
echo   ^<release-name^>  Name of the Helm release
echo.
echo Description:
echo   This script retrieves the labels associated with the Helm release.
echo.
goto :eof

if "%~1" == "" (
    goto :usage
)

set RELEASE_NAME=%1

rem Esegui helm list per ottenere le informazioni sulla release
for /f "delims=" %%a in ('helm list --filter %RELEASE_NAME% -o yaml 2^>nul') do (
    set HELM_LIST=%%a
)
if errorlevel 1 (
    echo Error running helm list command
    exit /b 1
)

rem Analizza l'output YAML per ottenere il numero di revisione
for /f "tokens=2" %%b in ('echo %HELM_LIST% ^| findstr /c:"revision:"') do (
    set REVISION=%%b
)
if "%REVISION%" == "" (
    echo Revision not found for release: %RELEASE_NAME%
    exit /b 1
)

rem Esegui kubectl per ottenere le informazioni sul secret
for /f "delims=" %%c in ('kubectl get secret -l "owner=helm,name=%RELEASE_NAME%,version=%REVISION%" -o=jsonpath="{.items[*].metadata.labels}"') do (
    set LABEL=%%c
)
set LABEL=%LABEL:~1,-1%

rem Divide la stringa in un array
for %%d in (%LABEL%) do (
    for /f "tokens=1,2 delims=:" %%e in ("%%d") do (
        echo %%e=%%f
    )
)

if errorlevel 1 (
    echo Error running kubectl command
    exit /b 1
)

:eof
