#!/bin/bash

HERE=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

# Configuration defaults
# These can be overriden in hub-get.cfg
github_url="https://github.com"
hubget_tmp="/tmp/github-get"
hubget_dir="/opt/github"
[ $EUID -ne 0 ] && hubget_dir="$HOME/github"

# Load config, if exists
CFG="$HOME/.hub-get.cfg"
[ -f "$CFG" ] && source "$CFG"

GH=$github_url
TMP=$hubget_tmp
DEST=$hubget_dir
mkdir -p $DEST

usage() {
	echo "hub-get <action> <repo>"
	echo "actions: get remove upgrade list"
	echo "repo: username/project,  ie bibby/hub-get"
	exit
}

cleanup() {
	[ -d "$TMP" ] && rm -rf "$TMP"
}

throw() {
	echo "Err! $1" >&2
	cleanup
	usage
	exit 1
}

repoAction() {
	repo="$1"
	[ -z "$repo" ] && throw "repo not specified"
	ghuser=${repo%/*}
	ghproj=${repo#*/}
}

configVar() {
	local sscfg="sscfg"
	hash $sscfg 2>/dev/null || sscfg=$HERE/sscfg/sscfg

	[ -f "$CFG" ] || {
		$sscfg -c "$CFG"
		$sscfg -q "$CFG" set "github_url" "$hubget_url"
		$sscfg -q "$CFG" set "github_oauth" ""
		$sscfg -q "$CFG" set "hubget_dir" "$hubget_dir"
		$sscfg -q "$CFG" set "hubget_tmp" "$hubget_tmp"
	}
	eval "$sscfg $CFG set $1 $2"
}

rawurlencode() {
  local string="${1}"
  local _outvar="${2}"
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] )
            o="${c}"
        ;;
        * )
            printf -v o '%%%02x' "'$c"
        ;;
     esac
     encoded+="${o}"
  done

  eval "$_outvar=\"${encoded}\""
}

action="$1"
case "$action" in
	"get"|"install")
		repoAction "$2"
		remote="$GH/$repo"
		locally="$DEST/$repo"

		[ -d "$locally" ] && throw "$locally already exists. Did you mean 'upgrade'?"
		mkdir -p $TMP
		cd $TMP
		git clone "$remote"

		[ "$?" == "0" ] || {
			throw "$remote failed to clone"
		}

		destrepo="$DEST/$ghuser"
		mkdir -p "$destrepo"
		mv "$TMP/$ghproj" "$destrepo"

		echo "Cloned $ghproj to $destrepo"
		cleanup
	;;
	"upgrade"|"pull")
		repoAction "$2"
		destrepo="$DEST/$repo"
		[ -d "$destrepo" ] || throw "repository $repo not found in $DEST"
		cd $destrepo && git pull
	;;
	"remove"|"rm"|"del"|"delete")
		repoAction "$2"
		destrepo="$DEST/$repo"
		[ -d "$destrepo" ] && rm -rf "$destrepo"
	;;
	"list")
		for r in $(find "$DEST/" -type d -name .git | sort)
		do
				r=${r%/.git}
				echo ${r#$DEST/}
		done
	;;
	"search")
	terms=""
	rawurlencode "${@:2}" terms

	curl -s \
	-H "Authorization: token $github_oauth" \
	-H "User-Agent: hub-get cli (dev/test)" \
	"$GH/legacy/repos/search/$terms" \
	| $HERE/json/JSON.sh \
	| awk -f $HERE/json-parse.awk
	;;

	"configure"|"config")
		configVar "$2" "$3"
	;;

	*)
		usage
	;;
esac

repo="$2"
[ -z "$repo" ] && usage



