@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set vm=%1
if "%vm%" == "" ( set vm="default" )
set dm=docker-machine.exe
for /f "delims=" %%A in ('%dm% status %vm%') do set "status=%%A"
echo.%status%
if "%status%" NEQ "running" (
	%dm% start %vm%
)

REM already running means controlvm (as opposed to modifyvm)

set up=
set h=%HOME%
call :unixpath %HOME%
set HOME=%up%
echo HOME='%HOME%'
set p=%PROG%
call :unixpath %PROG%
set PROG=%up%
echo PROG='%PROG%'

mkdir %h%\tmp 2>NUL
cp %h%\.gitconfig %h%\tmp
cp %p%\bin\db %h%\tmp
%dm% ssh %vm% cp -f %HOME%/tmp/.gitconfig .
%dm% ssh %vm% cp -f %HOME%/docker/profile .ashrc
%dm% ssh %vm% cp -f %HOME%/docker/.bash_aliases .
%dm% ssh %vm% mkdir -p /home/docker/.local/bin
%dm% ssh %vm% cp -f %HOME%/tmp/db /home/docker/.local/bin
%dm% ssh %vm%

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
