#!/bin/bash
#
# hub-get
# Something like apt-get or npm for github repos
#
# @author bibby <bibby@bbby.org>
# @license MIT

HERE=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

# Configuration defaults
CFG="$HERE/default.cfg"
[ -f "$CFG" ] && source "$CFG"

# Load local config, if exists
CFG="/etc/hubget/hubget.cfg"
[ -f "$CFG" ] && source "$CFG"

# Load user config, if exists
[ $EUID -ne 0 ] && {
	hubget_repo="$HOME/github"
	CFG="$HOME/.hubget.cfg"
	[ -f "$CFG" ] && source "$CFG"
}

GH=$github_url
TMP=$hubget_tmp
DEST=$hubget_repo
mkdir -p $DEST

usage() {
	cat <<EOM
hub-get - github "package" manager
	hub-get <action> <repo>"
	echo "actions: get remove upgrade list"
	echo "repo: username/project,  ie bibby/hub-get"
EOM
	exit
}

cleanup() {
	# cause for concern?
	[ -d "$TMP" ] && rm -rf "$TMP"
}

throw() {
	echo "Err! $1" >&2
	cleanup
	usage
	exit 1
}

repoSplit() {
	repo="$1"
	[ -z "$repo" ] || {
		ghuser=${repo%/*}
		ghproj=${repo#*/}
	}
}

configVar() {
	local sscfg="sscfg"
	hash $sscfg 2>/dev/null || sscfg=$HERE/sscfg/sscfg

	[ -f "$CFG" ] || {
		cp "$HERE/default.cfg" "$CFG"
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
repoSplit "$2"
case "$action" in
	"get"|"install")
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
		destrepo="$DEST/$repo"
		[ -d "$destrepo" ] || throw "repository $repo not found in $DEST"
		cd $destrepo && git pull
	;;
	"remove"|"rm"|"del"|"delete")
		destrepo="$DEST/$repo"
		[ -d "$destrepo" ] && rm -rf "$destrepo"
	;;
	"list")
		searchRoot="$DEST/$ghuser"
		[ -d "$searchRoot" ] || throw "dir $searchRoot not found"
		for r in $(find "$searchRoot" -type d -name .git | sort)
		do
				r=${r%/.git}
				echo ${r#$DEST/}
		done
	;;
	"search")

	[ -z "$github_oauth" ] && throw "OAuth token not set."
	terms=""
	rawurlencode "${@:2}" terms

	# legacy search can't limit?
	perPage="$search_perPage"
	[ -z "perPage" ] && perPage=25

	curl -s \
	-H "Authorization: token $github_oauth" \
	-H "User-Agent: hub-get cli (dev/test)" \
	"$GH/legacy/repos/search/$terms" \
	| $HERE/json/JSON.sh \
	| awk -f $HERE/github-json.awk
	;;

	"configure"|"config")
		prop=""
		case "$2" in
			"github.oauth"|"github.url")
				prop=${2/\./_}
			;;

			"tmp.dir"|"repo.dir")
				prop="hubget_${2%.*}"
			;;
		esac

		[ -z "$prop" ] && throw "unknown option '$2'"
		configVar "$prop" "$3"
	;;

	*)
		usage
	;;
esac
