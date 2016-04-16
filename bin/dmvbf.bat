@echo off
setlocal enabledelayedexpansion
set machine=%1
if "%machine%" == "" (
	echo dmvbf expects a machine name
	exit /b 1
)
set ipx=%2
if "%ipx%" == "" (
	echo dmvbf x missing ^(for 192.168.x.y^)
	exit /b 2
)
set ipy=%3
if "%ipy%" == "" (
	echo dmvbf y missing ^(for 192.168.x.y^)
	exit /b 3
)

docker-machine.exe ssh %machine% "sudo sh -c 'echo \"if [ -e /var/run/udhcpc.eth1.pid ]; then kill \$(more /var/run/udhcpc.eth1.pid); fi\" | sudo tee /var/lib/boot2docker/bootsync.sh >/dev/null'"
docker-machine ssh %machine% "sudo sh -c 'echo \"ifconfig eth1 192.168.%ipx%.%ipy% netmask 255.255.255.0 broadcast 192.168.%ipx%.255 up\" | sudo tee -a /var/lib/boot2docker/bootsync.sh >/dev/null'"

docker-machine ssh %machine% "sudo chmod 755 /var/lib/boot2docker/bootsync.sh"

docker-machine ssh %machine% "sudo sh -c 'if [ -e /var/run/udhcpc.eth1.pid ]; then cat /var/run/udhcpc.eth1.pid | xargs sudo kill; fi'"

docker-machine ssh %machine% "sudo ifconfig eth1 192.168.%ipx%.%ipy% netmask 255.255.255.0 broadcast 192.168.%ipx%.255 up"
