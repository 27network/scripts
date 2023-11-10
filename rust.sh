#!/bin/bash

#
# Installs Rust in a convenient way.
#
VERSION="0.1"
AUTHOR="kiroussa"

# START Exit codes
SUCCESS=0
EXITED_PROMPT=1
ALREADY_INSTALLED=2
COULDNT_INSTALL=3
MISSING_COMMAND=4
INVALID_SHELLRC=5
# END Exit codes

# Fetch log functions
curl --proto '=https' --tlsv1.2 -sSf https://scripts.xtrm.me/_utils.sh -o /tmp/utils.sh
source /tmp/utils.sh

# CLI options
SKIP_PROMPT=0
while getopts ":hvy" opt; do
	case $opt in
		h)
			echo "Usage: $0 [-hv] [-y]"
			echo "  -y  Skip confirmation prompt(s)"
			echo "  -h  Show this help message"
			echo "  -v  Show version"
			wexit $SUCCESS
			;;
		v)
			echo "Rust Installer v$VERSION by @$AUTHOR"
			wexit $SUCCESS
			;;
		y)
			SKIP_PROMPT=1
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			wexit $MISSING_COMMAND
			;;
	esac
done

# Start
info "Rust Installer v$VERSION by @$AUTHOR"
echo ''

# Check if rust is installed
log "Checking Rust installation..."
if ! command -v cargo >/dev/null 2>&1 && ! command -v rustup >/dev/null 2>&1 && ! command -v rustc >/dev/null 2>&1; then
	info "Rust is not installed."
else
	fail "Rust already is installed, aborting..." $ALREADY_INSTALLED
fi

# Prompt the user to install rust
if [ "$SKIP_PROMPT" -eq 0 ]; then
	user "Do you want to install Rust? [Y/n] "
	read -r CONFIRM
	if [ "$CONFIRM" != "Y" ] && [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "" ]; then
		fail "Aborted." $EXITED_PROMPT
	fi
else
	info "Running with -y, skipping prompt..."
fi
info "Installing Rust..."

# Setup environment variables
log "Setting up environment variables..."
export_shellrc "CARGO_HOME" "$HOME/sgoinfre/.cargo" 
export_shellrc "RUSTUP_HOME" "$HOME/sgoinfre/.rustup" 
export_shellrc "PATH" "\$CARGO_HOME/bin:\$RUSTUP_HOME/bin:\$PATH" 

# Install rust
log "Fetching rustup-init.sh"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup-init.sh

log "Installing Rust..."
sh /tmp/rustup-init.sh -y --no-modify-path --default-toolchain stable || fail "Rustup installer returned an error, aborting..." $COULDNT_INSTALL

# Check if rust is installed
log "Checking Rust installation..."
if ! command -v cargo >/dev/null 2>&1 && ! command -v rustup >/dev/null 2>&1 && ! command -v rustc >/dev/null 2>&1; then
	fail "Couldn't install Rust, aborting..." $COULDNT_INSTALL
else
	success "Rust installed successfully!"
fi
