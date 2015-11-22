@echo off

set script=%~dp0%
set parent=%script: =,%
set parent=%parent:\= %
set parentdir=
set unixpath=
call :getparentdir %parent%
set parent=%parentdir:,= %
set unixpath=%unixpath%/b2d

rem echo script='%script%'
rem echo parentdir='%parentdir%'
rem echo parent='%parent%'
rem echo.unixpath='%unixpath%'

if not exist ..\env.bat (
	echo Add %parent%\env.bat: (..\env.bat^)
	echo See env.bat.template in %script%
	echo In ..\env.bat, complete your %%PATH%% with Git, VirtualBox and Boot2Docker
	exit /B 1
)
call "%parent%\env.bat"
set PATH=%PATH%;%script%

rem http://stackoverflow.com/a/7218493/6309: test substring
echo.%PATH%| findstr /C:"dm\latest" 1>nul
if %errorlevel% == 1 (
	echo "docker-machine is not found in PATH: check your ..\env.bat"
	exit /B 1
)
echo.%PATH%| findstr /i /C:"Git" 1>nul
if %errorlevel% == 1 (
	echo "Git is not found in PATH: check your ..\env.bat"
	exit /B 1
)
echo.%PATH%| findstr /C:"vbox\latest" 1>nul
if %errorlevel% == 1 (
	echo "VirtualBox is not found in PATH: check your ..\env.bat"
	exit /B 1
)

doskey dm=docker-machine $*
rem doskey dmcv=docker-machine create -d virtualbox --engine-env HTTP_PROXY=%http_proxy% --engine-env HTTPS_PROXY=%https_proxy% --engine-env http_proxy=%http_proxy% --engine-env https_proxy=%https_proxy% --engine-env NO_PROXY=%no_proxy% --engine-env no_proxy=%no_proxy% $*
doskey dmcv=docker-machine create -d virtualbox $*

set DOCKER_TOOLBOX_INSTALL_PATH=C:/prgs/latest
set DOCKER_MACHINE=%DOCKER_TOOLBOX_INSTALL_PATH%/docker-machine.exe
set VBOXMANAGE=C:/prgs/vbox/latest/vboxmanage.exe

doskey vbm="VBoxManage.exe" $*
doskey vbmmt="VBoxManage.exe modifyvm \"boot2docker-vm\" natpf1 \"tcp-port$1,tcp,,$1,,$1\";"
doskey vbmmu="VBoxManage.exe modifyvm \"boot2docker-vm\" natpf1 \"udp-port$1,udp,,$1,,$1\";"
doskey vbmct="VBoxManage.exe controlvm \"boot2docker-vm\" natpf1 \"tcp-port$1,tcp,,$1,,$1\";"
doskey vbmcu="VBoxManage.exe controlvm \"boot2docker-vm\" natpf1 \"udp-port$1,udp,,$1,,$1\";"
doskey bd="boot2docker.exe" $*
doskey cdb=cd "%~dp0"

set scriptd=%script:\=\\%
git -C %script% config filter.dffilter.smudge %scriptd%dfsmudge.sh
git -C %script% config filter.dffilter.clean %scriptd%dfclean.sh

cp -f %script%dfsmudge.sh.template %script%dfsmudge.sh

echo.%HTTP_PROXY%| findstr /C:"http" 1>nul
if %errorlevel% == 0 (
	sed -i -e "s/#hasproxy#/1/g" dfsmudge.sh
	sed -i -e "s;#http_proxy#;%HTTP_PROXY%;g" dfsmudge.sh
	sed -i -e "s;#https_proxy#;%HTTPS_PROXY%;g" dfsmudge.sh
	sed -i -e "s;#no_proxy#;%NO_PROXY%;g" dfsmudge.sh
)
sed -i -e "s;_unixpath_;%unixpath%;g" dfsmudge.sh

doskey alias=doskey /macros:all
doskey h=doskey /history
doskey gl=git lg -20
doskey glba=git lg -20 --branches --all
doskey glab=git lg -20 --all --branches
doskey gla=git lg -20 --all

set LANG=en_US.UTF-8

goto :eof


rem http://www.dostips.com/DtTutoFunctions.php#FunctionTutorial.ReturningValuesClassic
:getparentdir
setlocal enabledelayedexpansion
set P=%~1
rem echo 1='%P%'
rem echo getparentdir parentdir='%parentdir%'
rem echo getparentdir unixpath='%unixpath%'
if "!P!" EQU "" goto :eof
if "!P!" EQU "b2d" (
	endlocal
	set "parentdir=%parentdir%"
	set "unixpath=%unixpath%"
	goto :EOF
)
if not "%parentdir%" == "" (
	set "parentdir=!parentdir!\!P!"
	set "unixpath=!unixpath!/!P!"
	rem echo notempty: parentdir='%parentdir%'
	rem echo notempty: unixpath='%unixpath%'
)
rem echo between: parentdir='%parentdir%'
rem echo between: unixpath='%unixpath%'
if "%parentdir%" == "" (
	set "parentdir=!P!"
	set "unixpath=/!P!"
	set "unixpath=!unixpath::=!"
	call :lowercase unixpath
	rem echo empty: parentdir='!parentdir!'
	rem echo empty: unixpath='!unixpath!'
)
shift
( endlocal & REM.-- RETURN VALUES
	set "parentdir=%parentdir%"
	set "unixpath=%unixpath%"
)
rem echo shiftt: parentdir='%parentdir%'
rem echo shiftt: unixpath='%unixpath%'
goto getparentdir

:lowercase
set %~1=!%1:C=c!
set %~1=!%1:D=d!
set %~1=!%1:E=e!
set %~1=!%1:F=f!
set %~1=!%1:G=g!
set %~1=!%1:H=h!
set %~1=!%1:I=i!
set %~1=!%1:J=j!
set %~1=!%1:K=k!
set %~1=!%1:L=l!
set %~1=!%1:M=m!
set %~1=!%1:N=n!
set %~1=!%1:O=o!
set %~1=!%1:P=p!
set %~1=!%1:Q=q!
set %~1=!%1:R=r!
set %~1=!%1:S=s!
set %~1=!%1:T=t!
set %~1=!%1:U=u!
set %~1=!%1:V=v!
set %~1=!%1:W=w!
set %~1=!%1:X=w!
set %~1=!%1:Y=y!
set %~1=!%1:Z=z!
goto :eof
