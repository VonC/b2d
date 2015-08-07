FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103


RUN mkdir /home/git/gitolite
RUN mkdir -p /home/git/.gitolite/logs
COPY install_or_update_gitolite.sh /home/git/bin/
RUN chmod +x /home/git/bin/install_or_update_gitolite.sh
RUN chown -R git:git /home/git
WORKDIR /home/git
USER git
RUN git clone https://github.com/sitaramc/gitolite /home/git/gitolite/github
RUN /home/git/bin/install_or_update_gitolite.sh

VOLUME /home/git/gitolite
VOLUME /home/git/.gitolite

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo Data Volume Container for gitolite installation"]
