rem This file contains tests for the SubnetScanner
rem The first argument to 'UpdatedSubnetScanner' is the address
rem The second argument is the offset
rem The third argument is the log directory
rem The forth argument is an attempt to enable multithreading, or disable it

set testSaveDIr=TestDir

echo - Generic call with multithreading -
call UpdatedSubnetScanner 127.0.0. 5 TestDir Y

echo - Generic call without multithreading -
call UpdatedSubnetScanner 127.0.0. 1 TestDir N

echo - Malformed Address Call (Fixable) -
call UpdatedSubnetScanner 127.0.0 5 TestDir Y

echo - Malformed Address Call (Unfixable) -
call UpdatedSubnetScanner 127.0.0. 5 TestDir Y

echo - Invalid offset (i < INDEX_MIN_VALUE) -
call UpdatedSubnetScanner 127.0.0. -1 TestDir Y

echo - Invalid offset (i > INDEX_MAX_VALUE) -
call UpdatedSubnetScanner 127.0.0. 300 TestDir Y

echo - Malformed Save Directory -
call UpdatedSubnetScanner 127.0.0. 5 ";" Y

echo - Cleanup Utility Testing -
for /l %%i in (1,1,100) do (
    echo unreachable > "%testSaveDir%\%%i.txt"
)