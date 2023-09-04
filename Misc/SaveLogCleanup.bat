@echo off
setlocal EnableDelayedExpansion

rem This is used to clean up any output files that slipped through the cracks
rem It searches for the string "unreachable" within every file and deletes that file
rem if the string is found

set logDir=%1

if DEFINED logDir (
    goto checkDir
)

:userPrompt
set /p logDir=Specify a directory to clean: 

if NOT DEFINED logDir (
    goto userPrompt
)

:checkDir
if NOT EXIST !logDir! (
    echo:
    echo Invalid directory
    echo:
    exit /b
)

:clean
echo Working...
cd !logDir!
for %%f in (*) do (
    find /c "unreachable" %%f > nul && del %%f
)
echo Finished
pause