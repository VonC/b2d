. /etc/init.d/tc-functions
if [ -n "$DISPLAY" ]
then
        `which editor >/dev/null` && EDITOR=editor || EDITOR=vi
else
        EDITOR=vi
fi
export EDITOR

# Alias definitions.
#
alias df='df -h'
alias du='du -h'

alias ls='ls -p'
alias ll='ls -l'
alias la='ls -la'

alias d='dmenu_run &'
alias ce='cd /etc/sysconfig/tcedir'

# proxy    should be defined as http://<user>:<pwd>@proxy.company:80
# no_proxy should be defined as .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

# export http_proxy=http://<user>:<pwd>@proxy.company:80
# export https_proxy=http://<user>:<pwd>@proxy.company:80
# export no_proxy=.company,.sock,localhost,127.0.0.1,::1,192.168.59.103

# export HTTP_PROXY=http://<user>:<pwd>@proxy.company:80
# export HTTPS_PROXY=http://<user>:<pwd>@proxy.company:80
# export NO_PROXY=.company,.sock,localhost,127.0.0.1,::1,192.168.59.103

alias l='ls -alrt'
alias h=history
alias cdd='cd #unixpath#'

ln -fs #unixpath# /home/docker
export PATH=$PATH:#unixpath#

alias d=docker
alias di='docker images'
alias dps='docker ps'
alias dka='docker kill $(docker ps -q --no-trunc)'
alias dsta='docker stop $(docker ps -q --no-trunc)'
alias drmae='docker rm $(docker ps -qa --no-trunc --filter "status=exited")'
alias drmiad='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias dr='docker run'
alias dritrm='docker run -it --rm'
alias dpsa='docker ps -a'
alias din='docker inspect'

alias dc='docker run -i -t -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`:`pwd` -w `pwd` docker-compose'
