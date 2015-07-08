#! /bin/bash

apache="${HOME_GIT}/apache"

sed -i "s/^#ServerName .*$/ServerName localhost/" "/usr/local/apache2/conf/httpd.conf"
ctld stop
last_line=$(tail -1 "${apache}/cnf1")
include="Include \"${apache}/cnf\""
if [[ "${last_line}" != "${include}" ]]; then
  echo add
  echo "${include}">>"${apache}/cnf1"
else
  echo ok
fi
sed -i "s/^Listen 80/#Listen 80/" "/usr/local/apache2/conf/httpd.conf"
