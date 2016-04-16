#!/bin/ash

echo "PATH=${PATH}"
b2d=$( cd "$( dirname . )" && pwd )
echo "b2d='${b2d}'"
bindir=${b2d}/bin
echo $PATH|grep -E ":${bindir}($|:)"
if [ $? -ne 0 ]; then
	echo "add path"
	export PATH=$PATH:${bindir}
fi
parent=$(dirname ${b2d})
echo "parent='${parent}'"
set -a 
if [ -e ${parent}/env.sh ]; then . ${parent}/env.sh; fi
set +a
git -C ${b2d} config filter.dffilter.smudge ${bindir}/dfsmudge.sh
git -C ${b2d} config filter.dffilter.clean ${bindir}/dfclean.sh
/bin/cp -f ${bindir}/dfsmudge.sh.template ${bindir}/dfsmudge.sh
chmod +x ${bindir}/dfsmudge.sh

if [[ ! -z ${http_proxy} ]]
	then
    sed -i -e "s/#hasproxy#/1/g" ${bindir}/dfsmudge.sh
	sed -i -e "s;#http_proxy#;${http_proxy};g" ${bindir}/dfsmudge.sh
	sed -i -e "s;#https_proxy#;${https_proxy};g" ${bindir}/dfsmudge.sh
	sed -i -e "s;#no_proxy#;${no_proxy};g" ${bindir}/dfsmudge.sh
fi

sed -i -e "s;_unixpath_;${b2d};g" ${bindir}/dfsmudge.sh
export HOME=${parent}
echo "HOME='$HOME'"
# export PATH=$PATH:${scriptdir}
. ${b2d}/scripts/.bash_aliases
