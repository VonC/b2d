FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN  apt-get -yq update \
  && apt-get -yqq install mcron

WORKDIR /home/git
RUN mkdir -p shippingbay_git/incoming && \
	mkdir -p shippingbay_git/outgoing && \
	mkdir mcron && mkdir -p .config/cron
COPY pull_external mcron/
COPY clean_shipping_bay mcron/
RUN ln -s ../mcron/pull_external bin/pull_external && \
	ln -s ../mcron/clean_shipping_bay bin/clean_shipping_bay
COPY config .ssh/
COPY update_known_hosts .ssh/
RUN chmod +x /home/git/mcron/pull_external && \
	chmod +x /home/git/mcron/clean_shipping_bay && \
	chmod 644 /home/git/.ssh/config && \
	chmod 755 /home/git/.ssh/update_known_hosts && \
	ln -s ../.ssh/update_known_hosts bin/update_known_hosts && \
	chown -R git:git /home/git
USER git
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["mcron"]
