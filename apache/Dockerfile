FROM apache.inst:latest

MAINTAINER VonC <vonc@laposte.net>
USER root
ENV HOME_GIT /home/git
WORKDIR $HOME_GIT
RUN mkdir apache
RUN mkdir apache/log
WORKDIR $HOME_GIT/apache
COPY env.conf ./
COPY update_cnf.sh  ./
COPY ctld ./
RUN chown -R git:git /home/git/apache
RUN ln -s  ${HOME_GIT}/apache/ctld  ${HOME_GIT}/bin/ctld
RUN chmod +x update_cnf.sh
RUN chmod +x  ctld
RUN ln -s /usr/local/apache2/conf/httpd.conf cnf1
RUN ln -s ${HOME_GIT}/apache/env.conf cnf
RUN ln -s /usr/local/apache2/bin/envvars envvars
RUN ln -s a_global_ca.crt ${HOME_GIT}/apache/global_ca.crt
RUN ln -s ../.ssh/curl-ca-bundle.crt ${HOME_GIT}/apache/a_global_ca.crt
RUN ln -s /usr/local/apache2/bin/rotatelogs ${HOME_GIT}/bin/rotatelogs
RUN mkdir /usr/local/apache2/logs
RUN ln -s /usr/local/apache2/logs ${HOME_GIT}/apache/logs
RUN ./update_cnf.sh
RUN ln -s /usr/share/gitweb ${HOME_GIT}/gitweb
RUN mkdir ${HOME_GIT}/cgit

COPY o.cnf ./
COPY gen_ssl_key_and_crt.sh ./
RUN chmod +x gen_ssl_key_and_crt.sh
RUN chown -R git:git /home/git/apache

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $PATH:$HTTPD_PREFIX/bin

WORKDIR $HTTPD_PREFIX

COPY httpd-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/httpd-foreground

EXPOSE 8091
EXPOSE 8433
EXPOSE 8443
EXPOSE 8453
EXPOSE 8463
USER git
WORKDIR $HOME_GIT/apache
RUN ./gen_ssl_key_and_crt.sh
ENTRYPOINT ["/bin/sh", "-c"]
#ENTRYPOINT ["httpd-foreground"]
