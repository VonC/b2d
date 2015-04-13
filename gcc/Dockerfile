FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

# ENV http_proxy http://<user>:<pwd>@proxy.company:80
# ENV https_proxy http://<user>:<pwd>@proxy.company:80
# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103

RUN apt-get -yq update && apt-get -y --fix-missing install gcc g++
RUN apt-get -y --fix-missing install make cmake automake m4 pkg-config
