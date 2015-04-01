sed -e "s;^.*\(ENV\|export\) \(http_proxy[ =]\|HTTP_PROXY[ =]\).*$;# \1 \2http://<user>:<pwd>@proxy.company:80;g" \
	-e "s;^.*\(ENV\|export\) \(https_proxy[ =]\|HTTPS_PROXY[ =]\).*$;# \1 \2http://<user>:<pwd>@proxy.company:80;g" \
	-e "s;^.*\(ENV\|export\) \(no_proxy[ =]\|NO_PROXY[ =]\).*$;# \1 \2.company,.sock,localhost,127.0.0.1,::1,192.168.59.103;g"\
    -e "s;^.*# unxpath:\(.*\)$;\1;"
