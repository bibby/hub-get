#!/bin/bash

_sscfg() {
	local cur prev cmds opts combined
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	cmds="set unset print reset"
	opts="-c --create -q --quiet -h --help -v --version"

	case "$prev" in
		-c|--create|*sscfg)
			COMPREPLY=( $(compgen -f -o nospace -- "${cur}"))
			return 0
		;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
			return 0
		;;
		*)
			COMPREPLY=( $(compgen -W "${cmds}" -- "${cur}"))
			return 0
		;;
	esac
}

complete -F _sscfg sscfg
