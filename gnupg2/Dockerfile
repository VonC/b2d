FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN mkdir /home/git/.gnupg
RUN mkdir -p /home/git/sbin/usrcmd
COPY get_tpl_value /home/git/sbin/usrcmd/
RUN chmod +x /home/git/sbin/usrcmd/get_tpl_value
COPY projextrdr.unattended /home/git/.gnupg/
COPY gpg-agent.conf /home/git/.gnupg/

COPY ini_users_gpg /home/git/bin/
RUN chmod +x /home/git/bin/ini_users_gpg
COPY ini-git-credential-netrc /home/git/bin/
RUN chmod +x /home/git/bin/ini-git-credential-netrc

RUN chown -R git:git /home/git
RUN chown -R git:git /usr/share/doc/git/contrib/credential/netrc
WORKDIR /home/git/.gnupg
USER git
ENV H=/home/git
RUN ini-git-credential-netrc
VOLUME /home/git/.gnupg

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo Data Volume Container for gnupg users credentials"]
