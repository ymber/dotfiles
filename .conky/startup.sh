#!/bin/sh

conky -c $HOME/.conky/rings.conf &
conky -c $HOME/.conky/cpu.conf &
conky -c $HOME/.conky/ram.conf &
conky -c $HOME/.conky/updates.conf &
