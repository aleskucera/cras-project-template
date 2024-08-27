export SHELL=/usr/bin/bash

# Load the shell dotfiles:
for file in /.env/{bash_prompt,bash_exports,bash_aliases,bash_functions}.sh; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob 2>/dev/null

# Append to the Bash history file, rather than overwriting it
shopt -s histappend 2>/dev/null

# Autocorrect typos in path names when using `cd`
shopt -s cdspell 2>/dev/null

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize 2>/dev/null

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2>/dev/null
done

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# Source the ROS workspace
if [ -f "/workspace/devel/setup.bash" ]; then
    source /workspace/devel/setup.bash 2>/dev/null
elif [ -f "/opt/ros/noetic/setup.bash" ]; then
    source /opt/ros/noetic/setup.bash 2>/dev/null
fi

[ -z "$ROS_PORT" ] && export ROS_PORT=11310
[ -z "$ROS_MASTER_URI" ] && export ROS_MASTER_URI=http://localhost:$ROS_PORT