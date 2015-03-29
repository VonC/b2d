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

export HTTP_PROXY=#HTTP_PROXY#
export HTTPS_PROXY=#HTTPS_PROXY#
export NO_PROXY=#NO_PROXY#

export http_proxy=#HTTP_PROXY#
export https_proxy=#HTTPS_PROXY#
export no_proxy=#NO_PROXY#

alias l='ls -alrt'
alias h=history
alias cdd='cd #unixpath#'

ln -fs #unixpath# /home/docker
