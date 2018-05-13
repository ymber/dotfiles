# Attach to or create a tmux session if the shell is a child of xfce4-terminal
if [[ "$(ps -o 'cmd=' -p $(ps -o 'ppid=' -p $$))" == "xfce4-terminal" ]]; then
    # Attach to tmux session if one exists, otherwise start one
    if tmux has-session -t $(whoami) 2>/dev/null; then
        tmux -2 attach-session -t $(whoami)
    else
        tmux -2 new-session -s $(whoami)
    fi
fi

# Add ~/.zmodules to fpath and set agnoster as zsh prompt
fpath=( "$HOME/.zmodules" $fpath )
autoload -Uz promptinit
promptinit
prompt agnoster

# Start ssh-agent
source $HOME/.zmodules/ssh-agent.zsh
