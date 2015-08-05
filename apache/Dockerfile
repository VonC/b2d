FROM apache.inst:latest

MAINTAINER VonC <vonc@laposte.net>
USER root
ENV HOME_GIT /home/git
WORKDIR $HOME_GIT
RUN git clone https://github.com/Semantic-Org/Semantic-UI -b 0.9.1 --depth=1 Semantic-UI
RUN mkdir apache
RUN mkdir apache/log
WORKDIR $HOME_GIT/apache
COPY gen_ssl_key_and_crt.sh ./
RUN chmod +x gen_ssl_key_and_crt.sh
COPY update_cnf.sh  ./
COPY ctld ./
RUN mkdir logins
RUN ln -s  ${HOME_GIT}/apache/ctld  ${HOME_GIT}/bin/ctld
RUN chmod +x update_cnf.sh
RUN chmod +x  ctld
RUN ln -s /usr/local/apache2/conf/httpd.conf cnf1
RUN ln -s ${HOME_GIT}/apache/env.conf cnf
RUN ln -s /usr/local/apache2/bin/envvars envvars
RUN chown -R git:git /home/git/apache

RUN ln -s a_global_ca.crt ${HOME_GIT}/apache/global_ca.crt
RUN ln -s ../.ssh/curl-ca-bundle.crt ${HOME_GIT}/apache/a_global_ca.crt
RUN ln -s /usr/local/apache2/bin/rotatelogs ${HOME_GIT}/bin/rotatelogs
RUN mkdir /usr/local/apache2/logs
RUN ln -s /usr/local/apache2/logs ${HOME_GIT}/apache/logs
RUN ./update_cnf.sh
RUN mkdir ${HOME_GIT}/cgit

COPY o.cnf ./
RUN chown -R git:git /home/git/apache
RUN chown -R git:git /usr/local/apache2/logs

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $PATH:$HTTPD_PREFIX/bin

USER git
RUN ./gen_ssl_key_and_crt.sh
USER root

RUN mkdir ${HOME_GIT}/gitweb
WORKDIR ${HOME_GIT}/gitweb
COPY gitweb/* ./
RUN ln -s /usr/share/gitweb gitweb
RUN ln -s ../Semantic-UI Semantic-UI
RUN ln -s gitweb/static static
RUN ln -s gitweb/gitweb.cgi gitweb.cgi
RUN ln -s gitweb-favicon.png favicon.ico
RUN ln -s gitweb.conf.pl cnf

WORKDIR $HTTPD_PREFIX

COPY httpd-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/httpd-foreground

EXPOSE 8091
EXPOSE 8433
EXPOSE 8443
EXPOSE 8453
EXPOSE 8463
WORKDIR $HOME_GIT/apache
COPY env.conf ./
RUN chown -R git:git /home/git/apache
USER git
ENTRYPOINT ["/bin/sh", "-c"]
#ENTRYPOINT ["httpd-foreground"]
