#!/usr/bin/env sh

ZSH_SCRIPT_URL=https://raw.githubusercontent.com/piyushsarkar/zsh-meteor-theme/main/meteor.zsh
SCRIPT_DIRECTORY=.zsh/zsh-meteor-theme
FILE_NAME=meteor.zsh
SCRIPT_NAME="Meteor theme"

BOLD="$(tput bold 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
RESET="$(tput sgr0 2>/dev/null || printf '')"

info() {
  printf '%s\n' "${BOLD}${BLUE}>${RESET} $*" 
}
error() {
  printf '%s\n' "${RED}x $*${RESET}" >&2 
}
success() {
  printf '%s\n' "${GREEN}✓${RESET} $*" 
}
clear_last_printed_line() {
  printf '\033[1A\033[K' 
}
has() {
  command -v "$1" 1>/dev/null 2>&1 
}

download() {
  file_url="$1"
  destination=$HOME/$SCRIPT_DIRECTORY
  mkdir -p $destination

  if has curl; then
    cmd="curl --fail --silent --location --output $destination/$FILE_NAME $file_url"
  elif has wget; then
    cmd="wget --quiet "$file_url" -O $destination/$FILE_NAME"
  elif has fetch; then
    cmd="fetch --quiet --output=$file_url $destination/$FILE_NAME"
  else
    error "No HTTP download program (curl, wget, fetch) found, exiting…"
    return 1
  fi

  $cmd && return 0 || rc=$?
  clear_last_printed_line
  error "Command failed (exit code $rc): ${MAGENTA}${cmd}${RESET}"
  return 1
}

add_source_to_rc_file() {
  zshrc_file=$HOME/.zshrc
  if grep -q "^source ~/$SCRIPT_DIRECTORY/${FILE_NAME}$" $zshrc_file; then
    success "${SCRIPT_NAME} already set in .zshrc"
  else
    info "Adding ${SCRIPT_NAME} in .zshrc"
    echo "\nsource ~/${SCRIPT_DIRECTORY}/${FILE_NAME}" >> $zshrc_file
    clear_last_printed_line
    success "${SCRIPT_NAME} added in .zshrc"
  fi
}

# Entry Point
info "Installing ${SCRIPT_NAME}..."
if download $ZSH_SCRIPT_URL; then
  clear_last_printed_line
  success "${SCRIPT_NAME} installed successfully!"
  add_source_to_rc_file
  printf "${GREEN}Restart your terminal to see the changes${RESET}"
else
  error "Installation Failed"
fi
