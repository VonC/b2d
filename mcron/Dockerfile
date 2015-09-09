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
	mkdir mcron
COPY pull_external mcron/
COPY clean_shipping_bay mcron/
COPY run_tasks mcron/
RUN ln -s ../mcron/pull_external bin/pull_external && \
	ln -s ../mcron/clean_shipping_bay
RUN chown -R git:git /home/git && \
	chmod +x /home/git/mcron/pull_external && \
	chmod +x /home/git/mcron/clean_shipping_bay && \
	chmod +x /home/git/mcron/run_tasks