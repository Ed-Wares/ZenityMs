@echo off
echo Script to start zenity in debugger

SET "current_dir=%~dp0"
cd "%current_dir%"

SET "zenity=bin\zenity.exe"

REM If there is an issue with GTK, then enabling the two variables below can help output more info
REM set G_MESSAGES_DEBUG=all
REM set GTK_DEBUG=interactive

echo To see if directx 2d hardware rendering is still being used run the command: tasklist /m d2d1.dll 

echo To debug a crash and print the exact line of code causing the issue type: bt full
echo running in gdb debugger: %zenity% --entry --title="user input test" --text="debug input:"
%current_dir%\gdb\gdb.exe -ex=r --args %zenity% --entry --title="user input test" --text="debug input:"

echo done.
pause
