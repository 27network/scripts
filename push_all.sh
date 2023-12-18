#!/bin/bash

# find all git repos
current=$(pwd)
find . -name ".git" | while read repo; do
	dir=$(dirname $repo)
	echo "Pushing $dir"
	cd $dir
	git push
	cd $current
done
