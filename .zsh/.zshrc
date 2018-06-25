# Attach to or create a tmux session if the shell is a child of xfce4-terminal
if [[ "$(ps -o 'cmd=' -p $(ps -o 'ppid=' -p $$))" == "xfce4-terminal" ]]; then
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
