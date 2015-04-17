FROM ubuntu:vivid

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

RUN  apt-get -yq update \
  && apt-get -yqq install software-properties-common

RUN  add-apt-repository ppa:git-core/ppa \
  && apt-get -yq update \
  && apt-get -yqq install \
     wget \
     curl \
     ca-certificates \
     git \
     openssl \
     ldap-utils \
     iputils-ping
