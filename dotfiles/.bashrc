#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'		# TODO: read ~/.bash_aliases
PS1='[\u@\h \W]\$ '

[[ -f $HOME/.bash_aliases ]] && source $HOME/.bash_aliases

# PAGER="less"
# LESS="-R"
PAGER="less"
LESS="-eFMXR"

powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/share/powerline/bindings/bash/powerline.sh
source /usr/share/nvm/init-nvm.sh
