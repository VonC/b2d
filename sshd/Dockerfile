FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN  apt-get -yq update \
  && apt-get -yqq install ssh

WORKDIR /home/git
COPY post_install_ssh.sh .ssh/
COPY cnf .ssh/
RUN ln -s ../.ssh/post_install_ssh.sh bin/post_install_ssh.sh
RUN chown -R git:git /home/git && \
	chmod +x /home/git/.ssh/post_install_ssh.sh
USER git
ENTRYPOINT ["/bin/sh", "-c"]
