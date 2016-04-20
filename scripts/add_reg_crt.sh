if [[ ! -e /var/lib/boot2docker/registry.crt ]]; then
	openssl s_client -connect kv:5000 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM | sudo tee /var/lib/boot2docker/registry.crt
fi
rline=$(tail -2 /var/lib/boot2docker/registry.crt | head -1)
if [[ "$(grep ${rline} /etc/ssl/certs/ca-certificates.crt)" == "" ]]; then
	cat /var/lib/boot2docker/registry.crt | sudo tee -a /etc/ssl/certs/ca-certificates.crt
fi
grep $rline /etc/ssl/certs/ca-certificates.crt|wc
