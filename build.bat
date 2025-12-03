@echo off
REM Script to rebuild the EXE binary

SET "current_dir=%~dp0"
SET "pwd_dir=%current_dir:\=/%"

REM find the MSYS_ROOT by searching for the location of g++.exe from PATH environment variable
FOR /F "tokens=*" %%i IN ('where g++.exe') DO pushd "%%~dpi..\.." && (call set "MSYS_ROOT=%%CD%%") && popd
echo MSYS_ROOT: %MSYS_ROOT%
SET "bash_cmd=%MSYS_ROOT%\usr\bin\bash.exe"
SET "ucrt64_cmd=%MSYS_ROOT%\msys2_shell.cmd -defterm -no-start -here -ucrt64 -c"

REM %bash_cmd% -l -c "%pwd_dir%build.sh"
REM C:\msys64\msys2_shell.cmd -defterm -no-start -here -ucrt64 -c "/D/dev/ed-wares/ZenityMs/build.sh"

REM use the msys2 ucrt64 environment for running the command or script
echo Running: %ucrt64_cmd% "%pwd_dir%build.sh"
%ucrt64_cmd% "%pwd_dir%build.sh"
