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
