@echo off
boot2docker start

REM already running means controlvm (as opposed to modifyvm)

VBoxManage controlvm "boot2docker-vm" natpf1 "tcp-port80,tcp,,80,,80"; 2> NUL
VBoxManage controlvm "boot2docker-vm" natpf1 "udp-port80,udp,,80,,80"; 2> NUL

VBoxManage controlvm "boot2docker-vm" natpf1 "tcp-port443,tcp,,443,,443"; 2> NUL
VBoxManage controlvm "boot2docker-vm" natpf1 "udp-port443,udp,,443,,443"; 2> NUL

VBoxManage controlvm "boot2docker-vm" natpf1 "tcp-port8443,tcp,,8443,,8443"; 2> NUL
VBoxManage controlvm "boot2docker-vm" natpf1 "udp-port8443,udp,,8443,,8443"; 2> NUL

VBoxManage controlvm "boot2docker-vm" natpf1 "tcp-port8543,tcp,,8543,,8543"; 2> NUL
VBoxManage controlvm "boot2docker-vm" natpf1 "udp-port8543,udp,,8543,,8543"; 2> NUL
VBoxManage controlvm "boot2docker-vm" natpf1 "tcp-port8553,tcp,,8553,,8553"; 2> NUL
VBoxManage controlvm "boot2docker-vm" natpf1 "udp-port8553,udp,,8553,,8553"; 2> NUL

boot2docker ssh sudo cp -f %unixpath%/profile /var/lib/boot2docker/profile
boot2docker ssh sudo /etc/init.d/docker restart
boot2docker ssh cp -f %unixpath%/profile .ashrc
boot2docker ssh cp -f %unixpath%/.bash_aliases .bash_aliases
boot2docker ssh
