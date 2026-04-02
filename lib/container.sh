#!/usr/bin/env bash
# lib/container.sh — Podman image build and run helpers
# Requires: lib/config.sh, lib/ui.sh

BANDIT_IMAGE="${BANDIT_IMAGE:-localhost/bandit:latest}"

# container_image_exists — returns 0 if the image is already built
container_image_exists() {
    podman image exists "$BANDIT_IMAGE" 2>/dev/null
}

# container_build — build the image from the Containerfile in SCRIPT_DIR
container_build() {
    ui_info "Building container image ${BOLD}${BANDIT_IMAGE}${RESET}..."
    podman build -t "$BANDIT_IMAGE" -f "$SCRIPT_DIR/Containerfile" "$SCRIPT_DIR"
    ui_success "Image built successfully."
}

# container_ensure_built — build only if the image doesn't exist yet
container_ensure_built() {
    if ! container_image_exists; then
        ui_warn "Container image not found. Building now (this may take a minute)..."
        container_build
    fi
}

# container_run [extra_podman_args...] -- <cmd> [cmd_args...]
# Runs a command inside the container with standard flags.
# If stdin is a tty, passes -it; otherwise just -i.
#
# Environment variables forwarded into the container:
#   SSHPASS  — used by lib/ssh.sh to pass passwords without exposing them
#              in process listings
container_run() {
    config_init  # ensure data dir and files exist before mounting

    local tty_flags=()
    if [[ -t 0 ]]; then
        tty_flags=(-it)
    else
        tty_flags=(-i)
    fi

    # Build the env-forward args array; only include SSHPASS if it's set
    local env_args=()
    if [[ -n "${SSHPASS:-}" ]]; then
        env_args=(--env "SSHPASS=${SSHPASS}")
    fi

    podman run --rm \
        "${tty_flags[@]}" \
        --userns=keep-id \
        -v "${BANDIT_DATA_DIR}:/home/player/.bandit:z" \
        -v "${BANDIT_KNOWN_HOSTS}:/home/player/.ssh/known_hosts:z" \
        "${env_args[@]}" \
        "$BANDIT_IMAGE" \
        "$@"
}
