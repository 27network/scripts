#!/bin/bash

# Installs Rust & ugdb

callback() {
	EXIT_FUNC=exit
	# Install ugdb
	cargo install ugdb || fail "Failed to install ugdb"
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
