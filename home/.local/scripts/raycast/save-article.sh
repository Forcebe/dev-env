#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Save Article
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📎
# @raycast.argument1 { "type": "text", "placeholder": "URL (leave blank for paste)", "optional": true }
# @raycast.packageName Articles

# Documentation:
# @raycast.description Save a web article to Obsidian with AI summary and tags
# @raycast.author forcebe
# @raycast.authorURL https://raycast.com/forcebe

# Raycast runs without a login shell, so nvm never initialises. Resolve the bin
# dir for nvm's *default* alias -- global npm tools (readable-cli) live there,
# not necessarily under the newest installed node.
nvm_default_bin() {
	local versions="$HOME/.nvm/versions/node" want="" dir=""
	[[ -d "$versions" ]] || return 0
	[[ -f "$HOME/.nvm/alias/default" ]] && want=$(<"$HOME/.nvm/alias/default")
	want="${want#v}"
	if [[ -n "$want" ]]; then
		dir=$(ls "$versions" | grep -E "^v${want}(\\.|$)" | sort -V | tail -1)
	fi
	[[ -z "$dir" ]] && dir=$(ls "$versions" | sort -V | tail -1)
	[[ -n "$dir" ]] && printf '%s' "$versions/$dir/bin"
}

export PATH="$HOME/.local/scripts:$HOME/.local/bin:$(nvm_default_bin):/opt/homebrew/bin:$PATH"

url="${1:-$(pbpaste)}"

if [[ -z "$url" || "$url" != http* ]]; then
	echo "No valid URL provided or on clipboard"
	exit 1
fi

err_file=$(mktemp)
result=$(save-article "$url" 2>"$err_file")
status=$?
if [[ $status -eq 0 ]]; then
	echo "Saved: $(basename "$result")"
else
	echo "Failed to save article: $(grep -v '^Summarizing' "$err_file" | tail -1)"
fi
rm -f "$err_file"
exit $status
