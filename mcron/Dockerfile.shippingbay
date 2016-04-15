FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

WORKDIR /home/git
RUN mkdir -p shippingbay_git/incoming && \
	mkdir -p shippingbay_git/outgoing && \
	chown -R git:git /home/git

VOLUME ["/home/git/shippingbay_git"]

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo Data Volume Container for shippingbay_git"]
