#!/bin/bash
# bash completion for hub-get

_hubget_dirs() {
	local _outvar _result d start
	_outvar=$1

	hubget_dir="${HOME}/github"
	CFG="$HOME/.hub-get.cfg"
	[ -f "$CFG" ] && source "$CFG"
	_result=""
	start="${hubget_dir%/}/"

	[ -d "${start}" ] && {
		for d in $(find "$start" -maxdepth 3 -type d -name .git)
		do
				d=${d#$start}
				d=${d%/.git}
				[ -z "$d" ] || _result="$_result $d"
		done
	}
	_result=${_result# }
	eval "$1=\"$_result\""
}

_hubget_users() {
	local _outvar _result d start
	_outvar=$1

	hubget_dir="${HOME}/github"
	CFG="$HOME/.hub-get.cfg"
	[ -f "$CFG" ] && source "$CFG"
	_result=""
	start="${hubget_dir%/}/"

	[ -d "${start}" ] && {
		for d in $(find "$start" -maxdepth 1 -type d)
		do
				d=${d#$start}
				[ -z "$d" ] || _result="$_result $d"
		done
	}
	_result=${_result# }
	eval "$1=\"$_result\""
}

_hubget_reply() {
	COMPREPLY=($(compgen -W "$1" -- "$2"))
}

_hubget() {
	local cur prev comps
	COMPREPLY=()

	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	comps=""

	case "$prev" in
		'hub-get')
			comps="install remove upgrade list search get del delete rm pull config configure"
			_hubget_reply "$comps" "$cur"
			return 0
		;;
		remove|rm|del|delete|upgrade|pull)
			_hubget_dirs comps
			_hubget_reply "$comps" "$cur"
			return 0
		;;
		list)
			_hubget_users comps
			_hubget_reply "$comps" "$cur"
			return 0
		;;
		config|configure)
			comps="github.url tmp.dir github.oauth repo.dir"
			_hubget_reply "$comps" "$cur"
			return 0
	esac
}

complete -F _hubget hub-get
