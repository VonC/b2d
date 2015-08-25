FROM apache.inst:latest

MAINTAINER VonC <vonc@laposte.net>
USER root
ENV HOME_GIT /home/git
WORKDIR $HOME_GIT
RUN git clone https://github.com/Semantic-Org/Semantic-UI -b 0.9.1 --depth=1 Semantic-UI
RUN mkdir -p apache/log
WORKDIR $HOME_GIT/apache
COPY gen_ssl_key_and_crt.sh ./
RUN chmod +x gen_ssl_key_and_crt.sh
COPY update_cnf.sh  ./
COPY update_curl-ca-bundle  ./
COPY ctld ./
COPY check_gitolite ./
RUN mkdir logins
RUN ln -s  ${HOME_GIT}/apache/ctld  ${HOME_GIT}/bin/ctld && \
 ln -s  ${HOME_GIT}/apache/check_gitolite  ${HOME_GIT}/bin/check_gitolite && \
 ln -s  ${HOME_GIT}/apache/update_curl-ca-bundle  ${HOME_GIT}/bin/update_curl-ca-bundle
RUN chmod +x update_cnf.sh && \
    chmod +x update_curl-ca-bundle && \
    chmod +x  ctld && \
    chmod +x  check_gitolite
RUN ln -s /usr/local/apache2/conf/httpd.conf cnf1 && \
    ln -s ${HOME_GIT}/apache/env.conf cnf && \
    ln -s /usr/local/apache2/bin/envvars envvars
RUN chown -R git:git /home/git/apache

RUN ln -s a_global_ca.crt ${HOME_GIT}/apache/global_ca.crt && \
    ln -s ../.ssh/curl-ca-bundle.crt ${HOME_GIT}/apache/a_global_ca.crt && \
    ln -s /usr/local/apache2/bin/rotatelogs ${HOME_GIT}/bin/rotatelogs
RUN mkdir /usr/local/apache2/logs
RUN ln -s /usr/local/apache2/logs ${HOME_GIT}/apache/logs
RUN ./update_cnf.sh
RUN ./update_curl-ca-bundle
RUN mkdir ${HOME_GIT}/cgit

COPY o.cnf ./
RUN chown -R git:git /home/git/apache && \
    chown -R git:git /usr/local/apache2/logs

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $PATH:$HTTPD_PREFIX/bin

USER git
RUN ./gen_ssl_key_and_crt.sh
USER root

RUN mkdir ${HOME_GIT}/gitweb
WORKDIR ${HOME_GIT}/gitweb
COPY gitweb/* ./
RUN ln -s /usr/share/gitweb gitweb && \
    ln -s ../Semantic-UI Semantic-UI && \
    ln -s gitweb/static static && \
    ln -s gitweb/gitweb.cgi gitweb.cgi
RUN cp gitweb/gitweb.cgi gitweb.cgi.ori
RUN ln -s gitweb-favicon.png favicon.ico && \
    ln -s gitweb.conf.pl cnf
RUN sed -i "s#print \"</body>#print \"<script src=\\\\\"jquery.min.js\\\\\"></script>\\\\n<script src=\\\\\"document_ready.js\\\\\"></script>\\\\n<script>if (top != self) top.location=location</script>\\\\n</body>#" "/home/git/gitweb/gitweb/gitweb.cgi"

WORKDIR $HTTPD_PREFIX

COPY httpd-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/httpd-foreground

# EXPOSE 8091
EXPOSE 8543
EXPOSE 8553
WORKDIR $HOME_GIT/apache
COPY env.conf ./
RUN chown -R git:git /home/git/apache
USER git
# Define default command.
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["apachectl -DFOREGROUND"]
