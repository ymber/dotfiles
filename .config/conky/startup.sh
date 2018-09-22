#!/bin/sh

conky -c $HOME/.config/conky/rings.conf &
conky -c $HOME/.config/conky/cpu.conf &
conky -c $HOME/.config/conky/ram.conf &
