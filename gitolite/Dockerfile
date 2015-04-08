FROM go:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN adduser --system --group --shell /bin/sh git
RUN mkdir /gitolite ; chown -R git:git /gitolite

RUN cd /; git clone git://github.com/sitaramc/gitolite /github;
# RUN cd /home/git/gitolite; su git -c "git checkout v3.6.2";
RUN cd /home/git; su git -c "/github/install -to /gitolite; mkdir /home/git/";
RUN chown -R git:git /home/git
