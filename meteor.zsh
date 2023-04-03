# PROMPT CONFIGURATION:
METEOR_DIRECTORY_LENGTH="4"
METEOR_DIRECTORY_COLOR="214"
METEOR_CURRENT_PATH="%${METEOR_DIRECTORY_LENGTH}~"
METEOR_TRUNCATE_GIT_DIR=false

METEOR_PROMPT_SUFFIX_SYMBOL=" $ "
METEOR_PROMPT_SUFFIX_COLOR="015"
METEOR_PROMPT_PREFIX_SYMBOL=""
METEOR_PROMPT_PREFIX_COLOR="015"

METEOR_GIT_BRANCH_PREFIX="⇢ "
METEOR_GIT_COLOR="008"

METEOR_SHOW_PACKAGE_MANAGER=false
METEOR_PACKAGE_MANAGER_COLOR="246"
declare -A METEOR_MAP_PACKAGE_MANAGER_NAMES
METEOR_MAP_PACKAGE_MANAGER_NAMES=(
  ["package"]="npm"
)

# Load version control information
autoload -Uz vcs_info
precmd() {
  vcs_info
}
zstyle ':vcs_info:git:*' formats "${METEOR_GIT_BRANCH_PREFIX}%b" # Format the vcs_info_msg_0_ variable
setopt PROMPT_SUBST # To make prompt string with single quotes work properly.

# Addditional Functionalities
function truncate:git() {
  if [[ $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]; then 
    local git_root=$(git rev-parse --show-toplevel)
    if [[ -n $git_root ]]; then
      local current_dir=${PWD:A}
      METEOR_CURRENT_PATH="$git_root:t${${PWD:A}#$~~git_root}"
    fi
  fi
}

function prompt:directory() {
  if [[ $METEOR_TRUNCATE_GIT_DIR == true ]]; then; truncate:git; fi
  echo "${METEOR_CURRENT_PATH}"
}

function prompt:package_manager() {
  if [[ $METEOR_SHOW_PACKAGE_MANAGER == true ]]; then
    local file=$(find . -maxdepth 1 -type f -iname "*.lock" -execdir basename {} .lock ';' | head -1)
    if [[ -n $file ]]; then;
    local filename
      if [[ -n  $METEOR_MAP_PACKAGE_MANAGER_NAMES[$file] ]]; then
        filename=$METEOR_MAP_PACKAGE_MANAGER_NAMES[$file]
      else
        filename=$file
      fi
      echo "%F{$METEOR_PACKAGE_MANAGER_COLOR} [$filename]%f"
    fi
  fi
}

PROMPT='${METEOR_PROMPT_PREFIX_SYMBOL}%B%F{$METEOR_DIRECTORY_COLOR}$(prompt:directory)%f%b'


if [[ $METEOR_GIT_IN_MAIN_PROMPT == true ]] then;
  PROMPT+=' %B%F{$METEOR_GIT_COLOR}${vcs_info_msg_0_}%f%b'
else
  RPROMPT='%B%F{$METEOR_GIT_COLOR}${vcs_info_msg_0_}%f%b'
fi

PROMPT+='$(prompt:package_manager)%F{$METEOR_PROMPT_SUFFIX_COLOR}%b${METEOR_PROMPT_SUFFIX_SYMBOL}%f'