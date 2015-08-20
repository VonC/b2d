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
  && add-apt-repository ppa:hloeung/gnupg2 \
  && apt-get -yq update \
  && apt-get -yqq install \
     wget \
     curl \
     ca-certificates \
     git \
     openssl \
     ldap-utils \
     iputils-ping \
     gnupg2
RUN adduser --system --group --shell /bin/sh git \
 && mkdir /home/git/bin
COPY profile /home/git/.profile
COPY bashrc /home/git/.bashrc
COPY bash_aliases /home/git/.bash_aliases
RUN mkdir /home/git/.ssh
COPY curl-ca-bundle.crt /home/git/.ssh/
RUN mkdir -p /home/git/sbin/usrcmd
COPY get_tpl_value /home/git/sbin/usrcmd/
RUN chmod +x /home/git/sbin/usrcmd/get_tpl_value
RUN chown -R git:git /home/git
ENV PATH="$PATH:/home/git/bin"
WORKDIR /home/git
COPY bash_aliases /root/.bash_aliases
ENTRYPOINT bash -l
