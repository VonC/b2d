@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

for /f "delims=" %%A in ('docker-machine status default') do set "status=%%A"
echo.%status%
if "%status%" NEQ "running" (
	docker-machine start default
)

REM already running means controlvm (as opposed to modifyvm)


for /f "tokens=2 delims==" %%a in ('findstr PORT envs\*') do (
	set p=%%a
	set p=!p: =!
	VBoxManage controlvm "default" natpf1 "tcp-port!p!,tcp,,!p!,,!p!"; 2> NUL
	VBoxManage controlvm "default" natpf1 "udp-port!p!,udp,,!p!,,!p!"; 2> NUL
)

docker-machine ssh default cp -f %unixpath%/profile .ashrc
docker-machine ssh default cp -f %unixpath%/.bash_aliases .bash_aliases
docker-machine ssh default
