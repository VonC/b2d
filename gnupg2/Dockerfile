FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN  apt-get -yq update \
  && apt-get -yqq install gnupg2

RUN mkdir /home/git/.gnupg
RUN mkdir -p /home/git/sbin/usrcmd
COPY get_tpl_value /home/git/sbin/usrcmd/
RUN chmod +x /home/git/sbin/usrcmd/get_tpl_value
COPY ini_users_gpg /home/git/bin/
RUN chmod +x /home/git/bin/ini_users_gpg
COPY .envs.example /home/git/.envs.private
COPY projextrdr.unattended /home/git/.gnupg/

RUN chown -R git:git /home/git
WORKDIR /home/git/.gnupg
USER git
ENV H=/home/git

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo Data Volume Container for gnupg users credentials"]
