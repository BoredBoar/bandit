#compdef bandit
# Zsh tab-completion for the bandit CLI
# Place in a directory on your $fpath, or source directly:
#   source completions/bandit.zsh

_bandit_levels() {
    local -a levels
    for i in {0..33}; do
        levels+=("$i")
    done
    echo "${levels[@]}"
}

_bandit() {
    local state

    _arguments \
        '1: :->command' \
        '*: :->args'

    case $state in
        command)
            local -a commands
            commands=(
                'init:Build the container image'
                'connect:Connect to a level via SSH'
                'save:Save a level password locally'
                'status:Show progress across all levels'
                'info:Show stored info for a level'
                'note:Attach a note to a level'
                'run:Run a command inside the container'
                'shell:Open an interactive container shell'
                'reset:Wipe all locally stored data'
                'version:Print the version'
                'help:Show help text'
            )
            _describe 'bandit commands' commands
            ;;
        args)
            case ${words[2]} in
                connect|info)
                    _arguments '2:level:({0..33})'
                    ;;
                note)
                    _arguments \
                        '2:level:({0..33})' \
                        '3:note text: '
                    ;;
                save)
                    _arguments \
                        '2:level:({0..33})' \
                        '3:password: '
                    ;;
                run)
                    _arguments '*:command:_command_names'
                    ;;
            esac
            ;;
    esac
}

_bandit "$@"
