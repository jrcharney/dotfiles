#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'		# TODO: read ~/.bash_aliases
PS1='[\u@\h \W]\$ '

[[ -f "${HOME}/.bash_aliases" ]] && source "${HOME}/.bash_aliases"
[[ ${PS1} && -f "/usr/share/bash-completion/bash_completion" ]] && source "/usr/share/bash-completion/bash_completion"

# PAGER="less"
# LESS="-R"
export PAGER="less"
export LESS="-eFMXR"

powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
source /usr/share/powerline/bindings/bash/powerline.sh
source /usr/share/nvm/init-nvm.sh
