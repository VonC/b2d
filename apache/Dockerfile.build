FROM gcc:latest

MAINTAINER VonC <vonc@laposte.net>

# https://lists.ubuntu.com/archives/vivid-changes/2015-March/006251.html
RUN  apt-get -yq update \
  && apt-get -yqq install libldap2-dev

# http://superuser.com/questions/740930/apt-get-upgrade-openssl-wont-bring-ubuntu-12-04-to-latest-version
RUN apt-get -yqq install --reinstall libssl1.0.0 libssl-dev

RUN git clone https://github.com/apache/httpd.git -b 2.4.10 --depth=1 /usr/local/src/httpd-2.4.10
WORKDIR /usr/local/src/httpd-2.4.10
RUN git clone https://github.com/apache/apr.git -b 1.5.1 --depth=1 srclib/apr
RUN git clone https://github.com/apache/apr-util.git -b 1.5.4 --depth=1 srclib/apr-util
COPY mod_authn_core.c.patch /usr/local/src/mod_authn_core.c.patch
COPY mod_auth_form.c.patch /usr/local/src/mod_auth_form.c.patch
# RUN curl https://raw.githubusercontent.com/VonC/compileEverything/master/apache/mod_authn_core.c.patch -o /usr/local/src/mod_authn_core.c.patch
# RUN curl https://raw.githubusercontent.com/VonC/compileEverything/master/apache/mod_auth_form.c.patch -o /usr/local/src/mod_auth_form.c.patch
RUN patch -r - -N modules/aaa/mod_authn_core.c < ../mod_authn_core.c.patch ; true
RUN patch -r - -N modules/aaa/mod_auth_form.c < ../mod_auth_form.c.patch ; true
RUN ./buildconf
RUN ./configure --with-included-apr --enable-mpm=worker --enable-suexec --enable-rewrite --enable-ssl=shared --enable-ssl --enable-proxy --enable-proxy-connect --enable-proxy-ftp --enable-proxy-http --with-ldap --enable-ldap --enable-authnz-ldap --enable-authn-alias --with-crypto --enable-mods-shared=all
RUN make
RUN checkinstall --pkgname=apache2-4 --pkgversion="2.4.10" --backup=no --deldoc=yes --fstrans=no --default
RUN mkdir $HOME/deb && mv *.deb $HOME/deb
VOLUME /root/deb
ENTRYPOINT ["echo"]
CMD ["\"Data Volume Container for apache /root/deb\""]
