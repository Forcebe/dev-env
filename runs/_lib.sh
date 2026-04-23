#!/usr/bin/env bash
# Shared utility library for run scripts
# Sourced by child scripts: source "$(dirname "$0")/_lib.sh"

# Inherit DRY and MANUAL_STEPS_FILE from parent `run` script
DRY="${DRY:-0}"
MANUAL_STEPS_FILE="${MANUAL_STEPS_FILE:-}"

log_section() {
	echo ""
	echo "==> $1"
}

log_step() {
	echo "  -> $1"
}

log_skip() {
	echo "  -- $1"
}

log_manual() {
	if [[ -n "$MANUAL_STEPS_FILE" ]]; then
		echo "$1" >> "$MANUAL_STEPS_FILE"
	fi
}

execute() {
	if [[ "$DRY" == "1" ]]; then
		echo "  [dry] $*"
		return
	fi
	"$@"
}

clone_or_pull() {
	local repo_url="$1"
	local target_dir="$2"
	local branch="${3:-}"

	if [[ -d "$target_dir" ]]; then
		if [[ -n "$branch" ]]; then
			log_skip "$(basename "$target_dir") already cloned, fetching $branch"
			if [[ "$DRY" == "0" ]]; then
				git -C "$target_dir" fetch --quiet
				git -C "$target_dir" checkout "$branch" --quiet
			fi
		else
			log_skip "$(basename "$target_dir") already cloned, pulling latest"
			if [[ "$DRY" == "0" ]]; then
				git -C "$target_dir" pull --quiet
			fi
		fi
	else
		log_step "Cloning $(basename "$target_dir")"
		execute git clone --quiet "$repo_url" "$target_dir"
		if [[ -n "$branch" && "$DRY" == "0" ]]; then
			git -C "$target_dir" checkout "$branch" --quiet
		fi
	fi
}

brew_install() {
	for formula in "$@"; do
		log_step "brew install $formula"
		execute brew install "$formula"
	done
}

brew_cask_install() {
	for cask in "$@"; do
		log_step "brew install --cask $cask"
		execute brew install --cask "$cask"
	done
}

# --- 1Password account helpers ---
# Shared so that runs/1password (the auth gate) and dev-env (op inject) agree
# on which account is expected for each layer.

WORK_OP_ACCOUNT="tmrw-health.1password.com"

# Resolve the 1Password account URL for the current layer.
# Work: hardcoded to the TMRW account.
# Personal: the first signed-in account in `op account list` that isn't work.
# `op account list` column order assumption: URL is column 1 (stable across 2.x).
# Echoes empty string when no match is found.
resolve_op_account() {
	if ! command -v op &>/dev/null; then
		return 0
	fi
	if [[ "$CURRENT_LAYER" == "work" ]]; then
		# Only echo if the work account is actually signed in
		op account list 2>/dev/null \
			| awk -v work="$WORK_OP_ACCOUNT" 'NR>1 && $1 == work { print $1; exit }'
	else
		op account list 2>/dev/null \
			| awk -v work="$WORK_OP_ACCOUNT" 'NR>1 && $1 != work { print $1; exit }'
	fi
}

# True when op is installed AND the layer-specific account is signed in.
op_account_ready() {
	command -v op &>/dev/null || return 1
	local account
	account=$(resolve_op_account)
	[[ -n "$account" ]]
}
