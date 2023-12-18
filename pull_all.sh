#!/bin/bash

# find all git repos
current=$(pwd)
find . -name ".git" | while read repo; do
	dir=$(dirname $repo)
	echo "Checking $dir"
	cd $dir
	git pull
	cd $current
done
