@echo off
setlocal enabledelayedexpansion
set PATH=%~dp0%;!PATH!

rem echo %PATH%
rem which git
rem git --version
cd %~dp0%
set nonetrc=1
git test

endlocal
