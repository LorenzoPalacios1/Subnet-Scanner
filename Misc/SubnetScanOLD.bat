::Default variables - IP to scan; starting index; save directory
@set address=10.254.8.
@set index=1
@set savedir=%UserProfile%

@echo Scanning IP addresses of %address%X. Enter a starting index (1-255; leave blank for 1).
@set /p index=

@echo Enter a save log path (leave blank for %UserProfile%\%address%X).
@set /p SaveDir=

::In case a number lesser than or equal to 1 is entered; Scan function adds 1 at the start of its routine
@if %index% LEQ 1 (
    set index=1
)

::Save directory validation and creation
@if not exist "%SaveDir%" (
    set SaveDir=%UserProfile%\%address%X
)
@mkdir %SaveDir%\%address%X

:Scan
@if %index% LEQ 255 (
    echo Iteration %index%
    set /a index="%index% + 1"
    ping %address%%index% /n 1 /w 2000 > "%SaveDir%\%address%X\%address%%index%.txt" && goto Scan & del "%SaveDir%\%address%X\%address%%index%.txt"
    goto Scan
)
@echo Finished. Log can be found in "%SaveDir%\%address%X"
@pause


::Below are some address bases that I've found. Feel free to add onto it.
:: 10.48.0.
:: 10.96.20.
:: 10.4.5.
:: 10.144.51.
:: 10.254.8. !
:: 10.11.50. !
:: 10.254.99. !
:: 10.254.97. !
:: 10.96.52. !

::Use this command to search through the generated list to filter out which addresses are legit or not; the scan functionality isn't quite perfect *yet*
::find /c /i "Request Timed Out" *