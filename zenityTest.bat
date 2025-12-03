@echo off
echo Script to run a few tests commands with zenity

SET "current_dir=%~dp0"
cd "%current_dir%"

SET "zenity=bin\zenity"

echo running: %zenity% --version
%zenity% --version

echo running: %zenity% --info --text="Test info message"
%zenity% --info --text="Test info message"

echo running: %zenity% --entry --title="user input test" --text="please enter you name:"
%zenity% --entry --title="user input test" --text="please enter you name:"

echo running: %zenity% --list --title="fruit selection test" --text="choose your favorite fruit:" --column="Fruits" "Apple" "Banana" "Orange"
%zenity% --list --title="fruit selection test" --text="choose your favorite fruit:" --column="Fruits" "Apple" "Banana" "Orange"

echo done.
pause
