FROM apache.inst:latest

MAINTAINER VonC <vonc@laposte.net>
#USER git
ENV HOME_GIT /home/git
WORKDIR $HOME_GIT
RUN mkdir apache
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
RUN mkdir /usr/local/apache2/logs
RUN ./update_cnf.sh

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $PATH:$HTTPD_PREFIX/bin

WORKDIR $HTTPD_PREFIX

COPY httpd-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/httpd-foreground

EXPOSE 80
EXPOSE 443

USER git
WORKDIR ${HOME_GIT}
ENTRYPOINT ["/bin/sh", "-c"]
#ENTRYPOINT ["httpd-foreground"]
