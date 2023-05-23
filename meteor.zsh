#!/usr/bin/env zsh

# Meteor Theme
# Author: Piyush Sarkar

# -----------------------------------------------------------------------------
# Prompt Configuration:
METEOR_DIRECTORY_LENGTH="4"
METEOR_DIRECTORY_COLOR="214"
METEOR_CURRENT_PATH="%${METEOR_DIRECTORY_LENGTH}~"
METEOR_TRUNCATE_GIT_DIR=false

METEOR_PROMPT_SUFFIX_SYMBOL=" $ "
METEOR_PROMPT_SUFFIX_COLOR="015"
METEOR_PROMPT_PREFIX_SYMBOL=""
METEOR_PROMPT_PREFIX_COLOR="015"

METEOR_GIT_PREFIX="⇢ "
METEOR_GIT_PREFIX_COLOR=""
METEOR_GIT_COLOR_DIRTY="red"
METEOR_GIT_COLOR_CLEAN="008"
METEOR_SHOW_GIT_STATUS_COLOR=true
METEOR_GIT_PROMPT_POSITION="RIGHT"

METEOR_SHOW_PACKAGE_MANAGER=false
METEOR_PACKAGE_MANAGER_COLOR="246"
declare -A METEOR_MAP_PACKAGE_MANAGER_NAMES
METEOR_MAP_PACKAGE_MANAGER_NAMES=(
  ["package-lock.json"]="npm"
)

METEOR_IMMEDIATE_UNSET_ASYNC=false
# -----------------------------------------------------------------------------

# autoload hooks
autoload -Uz add-zsh-hook
# Enable command substition in prompt. for using function inside prompt using single quotes (single quotes prevent immediate execution).
setopt PROMPT_SUBST 

# -----------------------------------------------------------------------------
# Functionalities
function get:git() {
  local ref=$(git symbolic-ref --short HEAD 2> /dev/null)
  if [ -n "${ref}" ]; then
    local gitstatuscolor=$METEOR_GIT_COLOR_CLEAN
    if [[ $METEOR_SHOW_GIT_STATUS_COLOR == true ]]; then
      if [ -n "$(git status --porcelain)" ]; then
        gitstatuscolor=$METEOR_GIT_COLOR_DIRTY
      else
        gitstatuscolor=$METEOR_GIT_COLOR_CLEAN
      fi
    fi
    if [ -z $METEOR_GIT_PREFIX_COLOR]; then; METEOR_GIT_PREFIX_COLOR=$gitstatuscolor; fi
    local prefix="%F{$METEOR_GIT_PREFIX_COLOR}$METEOR_GIT_PREFIX%f"
    print "%B${prefix}%F{$gitstatuscolor}${ref}%b%f"
  else
    echo ""
  fi
}

function get:package_manager() {
  if [[ $METEOR_SHOW_PACKAGE_MANAGER == true ]]; then
    local file=$(find . -maxdepth 1 -type f -iname "*.lock" -o -iname "*-lock.json" -execdir basename {} .lock ';' | head -1)
    if [[ -n $file ]]; then;
    local filename=$file
      if [[ -n $METEOR_MAP_PACKAGE_MANAGER_NAMES[$file] ]]; then
        filename=$METEOR_MAP_PACKAGE_MANAGER_NAMES[$file]
      fi
      echo "%F{$METEOR_PACKAGE_MANAGER_COLOR} [$filename]%f"
    fi
  fi
}

function truncate:git() {
  if [[ $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]; then 
    local git_root=$(git rev-parse --show-toplevel)
    if [[ -n $git_root ]]; then
      local current_dir=${PWD:A}
      METEOR_CURRENT_PATH="$git_root:t${${PWD:A}#$~~git_root}"
    fi
  fi
}
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Prompt Functions
function prompt:directory() {
  METEOR_CURRENT_PATH="%${METEOR_DIRECTORY_LENGTH}~"
  if [[ $METEOR_TRUNCATE_GIT_DIR == true ]]; then; truncate:git; fi
  print -n "%B%F{$METEOR_DIRECTORY_COLOR}${METEOR_CURRENT_PATH}%f%b"
}

function prompt:git() {
  if [[ -n $async_git_info_left && ${METEOR_GIT_PROMPT_POSITION:u} == "LEFT" ]]; then
    print -n " $async_git_info_left"
  fi
}

function prompt:package_manager() {
  if [[ -n $async_package_manager_response ]]; then
    print -n "$async_package_manager_response"
  fi
}

typeset -aHg METEOR_PROMPT_SEGMENTS=(
  prompt:directory
  prompt:package_manager
  prompt:git
)

function prompt:main() {
  print -n "%F{$METEOR_PROMPT_PREFIX_COLOR}$METEOR_PROMPT_PREFIX_SYMBOL%f"
  for prompt_segment in "${METEOR_PROMPT_SEGMENTS[@]}"; do
    [[ -n $prompt_segment ]] && $prompt_segment
  done
  print -n "%F{$METEOR_PROMPT_SUFFIX_COLOR}$METEOR_PROMPT_SUFFIX_SYMBOL%f"
}

function rprompt:main() {
  print -n $async_git_info_right
}
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Async Prompt
local async_pending=false
function async:init() {
  if [[ $async_pending == false ]]; then
    async_pending=true
    exec {FD}< <(
      echo "$(get:git)//,$(get:package_manager)" # "//," is a delimiter
    )
    zle -F $FD async:handler
  fi
}

function async:handler() {
  local arg="$(<&$1)"
  local response=("${(@s[//,])arg}")

  if [[ -n ${response[1]} ]]; then;
    if [[ ${METEOR_GIT_PROMPT_POSITION:u} == 'RIGHT' ]] then;
      async_git_info_right=${response[1]}
    else
      async_git_info_left=${response[1]}
    fi
  fi


  if [[ $METEOR_SHOW_PACKAGE_MANAGER == true && -n ${response[2]} ]]; then;
    async_package_manager_response=${response[2]}
  fi

  zle reset-prompt # Force zsh to redisplay the updated prompt.
  zle -F $1  # Unhook this callback to avoid being called repeatedly.
  exec {1}<&- # Closing the file descriptor
  async_pending=false # reset async_pending
}

function unset_async_vars() {
  unset async_git_info_left
  unset async_git_info_right
  unset async_package_manager_response
}

# -----------------------------------------------------------------------------

# Initialize prompt
function initialize() {
  # unset all async variables
  if [[ $METEOR_IMMEDIATE_UNSET_ASYNC == true ]]; then; unset_async_vars; fi

  # Show this on first paint
  PROMPT='$(prompt:main)'
  RPROMPT='$(rprompt:main)'

  # start executing async actions in background
  async:init
}
# precmd function is executed before displaying each prompt.
add-zsh-hook precmd initialize

# on change of directory, unset varibles to prevent showing wrong prompt
add-zsh-hook chpwd unset_async_vars
