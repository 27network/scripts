#!/bin/bash

# coreutils but cooler :3
callback() {
	EXIT_FUNC=exit
	# Install coolutils
	cargo install bat ripgrep exa fd-find || fail "Failed to install coolutils"

	# Aliases
	user "Do you want to add aliases for coolutils? [y/N] "
	read -r CONFIRM
	if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
		success "alright."
		wexit $SUCCESS
	fi
	alias_shellrc "ls" 'exa --group-directories-first --icons'
	alias_shellrc "l" 'exa -laHb --group-directories-first --icons'
	success "Done!"
	wexit $SUCCESS
}
EXIT_FUNC=callback

# Fetch util functions
rm -rf /tmp/utils.sh
curl --proto '=https' --tlsv1.2 -sSf https://scripts.xtrm.me/_utils.sh -o /tmp/utils.sh
source /tmp/utils.sh

# Ensure rust is installed
rm -rf /tmp/rust.sh
curl --proto '=https' --tlsv1.2 -sSf https://scripts.xtrm.me/rust.sh -o /tmp/rust.sh
source /tmp/rust.sh
