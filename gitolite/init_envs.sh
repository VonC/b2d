#!/bin/bash

H=/home/git

function update_remote() {
  a_remote_name="${1}"
  a_remote_url="${2}"
  a_push_user="${3}"
  r=$(git config --local remote.${a_remote_name}.url|grep "https")

  if [[ "${r}" == "" ]] ; then
    echo "register '${a_remote_name}' as '${a_remote_url}gitolite-admin'"
    git remote add ${a_remote_name} ${a_remote_url}gitolite-admin
  fi

  r=$(git config --local remote.${a_remote_name}.url|grep "https"|grep "${a_push_user}@")

  if [ "${r}" = "" ] || [ "${r#${a_remote_url}}" = "${r}" ] ; then
    echo "update '${a_remote_name}' as '${a_remote_url}gitolite-admin'"
    git remote set-url ${a_remote_name} ${a_remote_url}gitolite-admin
  fi
}

if [[ ! -e "${H}/.envs.private" ]] ; then
  echo "no /home/git/.envs.private"
  exit 0 ;
fi

source "${H}/sbin/usrcmd/get_tpl_value"

get_tpl_value "${H}/.envs.private" "@UPSTREAM_URL_HGIT@" upstream_url
get_tpl_value "${H}/.envs.private" "@UPSTREAM_NAME@" upstream_name

if [[ "${upstream_url}" == "" || "${upstream_name}" == "" ]] ; then
  echo "no upstream_url ('${upstream_url}') or upstream_name ('${upstream_name}')"
  exit 0 ;
fi

# A login must be defined for pushing gitolite admin repo
get_tpl_value "${H}/.envs.private" "@USER_GA_PUSH@" user_ga_push
if [[ "${user_ga_push}" == "" ]] ; then
  echo "No user is registered to push gitolite-admin to upstream url '${upstream_url}'"
  exit 0
fi

upstream_url="${upstream_url#https://}"
upstream_url="${upstream_url#*@}"
upstream_url="https://${user_ga_push}@${upstream_url#https://}"

export GIT_DIR="${H}/repositories/gitolite-admin.git"

update_remote "${upstream_name}" "${upstream_url}" "${user_ga_push}"
update_remote "apache.upstream.cont" "${upstream_url}" "${user_ga_push}"

# TODO to export in an runtime ini script
if [[ -e "${H}/.gnupg/users.netrc.asc" ]]; then
  chelper=$(git config --local --get credential.helper)
  if [[ "${chelper}" == "" || "${chelper#netrc -}" == "${chelper}" ]] ; then
    git config --local credential.helper 'netrc -f ${H}/.gnupg/users.netrc.asc'
  fi
fi

gtl="${H}/gitolite"
ln -fs "../../../gitolite/post-receive-gitolite-admin" "${H}/repositories/gitolite-admin.git/hooks/post-receive"

unset GIT_DIR
