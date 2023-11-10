#!/bin/bash

# coreutils but cooler :3

# Fetch util functions
curl --proto '=https' --tlsv1.2 -sSf https://scripts.xtrm.me/_utils.sh -o /tmp/utils.sh
source /tmp/utils.sh

# Ensure rust is installed
curl --proto '=https' --tlsv1.2 -sSf https://scripts.xtrm.me/rust.sh | sh -s -- -y

# Source shellrc
source "$SHELL_RC"

# Install coolutils
cargo install bat ripgrep exa fd-find

# Aliases
user "Do you want to add aliases for coolutils? [y/N] "
read -r CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
	success "alright."
	exit $SUCCESS
fi
alias_shellrc "ls" 'exa --group-directories-first --icons'
alias_shellrc "l" 'exa -laHb --group-directories-first --icons'
success "Done!"
