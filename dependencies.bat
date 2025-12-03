@echo off
REM Script to run dependency.sh script to locate all dependencies of an executable

SET "current_dir=%~dp0"
SET "pwd_dir=%current_dir:\=/%"

REM Find MSYS_ROOT by locating g++.exe in system PATH
FOR /F "tokens=*" %%i IN ('where g++.exe') DO pushd "%%~dpi..\.." && (call set "MSYS_ROOT=%%CD%%") && popd
REM SET MSYS_ROOT=C:\msys64\
echo MSYS_ROOT: %MSYS_ROOT%

SET "bash_cmd=%MSYS_ROOT%\usr\bin\bash.exe -l -c"
SET "ucrt64_cmd=%MSYS_ROOT%\msys2_shell.cmd -defterm -no-start -here -ucrt64 -c"

REM echo Running: %bash_cmd% "%pwd_dir%dependencies.sh %*"
REM %bash_cmd% "%pwd_dir%dependencies.sh %*"

echo Running: %ucrt64_cmd% "%pwd_dir%dependencies.sh %*"
%ucrt64_cmd% "%pwd_dir%dependencies.sh %*"
