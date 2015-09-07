FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

WORKDIR /home/git
RUN mkdir /home/git/gitolite && mkdir /home/git/logs
RUN chown -R git:git /home/git
USER git
RUN git clone https://github.com/sitaramc/gitolite /home/git/gitolite/github

USER root
RUN mkdir -p /home/git/.gitolite/logs
RUN mkdir -p /home/git/gitolite/hooks
COPY hooks/ /home/git/gitolite/hooks/
RUN chmod -R 755 /home/git/gitolite/hooks
COPY install_or_update_gitolite.sh /home/git/bin/
RUN chmod 755 /home/git/bin/install_or_update_gitolite.sh
COPY init_envs.sh /home/git/bin/
RUN chmod 755 /home/git/bin/init_envs.sh
COPY post-receive-gitolite-admin /home/git/gitolite/
RUN chmod 755 /home/git/gitolite/post-receive-gitolite-admin
RUN chown -R git:git /home/git

USER git
RUN /home/git/bin/install_or_update_gitolite.sh

VOLUME /home/git/gitolite
VOLUME /home/git/.gitolite

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo Data Volume Container for gitolite installation"]
