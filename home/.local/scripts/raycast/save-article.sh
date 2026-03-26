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

export PATH="$HOME/.local/scripts:$HOME/.local/bin:$HOME/.nvm/versions/node/$(ls "$HOME/.nvm/versions/node/" | sort -V | tail -1)/bin:$PATH"

url="${1:-$(pbpaste)}"

if [[ -z "$url" || "$url" != http* ]]; then
	echo "No valid URL provided or on clipboard"
	exit 1
fi

result=$(save-article "$url" 2>/dev/null)
if [[ $? -eq 0 ]]; then
	echo "Saved: $(basename "$result")"
else
	echo "Failed to save article"
fi
