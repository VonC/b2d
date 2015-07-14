#! /bin/bash

apache="${HOME}/apache"
if [[ -e "${apache}/key" && -e "${apache}/crt" ]] ; then exit 0 ; fi

a_hostname=localhost
a_fqn=localhost

hkey="${HOME}/../${a_hostname}.key"
hcrt="${HOME}/../${a_hostname}.crt"

if [[ -e "${hkey}" && -e "${hcrt}" ]] ; then
  ln -fs "${hkey}" "${apache}/key"
  ln -fs "${hcrt}" "${apache}/crt"
  exit 0
fi

# if no private certificate was given, generate self-signed one locally

fqnpassword="${a_fqn}1";
passphrasekey="${apache}/${a_fqn}.passphrase.key"
key="${apache}/${a_fqn}.key"
cert="${apache}/${a_fqn}.crt"
cnf="${apache}/o.cnf"
#cnf="${apache}/openssl.cnf"
ext="v3_ca"
#ext="v3_req"
if [[ ! -e "${passphrasekey}" ]]; then
  openssl genrsa -des3 -passout pass:${fqnpassword} -out "${passphrasekey}" 1024
  openssl rsa -passin pass:${fqnpassword} -in "${passphrasekey}" -out "${key}"
  openssl req -new -config "${cnf}" -extensions "${ext}" -x509 -days 730 -key "${key}" -out "${cert}"
  cat "${cert}" >> "${HOME}/.ssh/curl-ca-bundle.crt"
fi
ln -fs "${a_fqn}.key" "${apache}/key"
ln -fs "${a_fqn}.crt" "${apache}/crt"
