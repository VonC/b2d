if [[ "#hasproxy#" == "1" ]]; then
	sed -e "s;^.*ENV http_proxy .*$;#http_proxy#;g"
    sed -e "s;^.*ENV https_proxy .*$;#https_proxy#;g"
    sed -e "s;^.*ENV no_proxy .*$;#no_proxy#;g"
fi
