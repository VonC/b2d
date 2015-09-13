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
COPY config .ssh/
RUN ln -s ../.ssh/post_install_ssh.sh bin/post_install_ssh.sh && \
	chmod +x /home/git/.ssh/post_install_ssh.sh && \
	chmod 644 .ssh/cnf && chmod 644 .ssh/config &&  \
	chown git:git /etc/ssh/ssh_host*
RUN	post_install_ssh.sh
RUN chown -R git:git /home/git
USER git
ENTRYPOINT ["/usr/sbin/sshd"]
CMD ["-D", "-e"]
