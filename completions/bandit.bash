#!/usr/bin/env bash
# Bash tab-completion for the bandit CLI
# Source this file or place it in /etc/bash_completion.d/bandit
# Usage: source completions/bandit.bash

_bandit_levels() {
    local levels=()
    for i in $(seq 0 33); do
        levels+=("$i")
    done
    echo "${levels[*]}"
}

_bandit_complete() {
    local cur prev words
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")

    local commands="init connect save status info note run shell reset version help"

    if [[ ${COMP_CWORD} -eq 1 ]]; then
        # Complete subcommand name
        mapfile -t COMPREPLY < <(compgen -W "$commands" -- "$cur")
        return
    fi

    # Complete level numbers for level-taking subcommands
    case "${words[1]}" in
        connect|info|note)
            if [[ ${COMP_CWORD} -eq 2 ]]; then
                mapfile -t COMPREPLY < <(compgen -W "$(_bandit_levels)" -- "$cur")
            fi
            ;;
        save)
            if [[ ${COMP_CWORD} -eq 2 ]]; then
                mapfile -t COMPREPLY < <(compgen -W "$(_bandit_levels)" -- "$cur")
            fi
            # 3rd arg is the password — don't suggest anything
            ;;
        run)
            # Fall back to default filename completion for arbitrary commands
            mapfile -t COMPREPLY < <(compgen -c -- "$cur")
            ;;
    esac
}

complete -F _bandit_complete bandit
