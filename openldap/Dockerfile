FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN  apt-get -yq update \
  && apt-get -yqq install slapd

# curl https://raw.githubusercontent.com/VonC/compileEverything/master/openldap/slapdd.tpl -o $HOME/b2d/openldap/slapdd
COPY slapdd /home/git/bin/slapdd
RUN mkdir -p /home/git/openldap
# curl https://raw.githubusercontent.com/VonC/compileEverything/master/openldap/slapd.1.conf.tpl -o $HOME/b2d/openldap/slapd.1.conf
COPY slapd.1.conf /home/git/openldap/slapd.1.conf
RUN ln -s a_global_ca.crt /home/git/openldap/global_ca.crt
RUN ln -s ../.ssh/curl-ca-bundle.crt /home/git/openldap/a_global_ca.crt
RUN chown -R git:git /home/git
WORKDIR /home/git

ENV PORT_LDAP_TEST 9000
