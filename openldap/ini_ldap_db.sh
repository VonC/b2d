#!/bin/bash -x

H=/home/git
openldap="${H}/openldap"
if [[ ! -e "${openldap}/db.1.a" ]] ; then mkdir -p "${openldap}/db.1.a" ; fi

slapdd stop
slapdd start

echo "Before wait: $(date)"
read -t2 -n1 -r -p "Waiting a few seconds for ldap to start..." key
echo -e "\nAfter wait : $(date)"

slapdd status

bj=$(ldapsearch -P 3 -x  -LLL -S "" -b "dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} 'uid=bjensen' uid)
echo "bj='${bj}'"

if [[ "${bj}" == "" ]] ; then
  ldapmodify -a -P 3 -x -D "cn=Manager,dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} -w secret < "${openldap}/test-ordered.ldif"
  bj=$(ldapsearch -P 3 -x  -LLL -S "" -b "dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} 'uid=bjensen' uid)
  echo "bj='${bj}'"
fi

ga=$(ldapsearch -P 3 -x  -LLL -S "" -b "dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} 'uid=gitoliteadm' uid)
echo "ga='${ga}'"

if [[ "${ga}" == "" ]] ; then
  ldapmodify -a -P 3 -x -D "cn=Manager,dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} -w secret < "${openldap}/gitoliteadm.ldif"
  ga=$(ldapsearch -P 3 -x  -LLL -S "" -b "dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} 'uid=gitoliteadm' uid)
  echo "ga='${ga}'"
fi

usr=$(ldapsearch -P 3 -x  -LLL -S "" -b "dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} 'uid=almadm1' uid)
echo "usr='${usr}'"

if [[ "${usr}" == "" ]] ; then
  echo ldapmodify -a -P 3 -x -D "cn=Manager,dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} -w secret < "${openldap}/users-usecases.ldif"
  ldapmodify -a -P 3 -x -D "cn=Manager,dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} -w secret < "${openldap}/users-usecases.ldif"
  usr=$(ldapsearch -P 3 -x  -LLL -S "" -b "dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} 'uid=almadm1' uid)
  echo "usr='${usr}'"
fi

extusr=$(ldapsearch -P 3 -x  -LLL -S "" -b "dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} 'uid=projextusr1' uid)
echo "extusr='${extusr}'"

if [[ "${extusr}" == "" ]] ; then
  echo ldapmodify -a -P 3 -x -D "cn=Manager,dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} -w secret < "${openldap}/users-usecases.ext.ldif"
  ldapmodify -a -P 3 -x -D "cn=Manager,dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} -w secret < "${openldap}/users-usecases.ext.ldif"
  extusr=$(ldapsearch -P 3 -x  -LLL -S "" -b "dc=example,dc=com" -h localhost -p ${PORT_LDAP_TEST} 'uid=projextusr1' uid)
  echo "extusr='${extusr}'"
fi

slapdd stop
