
# FZF for fuzzy-finding
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# NVM - load node version manager on login
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install and nvm use specified node version when .nvmrc is found
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

# util/functions
addToPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$PATH:$1
    fi
}

# keybinds
bindkey -s ^f "tmux-sessionizer\n"

# Path items
# Add my custom scripts to path
addToPath $HOME/.local/scripts
# add bin to path for claude code
addToPath $HOME/.local/bin


# Aliases
# General
alias cat='bat'
alias find='fd'
alias ll='ls -la'
alias ..='cd ..'
alias ...='cd ../..'

# Git Aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gbs='git bisect'
alias gbl='git blame -w'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbm='git branch --move'
alias gbr='git branch --remote'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcB='git checkout -B'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gclean='git clean --interactive -d'
alias gcam='git commit --all --message'
alias gcmsg='git commit --message'
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gd='git diff'
alias gdc='git diff --cached'
alias gfo='git fetch origin'
alias ghh='git help'
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms="git merge --squash"
alias gmff="git merge --ff-only"
alias gl='git pull'
alias glog='git log --oneline --graph'
alias gpr='git pull --rebase'
alias gp='git push'
alias gpd='git push --dry-run'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias grf='git reflog'
alias gstall='git stash --all'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
# use the default stash push on git 2.13 and newer
alias gsta='git stash push' \
alias gst='git status'
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtmv='git worktree move'
alias gwtrm='git worktree remove'

# NPM Aliases
# Install dependencies globally
alias npmg="npm i -g "
# Install and save to dependencies in your package.json
# npms is used by https://www.npmjs.com/package/npms
alias npmS="npm i -S "
# Install and save to dev-dependencies in your package.json
# npmd is used by https://github.com/dominictarr/npmd
alias npmD="npm i -D "
# Check package versions
alias npmV="npm -v"
# List packages
alias npmL="npm list"
# Run npm start
alias npmst="npm start"
# Run npm test
alias npmt="npm test"
# Run npm scripts
alias npmR="npm run"
# Run npm publish
alias npmP="npm publish"
# Run npm init
alias npmI="npm init"
# Run npm info
alias npmi="npm info"
# Run npm run dev
alias npmrd="npm run dev"
# Run npm run build
alias npmrb="npm run build"

# Completion
# Include Homebrew completions (must be before compinit)
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
autoload -Uz compinit && compinit

# Git-aware completions for aliases
# Expands the alias (e.g. gco -> git checkout) then delegates to _git
_git_alias_complete() {
  local -a alias_words
  alias_words=("${(z)aliases[$words[1]]}")
  words=("${alias_words[@]}" "${words[@]:1}")
  (( CURRENT += ${#alias_words} - 1 ))
  service=git _git
}

for cmd in g ga gaa gbs gbl gb gba gbd gbD gbm gbr gco gcb gcB gcp gcpa gcpc \
  gclean gcam gcmsg gc gca gd gdc gfo ghh glog gm gma gmc gms gmff gl gpr gp gpd \
  grb grba grbc grbi grbo grbs grf gstall gstaa gstc gstd gstl gstp gsta gst \
  gwt gwta gwtls gwtmv gwtrm; do
  compdef _git_alias_complete "$cmd"
done

# Function calls
# Run starship prompt
eval "$(starship init zsh)"
