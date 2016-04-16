@echo off
setlocal enabledelayedexpansion

set machine=%1
if "%machine%" == "" (
	echo vbmfwd expects a machine name to forward from
	exit /b 1
)
set port=%2
if "%port%" == "" (
	echo vbmfwd expects a port to forward to
	exit /b 2
)

for /f "delims=" %%A in ('vboxmanage.exe showvminfo %machine% --machinereadable ^| grep -i VMState^=') do set "status=%%A"
rem " http://stackoverflow.com/questions/14658498/batch-get-string-between-first-and-last-double-quotes
set "status=%status:*"=%
echo status='%status%'

rem http://stackoverflow.com/questions/6711615/using-multiple-if-statements-in-a-batch-file
if not "%status%"=="running" if not "%status%"=="poweroff" (
	echo vm %machine% is not running or poweroff: %status%
	exit /B 1
)

set cmdvm=controlvm
if "%status%"=="poweroff" (
	set cmdvm=modifyvm
)
echo cmdvm='%cmdvm%'

call :forward tcp
call :forward udp
goto:eof

:forward
set protocol=%1
rem echo protocol='%protocol%'
rem echo vboxmanage.exe showvminfo %machine% --machinereadable ^| grep Forwarding ^| grep %protocol%-port%port%
for /f delims^=^"^ tokens^=2 %%A in ('vboxmanage.exe showvminfo %machine% --machinereadable ^| grep Forwarding ^| grep %protocol%-port%port%') do set "rule=%%A"
rem " http://stackoverflow.com/questions/7516064/escaping-double-quote-in-delims-option-of-for-f
rem echo rule='%rule%'
if "%rule%"=="" (
	set vbcmd=vboxmanage %cmdvm% %machine% natpf1 %protocol%-port%port%,%protocol%,,%port%,,%port%
	echo vbcmd='!vbcmd!'
	call !vbcmd!
) else (
	echo port %port% already forwarded from %machine%: %rule%
)
set rule=
goto:eof
