@echo off
setlocal EnableDelayedExpansion

rem Constants
set INDEX_MIN_VALUE=1
set INDEX_MAX_VALUE=255
set PING_LIFETIME=1500

rem Checking to see if the script is being run as a thread or as a standalone utility
set threadCheck=%~1
if !threadCheck!==⁪thread⁫ (
    goto singletonScan
)

rem Default variables; IP subnet to scan, starting index, and save directory respectively
set address=%1
set index=%2
set saveDir=%~f3

:getAddress
if NOT DEFINED address set /p address=Enter the portion of an IP address (Ex. 142.251.33.): 

rem This ping statement tests the passed IP address
ping /n 1 /l 16 %address%1 > nul
if ERRORLEVEL 1 (
    rem This echo statement generates a new line
    echo:
    echo Issue encountered while validating passed IP address
    echo Trying a common fix...
    rem Appending a period to the end; this is something I tripped up on several times, so
    rem I figured I might as well give it a fix
    set address=%address%.
    
    ping /n 1 /l 16 !address!1 > nul
    if !ERRORLEVEL! EQU 0 (
        echo Issue resolved
        goto getIndex
    )
    echo:
    echo Issue is still present
    echo This is usually due to improper formatting or connectivity issues
    echo This can also be because the passed IP address is not in operation or use
    echo Exiting...
    echo:
    pause
    exit /b
)


:getIndex
if NOT DEFINED index set /p index=Enter an offset to start the scan from (leave blank to start at the default, 1): 
if NOT DEFINED index set index=1

rem Validating the passed index offset
if %index% LSS %INDEX_MIN_VALUE% (
    set index=%INDEX_MIN_VALUE%
) else if %index% GTR %INDEX_MAX_VALUE% (
    set index=%INDEX_MIN_VALUE%
)

:getSaveDir
if NOT DEFINED saveDir set /p saveDir=Enter a log path (leave blank for %UserProfile%\%address%X): 

rem Validating the passed save log path
if NOT DEFINED saveDir set saveDir=%UserProfile%\%address%X
mkdir %saveDir%
if NOT EXIST %saveDir% (
    echo Using default log path...
    set saveDir=%UserProfile%\%address%X
    mkdir %saveDir%
)
cd %saveDir%

:parallelism
choice /m "Use multithreading"
if !ERRORLEVEL! EQU 1 (
    for /l %%i in (%index%,1,%INDEX_MAX_VALUE%) do (
        start "%%i" /min cmd /c call %0 ⁪thread⁫ %%i
    )
)

:cleaning
echo Filtering log...
cd !logDir!
for %%f in (*) do (
    find /c "unreachable" %%f > nul && del %%f
)
echo Finished

exit /b

rem The scan functions abuses the AND ("&" and "&&") logic in batch files
:singletonScan
    ping %address%%2 /n 1 /l 8 /w %PING_LIFETIME% > "%address%%2.txt" && exit & del "%address%%2.txt"