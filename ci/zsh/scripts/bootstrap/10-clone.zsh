#!/bin/zsh
#>[what]
#   clone/sync every $GITLAB_GROUP gitlab project into $WORKSPACE_DIR/$HOST_DIR_GITLAB_GROUP
#/[what]

emulate -LR zsh
setopt errexit pipefail
umask 002

##[>] 🤖🤖🤖
#[why] all required, no defaults: token authenticates gitlab (CI sets it, clones over https);
#   group + host dir come from .env or CI variables.
typeset v
for v in GITLAB_TOKEN GITLAB_GROUP HOST_DIR_GITLAB_GROUP; do
  if [[ -z ${(P)v-} ]] {
    print -r -- "clone: skip: $v unset"
    return 0
  }
done

typeset root=${WORKSPACE_DIR:-$HOME/projects/gitlab}
typeset group=$GITLAB_GROUP
typeset host_dir=$HOST_DIR_GITLAB_GROUP

function sync_project {
  local ns=$1 branch=$2 url=$3
  local dest=${root}/${ns}

  if [[ -z $branch ]] branch=main

  if [[ ! -d ${dest}/.git ]] {
    mkdir -p ${dest:h}
    git clone --quiet $url $dest 2> >(grep -v 'cloned an empty repository' >&2)
    print -r -- "clone(new): $dest"
    return 0
  }

  git -C $dest fetch --prune origin

  if { ! git -C $dest rev-parse --verify --quiet origin/$branch >/dev/null } {
    print -r -- "sync(no-changes): $dest"
    return 0
  }

  if [[ -n "$(git -C $dest status --porcelain)" ]] {
    print -r -- "skip(dirty): $dest"
    return 0
  }

  if [[ "$(git -C $dest symbolic-ref --short HEAD)" != $branch ]] git -C $dest switch $branch

  local before=$(git -C $dest rev-parse HEAD)

  if { ! git -C $dest merge --ff-only origin/$branch } {
    print -r -- "skip(diverged): $dest"
    return 0
  }

  if [[ "$(git -C $dest rev-parse HEAD)" == $before ]] {
    print -r -- "sync(no-changes): $dest"
    return 0
  }

  print -r -- "sync(updated): $dest"
}

#[what] CI/token: clone over https with the token (no ssh key); else ssh url
typeset url_field=ssh_url_to_repo
if (( ${+CI} )) url_field=http_url_to_repo

glab api --paginate \
  "groups/${group}/projects?include_subgroups=true&archived=false" \
  | jq -r ".[] | [.path_with_namespace, .default_branch, .${url_field}] | @tsv" \
  | while IFS=$'\t' read -r ns branch url; do
      #[what] map remote path <group>/<subpath> to host dir <host_dir>/<subpath>
      local rel=${host_dir}/${ns#${group}/}
      if (( ${+CI} )) url=${url/#https:\/\//https://oauth2:${GITLAB_TOKEN}@}
      if { ! sync_project $rel $branch $url } print -r -- "sync(fail): ${root}/${rel}"
    done
##[<] 🤖🤖🤖
