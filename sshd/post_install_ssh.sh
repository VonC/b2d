#!/bin/bash

H="/home/git"
mkdir -p "${H}/.ssh"
chmod 700 "${H}"
chmod 700 "${H}/.ssh"
if [[ ! -e "${H}/.ssh/authorized_keys" ]] ; then
  touch "${H}/.ssh/authorized_keys"
fi
chmod 600 "${H}/.ssh/authorized_keys"
chmod 700 "${H}/.ssh"

if [[ ! -h "/etc/ssh/sshd_config" ]] ; then
  cp -f "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.ori"
  ln -fs /home/git/.ssh/cnf /etc/ssh/sshd_config
fi
if [[ ! -h "/etc/ssh/ssh_config" ]] ; then
  cp -f "/etc/ssh/ssh_config" "/etc/ssh/ssh_config.ori"
  ln -fs /home/git/.ssh/config /etc/ssh/ssh_config
fi
if [[ ! -e "${H}/.ssh/root" ]]; then 
  ssh-keygen -t rsa -f "${H}/.ssh/root" -C "Local root access (interactive)" -q -P "" ; cat "${H}/.ssh/root.pub" >> "${H}/.ssh/authorized_keys"
fi

if [[ ! -e "${H}/.ssh/known_hosts" ]] ; then
  touch "${H}/.ssh/known_hosts"
  chmod 644 "${H}/.ssh/known_hosts"
fi
k=$(ssh-keyscan -t rsa,dsa $(hostname) 2>&1 | sort -u)
# echo "k='${k}'"

l=$(grep $(hostname) "${H}/.ssh/known_hosts")
# echo "l='${l}'"
if [[ "${k}" != "" && "${k}" != "${l}" ]] ; then
  echo "${k}" >> "${H}/.ssh/known_hosts"
fi
exit 0
sshd start
l=$(grep "localhost" "${H}/.ssh/known_hosts" | grep nist | tail -1)
p=$(grep "@PORT_SSHD@" "${H}/.ports.ini")
if [[ -e "${H}/../.ports.ini.private" ]] ; then p=$(grep "@PORT_SSHD@" "${H}/../.ports.ini.private") ; fi
if [[ -e "${H}/.ports.ini.private" ]] ; then p=$(grep "@PORT_SSHD@" "${H}/.ports.ini.private") ; fi
p=${p#*=}
k=$(ssh-keyscan -t ecdsa -p ${p} localhost 2>&1 | grep ecdsa | grep nist)
  echo "D: 0k='${k}'"
if [[ "${k}" != "" ]]; then
  k="[localhost]:${p} ${k#* }"
  # echo "D: 1k='${k}'"
  # echo "D: 0l='${l}'"
  if [[ "${k}" != "" && "${k}" != "${l}" ]] ; then
    echo "${k}" >> "${H}/.ssh/known_hosts"
  fi
fi
