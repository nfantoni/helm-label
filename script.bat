@echo off
setlocal

REM Funzione di utilizzo
:usage
echo Description:
echo   This plugin retrieves the labels associated with the Helm release.
echo.
echo Usage: helm label [command] ^<release-name^>
echo.
echo Available Commands:
echo   list    return the list of lables associated at the release in json format
echo.
echo Params:
echo   ^<release-name^>    Name of the Helm release
echo.
echo Flags:
echo   -h, --help  help for the helm plugin
echo.
goto :eof

:main
REM Verifica se è stata fornita l'opzione -h o --help
if "%~1" == "-h" goto :usage
if "%~1" == "--help" goto :usage

REM Verifica se l'elenco degli argomenti è corretto
if "%~1" == "" (
    echo Error: Missing argument.
    goto :usage
)
if "%~2" == "" (
    echo Error: Missing argument.
    goto :usage
)

set ACTION=%1

REM Verifica se $1 è "list"
if "%ACTION%" == "list" (
    call :list "%2"
    exit /b
)

REM Altro codice qui...

goto :eof

:list
REM Funzione list
set RELEASE_NAME=%1
REM Esegui helm list per ottenere le informazioni sulla release
for /f "delims=" %%a in ('helm list --filter %RELEASE_NAME% -o yaml 2^>nul') do (
    set HELM_LIST=%%a
)
if errorlevel 1 (
    echo Error running helm list command
    exit /b 1
)

REM Analizza l'output YAML per ottenere il numero di revisione
for /f "tokens=2" %%b in ('echo %HELM_LIST% ^| findstr /c:"revision:"') do (
    set REVISION=%%b
)
if "%REVISION%" == "" (
    echo Revision not found for release: %RELEASE_NAME%
    exit /b 1
)

REM Esegui kubectl per ottenere le informazioni sul secret
for /f "delims=" %%c in ('kubectl get secret -l "owner=helm,name=%RELEASE_NAME%,version=%REVISION%" -o=jsonpath="{.items[*].metadata.labels}"') do (
    set LABEL=%%c
)
set LABEL=%LABEL:~1,-1%

REM Stampa le label
echo %LABEL%
if errorlevel 1 (
    echo Error running kubectl command
    exit /b 1
)

goto :eof