@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

for /f "delims=" %%A in ('boot2docker status') do set "status=%%A"
echo.%status%
if "%status%" NEQ "running" (
	boot2docker start
)

REM already running means controlvm (as opposed to modifyvm)


for /f "tokens=2 delims==" %%a in ('findstr PORT envs\*') do (
	set p=%%a
	set p=!p: =!
	VBoxManage controlvm "boot2docker-vm" natpf1 "tcp-port!p!,tcp,,!p!,,!p!"; 2> NUL
	VBoxManage controlvm "boot2docker-vm" natpf1 "udp-port!p!,udp,,!p!,,!p!"; 2> NUL
)

boot2docker ssh sudo cp -f %unixpath%/profile /var/lib/boot2docker/profile
boot2docker ssh sudo /etc/init.d/docker restart
boot2docker ssh cp -f %unixpath%/profile .ashrc
boot2docker ssh cp -f %unixpath%/.bash_aliases .bash_aliases
boot2docker ssh
