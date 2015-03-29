@echo off

set script=%~dp0%
set parent=%script: =,%
set parent=%parent:\= %
set parentdir=
call :getparentdir %parent%
set parent=%parentdir:,= %

if not exist ..\env.bat (
	echo Add %parent%\env.bat: (..\env.bat^)
	echo See env.bat.template in %script%
	echo In ..\env.bat, complete your %%PATH%% with Git, VirtualBox and Boot2Docker
	exit /B 1
)
call "%parent%\env.bat"
set PATH=%PATH%;%script%

rem http://stackoverflow.com/a/7218493/6309: test substring
echo.%PATH%| findstr /C:"Boot2Docker" 1>nul
if errorlevel 1 (
	echo "Boot2Docker is not found in PATH: check your ..\env.bat"
	exit /B 1
)
echo.%PATH%| findstr /C:"Git" 1>nul
if errorlevel 1 (
	echo "Git is not found in PATH: check your ..\env.bat"
	exit /B 1
)
echo.%PATH%| findstr /C:"VirtualBox" 1>nul
if errorlevel 1 (
	echo "VirtualBox is not found in PATH: check your ..\env.bat"
	exit /B 1
)

doskey vbm="VBoxManage.exe" $*
doskey vbmmt="VBoxManage.exe modifyvm \"boot2docker-vm\" natpf1 \"tcp-port$1,tcp,,$1,,$1\";"
doskey vbmmu="VBoxManage.exe modifyvm \"boot2docker-vm\" natpf1 \"udp-port$1,udp,,$1,,$1\";"
doskey vbmct="VBoxManage.exe controlvm \"boot2docker-vm\" natpf1 \"tcp-port$1,tcp,,$1,,$1\";"
doskey vbmcu="VBoxManage.exe controlvm \"boot2docker-vm\" natpf1 \"udp-port$1,udp,,$1,,$1\";"
doskey bd="boot2docker.exe" $*

goto :eof

rem http://www.dostips.com/DtTutoFunctions.php#FunctionTutorial.ReturningValuesClassic
:getparentdir
if "%~1" EQU "b2d" goto :EOF
if not "%parentdir%" == "" (
	set "parentdir=%parentdir%\%~1"
)
if "%parentdir%" == "" (
	set parentdir=%~1
)
shift
goto getparentdir
