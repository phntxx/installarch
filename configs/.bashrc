#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias la='ls -la --color=auto'

CYAN="\[$(tput setaf 14)\]"
RESET="\[$(tput sgr0)\]"
PS1="${CYAN}[\u@\h \W]${RESET} "
