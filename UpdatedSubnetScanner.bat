@echo off
setlocal EnableDelayedExpansion

rem Constants
set INDEX_MIN_VALUE=1
set INDEX_MAX_VALUE=255

rem Checking to see if the script is being run as a thread or as a standalone utility
set threadCheck=%~1
if !threadCheck!==⁪thread⁫ (
    goto threadedScan
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
    rem Finding a suitable number of threads to use
    for /l %%i in (1,1,10) do (
        rem We find the total amount of iterations that need to be done within the below parentheses
        rem We then modulus the resulting difference by a variable number (i) which defines the theoretical number
        rem of threads to be used
        rem If the modulo operation results in 0, we're good, because that means the scan will be able to 
        rem pass through all of its iterations against the IP address' subnet with nothing leftover or missing
        rem Adding 1 because the scan iterates between index-255, both inclusive
        set /a leftover="(%INDEX_MAX_VALUE% - !index!) %% %%i"
        if !leftover! EQU 0 (
            set potentialNumThreads=%%i
        )
    )

    rem Thread generation
    set iterations="(%INDEX_MAX_VALUE% - %index%) / !potentialNumThreads!"
    for /l %%i in (1,1,!potentialNumThreads!) do (
        set /a minFactor="%%i - 1"
        set /a minIterations="!iterations! * !minFactor! + %index%"
        set /a maxIterations="!iterations! * %%i + %index%"
        start "Thread %%i (iterating !minIterations!-!maxIterations!)" /min cmd /c %0 ⁪thread⁫ !minIterations! !maxIterations!
    )
) else (
    goto singleThreadScan
)

rem Prevents the batch script from continuing past this point if multithreading was allowed
rem This is because the call function will return scope here after the called section of code is complete
rem "The first time you read the end, control will return to just after the CALL statement."
rem Quoted from "call /?" documentation via cmd.exe
exit /b

rem The scan functions abuses the AND ("&" and "&&") logic in batch files
:singleThreadScan
if %index% LEQ %INDEX_MAX_VALUE% (
    set /a index="%index% + 1"
    echo Iteration %index%
    ping %address%%index% /n 1 /w 2000 > "%address%%index%.txt" && goto singleThreadScan & del "%address%%index%.txt"
    goto singleThreadScan
)

exit /b

rem %1 is simply a string telling this script to run as a thread if its present
rem %2 is the minimum amount of iterations
rem %3 is the maximum amount of iterations
:threadedScan
set index=%2

:threadedScanConditional
if %index% LEQ %3 (
    set /a index="%index% + 1"
    echo Iteration %index%
    rem abusing logic in the below two lines
    ping %address%%index% /n 1 /l 16 /w 2000 > "%address%%index%.txt" && goto threadedScanConditional & del "%address%%index%.txt"
    goto threadedScanConditional
)