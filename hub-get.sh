#!/bin/bash
#
# hub-get
# Something like apt-get or npm for github repos
#
# @author bibby <bibby@bbby.org>
# @license MIT

here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

# Configuration defaults
cfg="$here/default.cfg"
[ -f "$cfg" ] && . "$cfg"

# Load local config, if exists
cfg="/etc/hubget/hubget.cfg"
[ -f "$cfg" ] && . "$cfg"

# Load user config, if exists
[ $(id -u) -ne 0 ] && {
	hubget_repo="$HOME/github"
	cfg="$HOME/.hubget.cfg"
	[ -f "$cfg" ] && . "$cfg"
}

githubUrl=$github_url
githubApi=$github_api
appTemp=$hubget_tmp
repoDest=$hubget_repo
mkdir -p $repoDest

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
	[ -d "$appTemp" ] && rm -rf "$appTemp"
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
	hash $sscfg 2>/dev/null || sscfg=$here/sscfg/sscfg

	[ -f "$cfg" ] || {
		cp "$here/default.cfg" "$cfg"
	}

	eval "$sscfg $cfg set $1 $2"
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
			# I don't understand the "'" prepend hack, but it works
			printf -v o '%%%02x' "'${c}"
        ;;
     esac
     encoded="${encoded}${o}"
  done

  eval "$_outvar=\"${encoded}\""
}

#missing action, but $1 smells of a repo; hub-get foo/bar
if [[ -z "$2" && "$1" = */* ]] 
then
	action="install"
	repoSplit "$1"
else
	action="$1"
	repoSplit "$2"
fi

case "$action" in
	"get"|"install")
		remote="$githubUrl/$repo"
		locally="$repoDest/$repo"

		[ -d "$locally" ] && throw "$locally already exists. Did you mean 'upgrade'?"
		mkdir -p $appTemp
		cd $appTemp
		git clone "$remote"

		[ "$?" = "0" ] || {
			throw "$remote failed to clone"
		}

		destrepo="$repoDest/$ghuser"
		mkdir -p "$destrepo"
		mv "$appTemp/$ghproj" "$destrepo"

		echo "Cloned $ghproj to $destrepo"
		cleanup
	;;
	"upgrade"|"pull")
		destrepo="$repoDest/$repo"
		[ -d "$destrepo" ] || throw "repository $repo not found in $repoDest"
		cd $destrepo && git pull
	;;
	"remove"|"rm"|"del"|"delete")
		destrepo="$repoDest/$repo"
		[ -d "$destrepo" ] && rm -rf "$destrepo"
	;;
	"list")
		searchRoot="$repoDest/$ghuser"
		[ -d "$searchRoot" ] || throw "dir $searchRoot not found"
		for r in $(find "$searchRoot" -type d -name .git | awk -F "/" -f "$here/listfmt.awk" | sort)
		do
				r=${r%/.git}
				echo ${r#$repoDest/}
		done
	;;
	"search")

	[ -z "$github_oauth" ] && throw "OAuth token not set."
	terms=""
	rawurlencode "${@:2}" terms

	# legacy search can't limit?
	perPage="$search_perPage"
	[ -z "$perPage" ] && perPage=25

	paging="&perPage=$perPage&page=1"
	# no paging?
	paging=""
	requestUrl="$githubApi/search/repositories?q=$terms&sort=stars&order=desc$paging"
# echo $requestUrl; exit;

 	results="$appTemp/search-results"
	auth=""
	[ -z "$github_oauth" ] || auth="-H 'Authorization: token $github_oauth'"

	curl -s $auth \
	-H "User-Agent: hub-get cli (dev/test)" \
	-H "Accept: application/vnd.github.preview, application/json" \
	"${requestUrl}" \
	| $here/json/JSON.sh \
	| awk -f $here/github-json.awk
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
