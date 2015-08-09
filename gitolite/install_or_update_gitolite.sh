#!/bin/bash

H=/home/git
gtl="${H}/gitolite"
github="${gtl}/github"
githubdir="${H}/.git/modules/gitolite"

mkdir -p "${gtl}/bin"
"${github}/install" -to "${gtl}/bin"
ssh-keygen -t rsa -f "${H}/.ssh/gitoliteadm" -C "Gitolite Admin access (not interactive)" -q -P ""

USER=git GITOLITE_HTTP_HOME= ${gtl}/bin/gitolite setup -pk "${H}/.ssh/gitoliteadm.pub"
sed -i "s,\"/projects.list\",\"/gitolite/projects.list\",g" "${H}/.gitolite.rc"
sed -i "22a\    GITWEB_PROJECTS_LIST        => '$HOME/gitolite/projects.list'," "${H}/.gitolite.rc"
sed -i "s,0077,0007,g" "${H}/.gitolite.rc"
sed -i "s,'','.*',g" "${H}/.gitolite.rc"
if [[ -e "${H}/projects.list" ]] ; then
  mv "${H}/projects.list" "${H}/gitolite/"
fi
  #echo "# REPO_UMASK = 0007" >> "${H}/.gitolite.rc"
#  chmod -R ug+rwX,o-rwx "${H}/repositories/"
#  chmod -R ug-s "${H}/repositories/"
chmod 750 "${H}/.gitolite"
#  find "${H}/repositories/" -type d -print0 | xargs -0 chmod g+s

glc=$(grep "  LOCAL_CODE" "${H}/.gitolite.rc")
if [[ "${glc}" == "" ]] ; then
  a=$(grep -n ");" "${H}/.gitolite.rc")
  a=${a%%:*}
  echo $a
  sed -i "${a}i\    LOCAL_CODE                  => '$HOME/gitolite'," "${H}/.gitolite.rc"
fi

glc=$(grep "GROUPLIST_PGM" "${H}/.gitolite.rc")
if [[ "${glc}" == "" ]] ; then
  a=$(grep -n ");" "${H}/.gitolite.rc")
  a=${a%%:*}
  echo $a
  sed -i "${a}i\    GROUPLIST_PGM                  => 'gitolite-ldap'," "${H}/.gitolite.rc"
fi

#sshd start

#if [[ ! -e "${gtl}/ga" ]]; then
#  git clone gitolitesrv:gitolite-admin "${gtl}/ga"
#else
#  git --git-dir="${gtl}/ga/.git" --work-tree="${gtl}/ga" pull
#fi

#cp_tpl "${gtl}/gitolite-shell" "${H}/sbin"
#cp_tpl "${gtl}/gitolite-ldap" "${H}/sbin"
mkdir -p "${gtl}/ldap"
#cp_tpl "${gtl}/VREF/CHECKID" "${gtl}/VREF"

GL_USER=gitoliteadm ${gtl}/bin/gitolite print-default-rc > "${gtl}/default.gitolite.rc"
set +e
echo vvvvvvvvvvvvvvvvvvvvv
echo diff "${gtl}/default.gitolite.rc" "${H}/.gitolite.rc"
echo vvvvvvvvvvvvvvvvvvvvv
diff "${gtl}/default.gitolite.rc" "${H}/.gitolite.rc"
set -e
