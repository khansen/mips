#!/bin/sh
SESSION=$USER

tmux -2 new-session -d -s $SESSION

tmux select-window -t $SESSION:1
tmux rename-window vim
tmux send-keys "vim lib/mips.rb" C-m

tmux new-window -t $SESSION:2 -n test
tmux send-keys "rake test"

tmux new-window -t $SESSION:3 -n git
tmux send-keys "git status"

tmux new-window -t $SESSION:4 -n irb
tmux send-keys "irb" C-m

# Set default window
tmux select-window -t $SESSION:1

# Attach to session
tmux -2 attach-session -t $SESSION
