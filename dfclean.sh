sed -e "s;^.*ENV http_proxy .*$;# ENV http_proxy http://<user>:<pwd>@proxy.company:80;g" \
	-e "s;^.*ENV https_proxy .*$;# ENV https_proxy http://<user>:<pwd>@proxy.company:80;g" \
	-e "s;^.*ENV no_proxy .*$;# ENV no_proxy .company,.sock,localhost,127.0.0.1,::1,192.168.59.103;g"
