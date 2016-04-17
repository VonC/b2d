@echo off
setlocal enabledelayedexpansion

set machine=blessed
if not exist %USERPROFILE%\.docker\machine\machines\%machine% (
	call dmcv %machine% kv
)
docker-machine ls %machine%
for /f "delims=" %%A in ('docker-machine ip kv') do set "ipkv=%%A"
echo ipkv='%ipkv%'
FOR /F "tokens=* USEBACKQ" %%F IN (`dm ssh %machine% "if [ ^! -e /var/lib/boot2docker/bootsync.sh ]; then echo nobootsync; fi"`) DO (SET checkbootsync=%%F)
if "%checkbootsync%"=="nobootsync" (
	echo fix IP for %machine% at 99.101
	call dmvbf %machine% 99 101
	docker-machine ssh %machine% "sudo sh -c 'echo \"echo %ipkv% kv^>^>/etc/hosts\" | sudo tee -a /var/lib/boot2docker/bootsync.sh >/dev/null'"
	dm regenerate-certs -f %machine%
	dm restart %machine%
)
