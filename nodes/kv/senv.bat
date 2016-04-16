@echo off
setlocal enabledelayedexpansion

if not exist %USERPROFILE%\.docker\machine\machines\kv (
	dmcv kv
)
docker-machine ls kv
FOR /F "tokens=* USEBACKQ" %%F IN (`dm ssh kv "if [ ^! -e /var/lib/boot2docker/bootsync.sh ]; then echo nobootsync; fi"`) DO (SET checkbootsync=%%F)
if "%checkbootsync%"=="nobootsync" (
	echo fix IP for kv at 99.100
	dmvbf kv 99 100
	dm regenerate-certs -f kv
	dm restart kv
)
