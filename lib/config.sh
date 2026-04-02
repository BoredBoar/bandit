#!/usr/bin/env bash
# lib/config.sh — Local credential and progress storage
# Data is stored under BANDIT_DATA_DIR (default: ~/.local/share/bandit/).
# Override BANDIT_DATA_DIR for testing without touching real data.

BANDIT_DATA_DIR="${BANDIT_DATA_DIR:-$HOME/.local/share/bandit}"
BANDIT_PASSWORDS_FILE="$BANDIT_DATA_DIR/passwords.json"
BANDIT_PROGRESS_FILE="$BANDIT_DATA_DIR/progress.json"
BANDIT_KNOWN_HOSTS="$BANDIT_DATA_DIR/known_hosts"

# config_init — create data directory and empty JSON files if missing
config_init() {
    mkdir -p "$BANDIT_DATA_DIR"
    chmod 700 "$BANDIT_DATA_DIR"

    if [[ ! -f "$BANDIT_PASSWORDS_FILE" ]]; then
        echo '{}' > "$BANDIT_PASSWORDS_FILE"
        chmod 600 "$BANDIT_PASSWORDS_FILE"
    fi

    if [[ ! -f "$BANDIT_PROGRESS_FILE" ]]; then
        echo '{}' > "$BANDIT_PROGRESS_FILE"
        chmod 600 "$BANDIT_PROGRESS_FILE"
    fi

    touch "$BANDIT_KNOWN_HOSTS"
    chmod 600 "$BANDIT_KNOWN_HOSTS"
}

# config_get_password <level> — print the stored password, or empty string
config_get_password() {
    local level="$1"
    if [[ ! -f "$BANDIT_PASSWORDS_FILE" ]]; then
        echo ''
        return
    fi
    jq -r --arg lvl "$level" '.[$lvl] // empty' "$BANDIT_PASSWORDS_FILE"
}

# config_set_password <level> <password> — store a level's password atomically
config_set_password() {
    local level="$1"
    local password="$2"
    config_init
    local tmp
    tmp="$(mktemp "$BANDIT_DATA_DIR/.passwords.XXXXXX")"
    jq --arg lvl "$level" --arg pw "$password" '.[$lvl] = $pw' \
        "$BANDIT_PASSWORDS_FILE" > "$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$BANDIT_PASSWORDS_FILE"
}

# config_mark_done <level> — record completion timestamp in progress.json
config_mark_done() {
    local level="$1"
    config_init
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    local tmp
    tmp="$(mktemp "$BANDIT_DATA_DIR/.progress.XXXXXX")"
    jq --arg lvl "$level" --arg ts "$timestamp" \
        '.[$lvl].completed_at = $ts' \
        "$BANDIT_PROGRESS_FILE" > "$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$BANDIT_PROGRESS_FILE"
}

# config_add_note <level> <note> — append a note to a level's progress entry
config_add_note() {
    local level="$1"
    local note="$2"
    config_init
    local tmp
    tmp="$(mktemp "$BANDIT_DATA_DIR/.progress.XXXXXX")"
    jq --arg lvl "$level" --arg note "$note" \
        '.[$lvl].note = $note' \
        "$BANDIT_PROGRESS_FILE" > "$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$BANDIT_PROGRESS_FILE"
}

# config_get_progress <level> — print the raw progress JSON object for a level
config_get_progress() {
    local level="$1"
    if [[ ! -f "$BANDIT_PROGRESS_FILE" ]]; then
        echo 'null'
        return
    fi
    jq --arg lvl "$level" '.[$lvl] // null' "$BANDIT_PROGRESS_FILE"
}
