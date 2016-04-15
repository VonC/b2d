FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

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
