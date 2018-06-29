# Attach to or create a tmux session if the shell is a child of xfce4-terminal
if [[ "$(ps -o 'cmd=' -p $(ps -o 'ppid=' -p $$))" == "termite" ]]; then
    # Attach to tmux session if one exists, otherwise start one
    if tmux has-session -t $(whoami) 2>/dev/null; then
        tmux -f "$XDG_CONFIG_HOME"/tmux/tmux.conf -2 attach-session -t $(whoami)
    else
        tmux -f "$XDG_CONFIG_HOME"/tmux/tmux.conf -2 new-session -s $(whoami)
    fi
fi

# Add ~/.zsh to fpath and set agnoster as zsh prompt
fpath=( "$HOME/.zsh" $fpath )
autoload -Uz promptinit
promptinit
prompt agnoster

# Start ssh-agent
source $HOME/.zsh/ssh-agent.zsh

# Immediately write history, load new history as it is created, configure history file
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
HISTFILE=$HOME/.zsh/history
HISTSIZE=10000
SAVEHIST=5000

# Bind up/down arrows to history search from currently entered string
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

