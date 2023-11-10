#!/bin/bash

# Installs Rust & ugdb

# Fetch util functions
curl --proto '=https' --tlsv1.2 -sSf https://scripts.xtrm.me/_utils.sh -o /tmp/utils.sh
source /tmp/utils.sh

# Ensure rust is installed
curl --proto '=https' --tlsv1.2 -sSf https://scripts.xtrm.me/rust.sh | bash -- -y

# Source shellrc
source "$SHELL_RC"

# Install ugdb
cargo install ugdb
success "Done!"
