#!/bin/bash

UTILS_SCRIPT="_utils.sh"
if [ ! -f "$UTILS_SCRIPT" ]; then
	echo "Couldn't find _utils.sh, aborting..."
	exit 1
fi
source "$UTILS_SCRIPT"

TO_SYMLINK=("check_untracked.sh" "push_all.sh" "pull_all.sh")
user "Do you want to symlink scripts to the parent folder? [y/n] "
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	PARENT_DIR=$(dirname "$PWD")
	for file in "${TO_SYMLINK[@]}"
	do
		if [ -f "$PARENT_DIR/$file" ]; then
			info "File $file already exists in parent directory, skipping..."
			continue
		fi
		ln -s "$PWD/$file" "$PARENT_DIR/$file" \
			|| error "Couldn't symlink $file to $PARENT_DIR" \
			&& success "Symlinked $file to $PARENT_DIR"
	done
fi

user "Do you want to setup the proj tool? [y/n] "
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	alias_shellrc proj "source $PWD/proj.sh"
fi
