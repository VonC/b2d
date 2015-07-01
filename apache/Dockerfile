FROM apache.inst:latest

MAINTAINER VonC <vonc@laposte.net>

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $PATH:$HTTPD_PREFIX/bin

WORKDIR $HTTPD_PREFIX

COPY httpd-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/httpd-foreground

EXPOSE 80
EXPOSE 443

CMD ["httpd-foreground"]
