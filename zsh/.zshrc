##
## S E T T I N G S
##
# Vi mode
bindkey -v

# Enable colors
autoload -U colors && colors

# enable colored output from ls, etc. on FreeBSD-based systems
export CLICOLOR=1

# awesome cd movements from zshkit
setopt autocd autopushd pushdminus pushdsilent pushdtohome cdablevars
DIRSTACKSIZE=5

# Enable extended globbing
setopt extendedglob

# Allow [ or ] whereever you want
unsetopt nomatch

# Allow bash style comments
setopt interactivecomments

# Setup zsh path
fpath=(
    ~/.zsh/prompt/
    $fpath)

source "/home/wolfe/.cache/wal/colors.sh"

# Set vim as default editor
export EDITOR='vim'
export VISUAL='vim'

## History
HISTFILE=$HOME/.zhistory       # enable history saving on shell exit
setopt APPEND_HISTORY          # append rather than overwrite history file.
HISTSIZE=1200                  # lines of history to maintain memory
SAVEHIST=1000                  # lines of history to maintain in history file.
setopt HIST_EXPIRE_DUPS_FIRST  # allow dups, but expire old ones when I hit HISTSIZE
setopt EXTENDED_HISTORY        # save timestamp and runtime information

# Adds case insensitivity
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
# Color completion folders
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==34=34}:${(s.:.)LS_COLORS}")';
# Kill colors
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
# Option colors
zstyle ':completion:*:options' list-colors '=^(-- *)=34'
# Highlights current option
zstyle ':completion:*' menu select

autoload -Uz compinit
compinit

# Nice auto correct prompt
setopt correct
autoload -U colors && colors
export SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r?$reset_color (Yes, No, Abort, Edit) "

# Colorify man
function man() {
    env \
	LESS_TERMCAP_mb=$(printf "\e[1;31m") \
	LESS_TERMCAP_md=$(printf "\e[1;31m") \
	LESS_TERMCAP_me=$(printf "\e[0m") \
	LESS_TERMCAP_se=$(printf "\e[0m") \
	LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
	LESS_TERMCAP_ue=$(printf "\e[0m") \
	LESS_TERMCAP_us=$(printf "\e[1;32m") \
	man "$@"
}

##
## T W E A K S
##
fancy-ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

##
## K E Y B I N D I N G S
##
bindkey '^P' up-history
bindkey '^N' down-history

# backspace and ^h working even after
# returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

# ctrl-w removed word backwards
bindkey '^w' backward-kill-word
backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '^[^?' backward-kill-dir

# ctrl-r starts searching history backward
bindkey '^r' history-incremental-search-backward

# VI MODE KEYBINDINGS (ins mode)
bindkey -M viins '^a'    beginning-of-line
bindkey -M viins '^e'    end-of-line
bindkey -M viins '^k'    kill-line
bindkey -M viins '^w'    backward-kill-word
bindkey -M viins '^u'    backward-kill-line

##
## A L I A S E S
##
# Misc
alias :q='exit'
alias less='less -R'
alias grep='grep --color=always'
alias open='xdg-open'
alias wttr='~/bin/weather'
alias ducolor='cdu -i -s -dh'
# List directory contents
alias lsa='ls -lah --color'
alias l='ls --color'
alias ll='ls -lh --color'
alias la='ls -A --color'
alias ls='ls --color'
# Push and pop directories on directory stack
alias md='mkdir -p'
alias rd=rmdir
alias d='dirs -v | head -10'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
# Emacs clients
alias e='emacs -nw'
alias et='emacsclient -t'
alias ec='emacsclient -c'

##
## P R O M P T
##
PROMPT_STATUS="\`$SMILE\`"
_newline=$'\n'
_lineup=$'\e[1A'
_linedown=$'\e[1B'

# * There are uncommitted changes.
# ? There are files git doesn't know about.
# ➚ There are commits that haven't been pushed yet.
# ☰ There are stashed files.
# ⌥ There are branches other than master.
# ® There are remote repositories other than origin configured.
source ~/.zsh/git-prompt.zsh 

function preexec() {
    echo
}
function precmd() {
    echo
    PSVAR=`git_prompt_precmd`
}

PROMPT="%F{red}%n%F{white}@%F{green}%m %F{blue}%~ ${_newline}%F{white}$ "
RPROMPT='%{${_lineup}%}%F{red}%(?..%? )%F{yellow}%v%F{white}`jobs %% 2> /dev/null | cut -d " " -f6` [`date +%H:%M:%S`]%{${_linedown}%}'
setopt promptsubst

# Delay of 0.1 seconds
export KEYTIMEOUT=1

if type fuck >/dev/null; then
    eval $(thefuck --alias)
fi
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 

# FZF custom options
if [ -f ~/.fzf.zsh ] && which tree > /dev/null 2>&1; then
    source ~/.fzf.zsh
    export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
fi

