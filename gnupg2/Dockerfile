FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

RUN mkdir /home/git/.gnupg
COPY projextrdr.unattended /home/git/.gnupg/
COPY gpg-agent.conf /home/git/.gnupg/

COPY ini_users_gpg /home/git/.gnupg/
RUN chmod +x /home/git/.gnupg/ini_users_gpg
RUN ln -s ../.gnupg/ini_users_gpg /home/git/bin/ini_users_gpg

COPY ini-git-credential-netrc /home/git/.gnupg/
RUN chmod +x /home/git/.gnupg/ini-git-credential-netrc
RUN ln -s ../.gnupg/ini-git-credential-netrc /home/git/bin/ini-git-credential-netrc

COPY check_gpg-agent /home/git/.gnupg/
RUN chmod +x /home/git/.gnupg/check_gpg-agent

RUN chown -R git:git /home/git
RUN chown -R git:git /usr/share/doc/git/contrib/credential/netrc
WORKDIR /home/git/.gnupg
USER git
ENV H=/home/git
RUN ini-git-credential-netrc
VOLUME /home/git/.gnupg

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo Data Volume Container for gnupg users credentials"]
