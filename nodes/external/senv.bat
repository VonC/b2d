@echo off
setlocal enabledelayedexpansion

set machine=external
if not exist %USERPROFILE%\.docker\machine\machines\%machine% (
	call dmcv %machine% kv
	docker-machine ls %machine%
)
FOR /F "tokens=* USEBACKQ" %%F IN (`dm ssh %machine% "if [ ^! -e /var/lib/boot2docker/bootsync.sh ]; then echo nobootsync; fi"`) DO (SET checkbootsync=%%F)
if "%checkbootsync%"=="nobootsync" (
	for /f "delims=" %%A in ('docker-machine ip kv') do set "ipkv=%%A"
	echo ipkv='!ipkv!'
	echo fix IP for %machine% at 99.103
	call dmvbf %machine% 99 103
	docker-machine ssh %machine% "sudo sh -c 'echo \"echo !ipkv! kv^>^>/etc/hosts\" | sudo tee -a /var/lib/boot2docker/bootsync.sh >/dev/null'"
	dm regenerate-certs -f %machine%
	dm restart %machine%
)
