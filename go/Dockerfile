FROM git:latest

MAINTAINER VonC <vonc@laposte.net>

ENV GOLANG_VERSION 1.4.2

RUN mkdir /go$GOLANG_VERSION && curl -sSL https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz | tar -v -C /go$GOLANG_VERSION -xz --strip-components=1 && ln -fs /go$GOLANG_VERSION /go

ENV GOROOT /go
ENV GOPATH /gopath
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin
