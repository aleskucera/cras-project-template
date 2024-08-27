#!/usr/bin/env bash

# Set the default editor to Neovim (nvim)
export EDITOR='vim'

# Control how commands are saved in the history
# `ignoreboth` avoids duplicate lines and lines starting with a space
export HISTCONTROL='ignoreboth'

# Set the maximum number of commands to remember in the history
export HISTSIZE='32768'

# Set the maximum size of the history file
export HISTFILESIZE="${HISTSIZE}"

# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${yellow}"

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X'