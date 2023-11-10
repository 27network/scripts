#!/bin/bash

# Installs Rust & ugdb

# Fetch util functions
rm -rf /tmp/utils.sh
curl --proto '=https' --tlsv1.2 -sSf https://scripts.xtrm.me/_utils.sh -o /tmp/utils.sh
source /tmp/utils.sh

wexit() {
	# noop
	info "Exiting with code $1"
}

# Ensure rust is installed
rm -rf /tmp/rust.sh
curl --proto '=https' --tlsv1.2 -sSf https://scripts.xtrm.me/rust.sh -o /tmp/rust.sh
source /tmp/rust.sh

# Install ugdb
cargo install ugdb
success "Done!"
