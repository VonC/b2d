FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

# From https://github.com/dockerfile/nginx/blob/master/Dockerfile
# Install Nginx.
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  chown -R www-data:www-data /var/lib/nginx

# Expose ports.
EXPOSE 80
EXPOSE 443

# Define default command.
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["nginx"]

WORKDIR /home/git
RUN mkdir nginx
WORKDIR /home/git/nginx
RUN mkdir html
WORKDIR /home/git/nginx/html
COPY html/* ./
WORKDIR /home/git/nginx
RUN mkdir logs
COPY crt ./itsvc.world.company.crt
COPY key ./itsvc.world.company.key
COPY env.conf ./
RUN ln -s /home/git/nginx/env.conf cnf
RUN ln -fs /home/git/nginx/cnf /etc/nginx/nginx.conf
RUN chown -R git:git /home/git
