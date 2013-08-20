#!/bin/bash

HERE=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

# Configuration defaultw
# These can be oveiden in hub-get.cfg
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
	echo "github-get <action> <repo>"
	echo "actions: get remove upgrade list"
	echo "repo: username/project,  ie bibby/github-get"
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
	hash $sscfg 2>/dev/null || sscfg=$HERE/sscfg

	[ -f "$CFG" ] || {
		$sscfg -c "$CFG"
		$sscfg -q "$CFG" set "github_url" "$hubget_url"
		$sscfg -q "$CFG" set "github_oauth" ""
		$sscfg -q "$CFG" set "hubget_dir" "$hubget_dir"
		$sscfg -q "$CFG" set "hubget_tmp" "$hubget_tmp"
	}
	eval "$sscfg $CFG set $1 $2"
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
		echo $GITHUB_OAUTH
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



