FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

RUN apt-get -yq update && apt-get -y --fix-missing install gcc g++
RUN apt-get -y --fix-missing install make cmake automake m4 pkg-config
RUN apt-get -y --fix-missing install python
RUN apt-get -y --fix-missing install libtool libtool-bin checkinstall libpcre3-dev
