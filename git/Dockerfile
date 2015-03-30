FROM debian:jessie

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes git

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes gcc make automake autoconf

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes libcurl4-gnutls-dev libexpat1-dev asciidoc xmlto docbook2x

RUN git clone https://github.com/git/git /usr/local/src/git
RUN git -C /usr/local/src/git checkout v2.3.4
RUN cd /usr/local/src/git && make configure
RUN cd /usr/local/src/git && ./configure --prefix=/usr
RUN cd /usr/local/src/git && make all doc
RUN cd /usr/local/src/git && make install install-doc install-html
