#!/bin/bash

# cool logging functions

log() {
	printf "\r\033[1;90m.\033[0m \033[0;90m>\033[0m $1\n"
}

info() {
	printf "\r\033[1;37mi\033[0m \033[0;90m>\033[0m $1\n"
}

user() {
	printf "\r\033[1;33m?\033[0m \033[0;90m>\033[0m $1"
}

success() {
	printf "\r\033[1;32mo\033[0m \033[0;90m>\033[0m $1\n"
}

error() {
	printf "\r\033[1;31mx\033[0m \033[0;90m>\033[0m $1\n"
}

fail() {
	printf "\r\033[1;31m!\033[0m \033[0;90m>\033[0m $1\n"
	echo ''
	exit $2
}

# shell rc stuff

SHELL_RC="$HOME/.bash_profile"
if [ -f "$HOME/.bashrc" ]; then
	SHELL_RC="$HOME/.bashrc"
fi
if [ -f "$HOME/.zshrc" ]; then
	SHELL_RC="$HOME/.zshrc"
fi

append_shellrc() {
	VAR=$1
	VALUE=$2
	SKIP_VERIFY=$3
	if [ "$SKIP_VERIFY" -eq 0 ]; then
		if grep -q "$VAR" "$SHELL_RC"; then
			return
		fi
	fi
	if [ -f "$SHELL_RC" ]; then
		echo "export $VAR=\"$VALUE\"" >> "$SHELL_RC"
		source "$SHELL_RC"
		success "Added '$VAR=$VALUE' to $SHELL_RC"
	else
		fail "Couldn't find .shellrc, aborting..." $INVALID_SHELLRC
	fi
}
