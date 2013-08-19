#!/bin/bash

HERE=$(readlink -f ${BASH_SOURCE[0]})
CFG="$HOME/.hub-get.cfg"
[ -f "$CFG" ] && source "$CFG"

GH="https://github.com"
TMP="/tmp/github-get"

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
	exit 1
}

DEST="/opt/github"
[ $EUID -ne 0 ] && DEST="$HOME/github"
mkdir -p $DEST

action="$1"
repo="$2"
ghuser=${repo%/*}
ghproj=${repo#*/}


case "$action" in
	"get")
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
	"remove")
		destrepo="$DEST/$repo"
		[ -d "$destrepo" ] && rm -rf "$destrepo"
	;;
	"list")
		for r in $(find "$DEST/$ghuser" -type d -name .git)
		do
				r=${r%/.git}
				echo ${r#$DEST/}
		done
	;;
	"search")
		echo $GITHUB_OAUTH
	;;
	*)
		usage
	;;
esac

repo="$2"
[ -z "$repo" ] && usage



