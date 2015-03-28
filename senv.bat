@echo off

rem http://stackoverflow.com/a/7218493/6309: test substring
echo.%PATH%| findstr /C:"Boot2Docker" 1>nul

if errorlevel 1 (
  rem http://stackoverflow.com/a/9806979/
  rem avoid "x86) not expected at this time" error message
  set "PATH=%PATH%;c:\prgs\Boot2Docker4W"
)

doskey vbm="c:\prgs\VirtualBox\VBoxManage.exe" $*
doskey vbmmt="c:\prgs\VirtualBox\VBoxManage.exe modifyvm \"boot2docker-vm\" natpf1 \"tcp-port$1,tcp,,$1,,$1\";"
doskey vbmmu="c:\prgs\VirtualBox\VBoxManage.exe modifyvm \"boot2docker-vm\" natpf1 \"udp-port$1,udp,,$1,,$1\";"
doskey vbmct="c:\prgs\VirtualBox\VBoxManage.exe controlvm \"boot2docker-vm\" natpf1 \"tcp-port$1,tcp,,$1,,$1\";"
doskey vbmcu="c:\prgs\VirtualBox\VBoxManage.exe controlvm \"boot2docker-vm\" natpf1 \"udp-port$1,udp,,$1,,$1\";"
:end
