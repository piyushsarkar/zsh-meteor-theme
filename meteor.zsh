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

PROMPT='${METEOR_PROMPT_PREFIX_SYMBOL}%B%F{$METEOR_DIRECTORY_COLOR}$(prompt:directory)%f%b'


if [[ $METEOR_GIT_IN_MAIN_PROMPT == true ]] then;
  PROMPT+=' %B%F{$METEOR_GIT_COLOR}${vcs_info_msg_0_}%f%b'
else
  RPROMPT='%B%F{$METEOR_GIT_COLOR}${vcs_info_msg_0_}%f%b'
fi

PROMPT+='%F{$METEOR_PROMPT_SUFFIX_COLOR}%b${METEOR_PROMPT_SUFFIX_SYMBOL}%f'