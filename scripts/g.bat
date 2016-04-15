@echo off
echo %~dp0
echo "doskey g=%~dp0g.bat $*"
git -c http.sslCAInfo=%~dp0apache\crts %*
