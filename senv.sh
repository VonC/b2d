#!/bin/bash

echo $PATH
scriptdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo $scriptdir
echo $PATH|grep -E ":${scriptdir}($|:)"
if [ $? -ne 0 ]; then
	echo "add path"
	export PATH=$PATH:${scriptdir}
fi
parent=$(dirname ${scriptdir})
echo $parent
set -a 
if [ -e ../env.bat ]; then . ../env.bat; fi
set +a
git -C $scriptdir config filter.dffilter.smudge ${scriptdir}/dfsmudge.sh
git -C $scriptdir config filter.dffilter.clean ${scriptdir}/dfclean.sh
cp -f ${scriptdir}/dfsmudge.sh.template ${scriptdir}/dfsmudge.sh
chmod +x ${scriptdir}/dfsmudge.sh

if [[ ! -z ${http_proxy} ]]
	then
    sed -i -e "s/#hasproxy#/1/g" dfsmudge.sh
	sed -i -e "s;#http_proxy#;${http_proxy};g" dfsmudge.sh
	sed -i -e "s;#https_proxy#;${https_proxy};g" dfsmudge.sh
	sed -i -e "s;#no_proxy#;${no_proxy};g" dfsmudge.sh
fi

sed -i -e "s;_unixpath_;${scriptdir};g" dfsmudge.sh
echo $HOME
export HOME=${parent}
export PATH=$PATH:${scriptdir}

