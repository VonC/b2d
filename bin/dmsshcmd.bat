@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set vm=%1
set acmd="%2"
if "%acmd%" == "" ( 
	set vm="default" 
	set acmd=%1
)
if "%acmd%" == "-f" ( 
	set vm="default" 
	set acmd=%1
	set force=true
)
if "%3"=="-f" (
	set force=true
)
set dm=docker-machine.exe
if "%force%"=="true" (
	for /f "delims=" %%A in ('%dm% status %vm%') do set "status=%%A"
	echo.%status%
	if "%status%" NEQ "running" (
		%dm% start %vm%
	)
)

REM already running means controlvm (as opposed to modifyvm)

set up=
set b2d=%HOME%\b2d
call :unixpath %b2d%
set b2du=%up%

if "%force%"=="true" (
	%dm% ssh %vm% cp -f %b2du%/git/.gitconfig /home/docker
	%dm% ssh %vm% cp -f %b2du%/scripts/profile /home/docker/.ashrc
	%dm% ssh %vm% cp -f %b2du%/scripts/.bash_aliases /home/docker/.bash_aliases
	%dm% ssh %vm% mkdir -p /home/docker/.local/bin
	%dm% ssh %vm% "echo cd %b2du%/nodes/$(hostname)>/home/docker/next"
)
%dm% ssh %vm% %acmd%

goto:EOF

rem > expr "c:\wind\back\up" | sed -e "s,\\\,/,g" | sed -e "s,\(.\):,/\1/,g"
rem /c/wind/back/up

:unixpath
set P=%~1
for /f "delims=" %%A in ('expr "%p%"^|sed -e "s,\\\,/,g"') do set "p=%%A"
for /f "delims=" %%A in ('expr "%p%"^|sed -e "s,\(.\):,/\1,g"') do set "p=%%A"
for /f "delims=" %%A in ('expr "%p%"^|sed -e "s,^/C,/c,g"') do set "p=%%A"
( endlocal & REM.-- RETURN VALUES
	set "up=%p%"
)
