@echo off
setlocal EnableDelayedExpansion
@REM shortcut zenity script

SET "current_dir=%~dp0"
SET "zenity=%current_dir%bin\zenity"


IF "%~1" == "" (
    echo No arguments passed. Executing default command...

    set "zen_usage= \n"
    set "zen_usage=!zen_usage!Usage:\n"
    set "zen_usage=!zen_usage!  zenity.exe [OPTION...]\n\n"
    set "zen_usage=!zen_usage!Help Options:\n"
    set "zen_usage=!zen_usage!  -h, --help                    Show help options\n"
    set "zen_usage=!zen_usage!  --help-all                    Show all help options\n"
    set "zen_usage=!zen_usage!  --help-general                Show general options\n"
    set "zen_usage=!zen_usage!  --help-calendar               Show calendar options\n"
    set "zen_usage=!zen_usage!  --help-entry                  Show text entry options\n"
    set "zen_usage=!zen_usage!  --help-error                  Show error options\n"
    set "zen_usage=!zen_usage!  --help-info                   Show info options\n"
    set "zen_usage=!zen_usage!  --help-file-selection         Show file selection options\n"
    set "zen_usage=!zen_usage!  --help-list                   Show list options\n"
    set "zen_usage=!zen_usage!  --help-progress               Show progress options\n"
    set "zen_usage=!zen_usage!  --help-question               Show question options\n"
    set "zen_usage=!zen_usage!  --help-warning                Show warning options\n"
    set "zen_usage=!zen_usage!  --help-scale                  Show scale options\n"
    set "zen_usage=!zen_usage!  --help-text-info              Show text information options\n"
    set "zen_usage=!zen_usage!  --help-color-selection        Show color selection options\n"
    set "zen_usage=!zen_usage!  --help-password               Show password dialog options\n"
    set "zen_usage=!zen_usage!  --help-forms                  Show forms dialog options\n"
    set "zen_usage=!zen_usage!  --help-misc                   Show miscellaneous options\n"
    set "zen_usage=!zen_usage!  --help-gtk                    Show GTK+ Options\n"
    set "zen_usage=!zen_usage! ..."
    
    rem Execute the 'zenity --version' command and store its output in the 'ver' variable
    FOR /F "tokens=* usebackq" %%i IN (`"%zenity%" --version`) DO (
        SET "ver=%%i"
        echo "ver: !ver!"
        echo "running: %zenity% --info --text=Zenity version !ver! ..."
        %zenity% --info --no-wrap --text="Zenity version !ver! \n !zen_usage!"
    )
 ) ELSE (
    echo "running: %zenity% %*"
    %zenity% %*
)
