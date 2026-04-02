#!/usr/bin/env bash
# lib/ui.sh — Terminal output helpers
# Requires: lib/colors.sh, lib/config.sh

BANDIT_LEVEL_COUNT=34  # Bandit levels 0–33

ui_banner() {
    printf "${BLUE}${BOLD}"
    printf ' ██████╗  █████╗ ███╗   ██╗██████╗ ██╗████████╗\n'
    printf ' ██╔══██╗██╔══██╗████╗  ██║██╔══██╗██║╚══██╔══╝\n'
    printf ' ██████╔╝███████║██╔██╗ ██║██║  ██║██║   ██║   \n'
    printf ' ██╔══██╗██╔══██║██║╚██╗██║██║  ██║██║   ██║   \n'
    printf ' ██████╔╝██║  ██║██║ ╚████║██████╔╝██║   ██║   \n'
    printf ' ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝   ╚═╝   \n'
    printf "${RESET}"
    printf "${DIM} OverTheWire Bandit — Podman terminal environment${RESET}\n\n"
}

ui_info() {
    printf "${BLUE}[info]${RESET}  %s\n" "$*"
}

ui_success() {
    printf "${GREEN}[ok]${RESET}    %s\n" "$*"
}

ui_warn() {
    printf "${YELLOW}[warn]${RESET}  %s\n" "$*" >&2
}

ui_error() {
    printf "${RED}[error]${RESET} %s\n" "$*" >&2
}

# ui_confirm <prompt> — returns 0 for yes, 1 for no
ui_confirm() {
    local prompt="$1"
    local reply
    printf "${YELLOW}%s${RESET} [y/N] " "$prompt"
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# ui_status_table — render a progress table for all 34 levels
ui_status_table() {
    local completed=0
    local separator="  ─────────────────────────────────────────"

    printf "\n${BOLD}  Bandit Progress${RESET}\n"
    printf "%s\n" "$separator"

    for i in $(seq 0 $((BANDIT_LEVEL_COUNT - 1))); do
        local pw date_str status_str
        pw="$(config_get_password "$i")"
        local progress
        progress="$(config_get_progress "$i")"
        date_str="$(echo "$progress" | jq -r '.completed_at // empty' 2>/dev/null | cut -c1-10)"

        if [[ -n "$pw" ]]; then
            status_str="${GREEN}[DONE]${RESET}"
            ((completed++)) || true
        else
            status_str="${DIM}[    ]${RESET}"
        fi

        printf "  Level %02d  %b  %s\n" "$i" "$status_str" "${date_str:-}"
    done

    printf "%s\n" "$separator"
    printf "  ${BOLD}Completed: %d / %d${RESET}\n\n" "$completed" "$BANDIT_LEVEL_COUNT"
}

# ui_level_info <level> — show stored progress details for one level
ui_level_info() {
    local level="$1"
    local pw progress completed_at note

    pw="$(config_get_password "$level")"
    progress="$(config_get_progress "$level")"
    completed_at="$(echo "$progress" | jq -r '.completed_at // empty' 2>/dev/null)"
    note="$(echo "$progress" | jq -r '.note // empty' 2>/dev/null)"

    printf "\n${BOLD}  Level %s${RESET}\n" "$level"
    if [[ -n "$pw" ]]; then
        printf "  Status:    ${GREEN}Completed${RESET}\n"
        [[ -n "$completed_at" ]] && printf "  Completed: %s\n" "$completed_at"
        [[ -n "$note" ]] && printf "  Note:      %s\n" "$note"
    else
        printf "  Status:    ${DIM}Not started${RESET}\n"
    fi
    printf "\n"
}
