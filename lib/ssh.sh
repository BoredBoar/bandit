#!/usr/bin/env bash
# lib/ssh.sh — SSH connection logic for Bandit levels
# Requires: lib/config.sh, lib/container.sh, lib/ui.sh

BANDIT_HOST="bandit.labs.overthewire.org"
BANDIT_PORT="2220"

# ssh_connect <level> <password>
# Opens an SSH session to banditN inside the container.
# The password is passed via SSHPASS env var — never via command-line args,
# so it won't appear in `ps aux` output.
ssh_connect() {
    local level="$1"
    local password="$2"
    local user="bandit${level}"

    container_ensure_built

    # Ensure ~/.ssh dir exists inside the container mount path on the host
    mkdir -p "$(dirname "$BANDIT_KNOWN_HOSTS")"

    ui_info "Connecting as ${BOLD}${user}${RESET} to ${BANDIT_HOST}:${BANDIT_PORT} ..."
    printf "\n"

    export SSHPASS="$password"
    container_run \
        sshpass -e ssh \
            -o StrictHostKeyChecking=accept-new \
            -o UserKnownHostsFile=/home/player/.ssh/known_hosts \
            -o ServerAliveInterval=60 \
            -o ServerAliveCountMax=3 \
            -p "$BANDIT_PORT" \
            "${user}@${BANDIT_HOST}"
    unset SSHPASS

    local next_level=$(( level + 1 ))
    if [[ $next_level -lt 34 ]]; then
        printf "\n"
        ui_info "Session ended. If you found the password for level ${next_level}, save it:"
        printf "  ${BOLD}./bandit save %d <password>${RESET}\n\n" "$next_level"
    else
        printf "\n"
        ui_success "You completed the last level!"
    fi
}

# ssh_get_password <level> — look up stored password, prompt if missing
ssh_get_password() {
    local level="$1"
    local password

    # Level 0's password is publicly documented
    if [[ "$level" == "0" ]]; then
        password="$(config_get_password 0)"
        if [[ -z "$password" ]]; then
            password="bandit0"
        fi
        echo "$password"
        return
    fi

    password="$(config_get_password "$level")"
    if [[ -z "$password" ]]; then
        printf "${YELLOW}Password for level %s:${RESET} " "$level" >&2
        read -rs password </dev/tty
        printf "\n" >&2
    fi
    echo "$password"
}
