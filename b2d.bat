@echo off
boot2docker start
boot2docker ssh sudo cp -f %unixpath%/profile /var/lib/boot2docker/profile
boot2docker ssh sudo /etc/init.d/docker restart
boot2docker ssh cp -f %unixpath%/profile .ashrc
boot2docker ssh
