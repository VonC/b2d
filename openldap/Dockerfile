FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN  apt-get -yq update \
  && apt-get -yqq install slapd

# curl https://raw.githubusercontent.com/VonC/compileEverything/master/openldap/slapdd.tpl -o $HOME/b2d/openldap/slapdd
COPY slapdd /home/git/bin/slapdd
RUN chmod +x  /home/git/bin/slapdd
COPY slapds /home/git/bin/slapds
RUN chmod +x  /home/git/bin/slapds

RUN mkdir -p /home/git/openldap
RUN ln -s a_global_ca.crt /home/git/openldap/global_ca.crt
RUN ln -s ../.ssh/curl-ca-bundle.crt /home/git/openldap/a_global_ca.crt

# curl https://raw.githubusercontent.com/VonC/compileEverything/master/openldap/slapd.1.conf.tpl -o $HOME/b2d/openldap/slapd.1.conf
COPY slapd.1.conf /home/git/openldap/slapd.1.conf

ENV PORT_LDAP_TEST 9011
COPY ldap.conf /home/git/openldap/ldap.conf

RUN ln -s -f /home/git/openldap/slapd.1.conf /usr/share/slapd/slapd.conf
RUN ln -s -f /home/git/openldap/ldap.conf /etc/ldap/ldap.conf
RUN ln -s /etc/ldap/schema /home/git/openldap/schema
COPY test-ordered.ldif /home/git/openldap/
COPY gitoliteadm.ldif /home/git/openldap/
COPY users-usecases.ext.ldif /home/git/openldap/
COPY users-usecases.ldif /home/git/openldap/
COPY test.schema /home/git/openldap/
COPY base /home/git/openldap/

RUN ln -s slapd.1.conf /home/git/openldap/cnf
RUN ln -s ldap.conf /home/git/openldap/cnf1
COPY ini_ldap_db.sh /home/git/openldap/
RUN chmod +x /home/git/openldap/ini_ldap_db.sh
RUN chown -R git:git /home/git
WORKDIR /home/git
USER git
RUN mkdir openldap/db.1.a
# RUN /home/git/openldap/ini_ldap_db.sh && /home/git/openldap/ini_ldap_db.sh && /home/git/openldap/ini_ldap_db.sh && /home/git/openldap/ini_ldap_db.sh
ENTRYPOINT ["sh", "-c"]
CMD ["slapds"]
