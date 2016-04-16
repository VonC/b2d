@echo off
setlocal enabledelayedexpansion
set machine=%1
if "%machine%" == "" (
	echo dmcv expects a machine name to create ^(and an optional key-value machine^)
	exit /b 1
)
set kv=%2

set envs=
set sp=
if not "%HTTP_PROXY%"=="" (
	set envs=%envs%%sp%--engine-env HTTP_PROXY=%HTTP_PROXY% --engine-env http_proxy=%HTTP_PROXY%
)
if not "%HTTPS_PROXY%"=="" (
	set envs=%envs% --engine-env HTTPS_PROXY=%HTTPS_PROXY% --engine-env https_proxy=%HTTPS_PROXY%
)
if not "%NO_PROXY%"=="" (
	set envs=%envs% --engine-env NO_PROXY=%NO_PROXY% --engine-env no_proxy=%NO_PROXY%
)

set opts=
if not "%kv%"=="" (
	rem http://stackoverflow.com/questions/16203629/batch-assign-command-output-to-variable
	set kvip=
	for /f "delims=" %%i in ('docker-machine ip %kv%') do set kvip=%%i
	set opts=%opts% --engine-opt=^"cluster-store=consul://!kvip!:8500^"
	set opts=!opts! --engine-opt=^"cluster-advertise=eth1:2376^"
)
docker-machine create -d virtualbox %envs% %opts% %machine%
