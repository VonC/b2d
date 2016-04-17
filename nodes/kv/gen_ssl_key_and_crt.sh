#! /bin/sh

DIR="$( cd "$( dirname "$(readlink -f "$0")" )" && pwd )"
echo ${DIR}
certs="${DIR}/certs"
if [[ -e "${certs}/key" && -e "${certs}/crt" ]] ; then exit 0 ; fi
if [[ ! -e ${certs} ]]; then mkdir -p ${certs}; fi

a_hostname=localhost
a_fqn=localhost

machine=$(hostname)
# http://unix.stackexchange.com/questions/119269/how-to-get-ip-address-using-shell-script
ip=$(ifconfig eth1 | awk '/inet addr/{print substr($2,6)}')
echo "machine='${machine}', ip='${ip}'"

# if no private certificate was given, generate self-signed one locally

fqnpassword="${a_fqn}1";
passphrasekey="${certs}/${a_fqn}.passphrase.key"
key="${certs}/${a_fqn}.key"
cert="${certs}/${a_fqn}.crt"
cnf="${DIR}/o.cnf"
dcnf="${DIR}/.o.cnf"
sed "s/#san#/DNS:localhost,DNS:${machine},IP:${ip}/" ${cnf}>"${dcnf}"

#cnf="${certs}/openssl.cnf"
ext="v3_ca"
#ext="v3_req"
if [[ ! -e "${passphrasekey}" ]]; then
  openssl genrsa -des3 -passout pass:${fqnpassword} -out "${passphrasekey}" 1024
  openssl rsa -passin pass:${fqnpassword} -in "${passphrasekey}" -out "${key}"
  openssl req -new -config "${dcnf}" -extensions "${ext}" -x509 -days 730 -key "${key}" -out "${cert}"
  # cat "${cert}" >> "${HOME}/.ssh/curl-ca-bundle.crt"
fi
cp -f "${key}" "${certs}/key"
cp -f "${cert}" "${certs}/crt"
