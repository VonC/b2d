FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN mkdir /home/git/gitolite ; chown -R git:git /home/git/gitolite

USER git
RUN cd /home/git; git clone git://github.com/sitaramc/gitolite github;
RUN mkdir -p /home/git/.gitolite/logs
# RUN git -C /home/git/github checkout v3.6.2
RUN /home/git/github/install -to /home/git/gitolite
RUN USER=git /home/git/gitolite/gitolite setup -a git
