#! /bin/sh

DIR="$( cd "$( dirname "$0" )" && pwd )"
echo ${DIR}
certs="${DIR}/certs"
if [[ -e "${certs}/key" && -e "${certs}/crt" ]] ; then exit 0 ; fi

a_hostname=localhost
a_fqn=localhost

# if no private certificate was given, generate self-signed one locally

fqnpassword="${a_fqn}1";
passphrasekey="${certs}/${a_fqn}.passphrase.key"
key="${certs}/${a_fqn}.key"
cert="${certs}/${a_fqn}.crt"
cnf="${DIR}/o.cnf"
#cnf="${certs}/openssl.cnf"
ext="v3_ca"
#ext="v3_req"
if [[ ! -e "${passphrasekey}" ]]; then
  openssl genrsa -des3 -passout pass:${fqnpassword} -out "${passphrasekey}" 1024
  openssl rsa -passin pass:${fqnpassword} -in "${passphrasekey}" -out "${key}"
  openssl req -new -config "${cnf}" -extensions "${ext}" -x509 -days 730 -key "${key}" -out "${cert}"
  # cat "${cert}" >> "${HOME}/.ssh/curl-ca-bundle.crt"
fi
cp -f "${key}" "${certs}/key"
cp -f "${cert}" "${certs}/crt"
