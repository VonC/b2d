@echo off
setlocal enabledelayedexpansion

set b2d=%~dp0%
set parent=%b2d: =,%
set parent=%parent:\= %
set parentdir=
set unixpath=
call :getparentdir %parent%
set parent=%parentdir:,= %
set unixpath=%unixpath%/b2d

echo b2d='%b2d%'
echo parentdir='%parentdir%'
echo parent='%parent%'
echo.unixpath='%unixpath%'

if not exist ..\env.bat (
	echo Add %parent%\env.bat: (..\env.bat^)
	echo See env.bat.template in %b2d%
	echo In ..\env.bat, complete your %%PATH%% with Git, VirtualBox and Boot2Docker
	exit /B 1
)
set PATH=C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem
call !parent!\env.bat
set PATH=%PATH%;%b2d%bin

rem http://stackoverflow.com/a/7218493/6309: test substring
for /f "delims=" %%A in ('where docker-machine.exe') do set "DOCKER_MACHINE=%%A"
if "%DOCKER_MACHINE%"=="" (
	echo "docker-machine.exe is not found in PATH: check your ..\env.bat"
	exit /B 1
)
for %%i in ("%DOCKER_MACHINE%\..") do set "DOCKER_TOOLBOX_INSTALL_PATH=%%~fi"
for /f "delims=" %%A in ('where git.exe') do set "GIT_HOME=%%A"
if "%GIT_HOME%"=="" (
	echo "git.exe is not found in PATH: check your ..\env.bat"
	exit /B 1
)
1>nul (git --version| findstr /i /C:"version 2.")
if %errorlevel% == 1 (
	echo "Please use a git 2.x (for instance 2.8+) version: check your ..\env.bat"
	exit /B 1
)
for /f "delims=" %%A in ('where vboxmanage.exe') do set "VBOXMANAGE=%%A"
if "%VBOXMANAGE%"=="" (
	echo "VirtualBox (vboxmanage.exe) is not found in PATH: check your ..\env.bat"
	exit /B 1
)
for %%i in ("%VBOXMANAGE%\..") do set "VBOX_MSI_INSTALL_PATH=%%~fi"

git --version
docker-machine version
vboxmanage --version

set scripts=%b2d%bin
set scriptd=%scripts:\=\\%
git -C %b2d% config filter.dffilter.smudge %scriptd%\\dfsmudge.sh
git -C %b2d% config filter.dffilter.clean %scriptd%\\dfclean.sh

cp -f %scripts%\dfsmudge.sh.template %scripts%\dfsmudge.sh

echo.%HTTP_PROXY%| findstr /C:"http" 1>nul
if %errorlevel% == 0 (
	sed -i -e "s/#hasproxy#/1/g" %scripts%\dfsmudge.sh
	sed -i -e "s;#http_proxy#;%HTTP_PROXY%;g" %scripts%\dfsmudge.sh
	sed -i -e "s;#https_proxy#;%HTTPS_PROXY%;g" %scripts%\dfsmudge.sh
	sed -i -e "s;#no_proxy#;%NO_PROXY%;g" %scripts%\dfsmudge.sh
)
sed -i -e "s;_unixpath_;%unixpath%;g" %scripts%\dfsmudge.sh

touch profile
git checkout HEAD -- profile

cd %b2d%compose
for /F "usebackq" %%i in (`dir Dockerfile* /b/s`) do touch %%i
for /F "usebackq" %%i in (`dir Dockerfile* /b/s`) do git checkout HEAD -- %%i
cd %b2d%

echo set PATH=%PATH%>p.bat
echo set HOME=%parentdir%>>p.bat
echo set DOCKER_MACHINE=%DOCKER_MACHINE%>>p.bat
echo set DOCKER_TOOLBOX_INSTALL_PATH=%DOCKER_TOOLBOX_INSTALL_PATH%>>p.bat
echo set VBOXMANAGE=%VBOXMANAGE%>>p.bat
echo set VBOX_MSI_INSTALL_PATH=%VBOX_MSI_INSTALL_PATH%>>p.bat
endlocal
call p.bat
del p.bat

doskey dm=docker-machine $*
rem doskey dmcv=docker-machine create -d virtualbox --engine-env HTTP_PROXY=%http_proxy% --engine-env HTTPS_PROXY=%https_proxy% --engine-env http_proxy=%http_proxy% --engine-env https_proxy=%https_proxy% --engine-env NO_PROXY=%no_proxy% --engine-env no_proxy=%no_proxy% $*
doskey dmcv=docker-machine create -d virtualbox $*

doskey vbm="VBoxManage.exe" $*
doskey vbmmt="VBoxManage.exe modifyvm \"boot2docker-vm\" natpf1 \"tcp-port$1,tcp,,$1,,$1\";"
doskey vbmmu="VBoxManage.exe modifyvm \"boot2docker-vm\" natpf1 \"udp-port$1,udp,,$1,,$1\";"
doskey vbmct="VBoxManage.exe controlvm \"boot2docker-vm\" natpf1 \"tcp-port$1,tcp,,$1,,$1\";"
doskey vbmcu="VBoxManage.exe controlvm \"boot2docker-vm\" natpf1 \"udp-port$1,udp,,$1,,$1\";"
doskey bd="boot2docker.exe" $*
doskey cdbb=cd "%~dp0"

doskey h=doskey /history
doskey gl=git lg -20
doskey glba=git lg -20 --branches --all
doskey glab=git lg -20 --all --branches
doskey gla=git lg -20 --all

set LANG=en_US.UTF-8
goto:eof
goto:eof


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
