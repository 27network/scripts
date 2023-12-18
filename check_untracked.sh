#!/bin/bash

# find all git repos
current=$(pwd)
find . -name ".git" | while read repo; do
	dir=$(dirname $repo)
	cd $dir
	git status -s > .tmp 2>&1
	if [ -s .tmp ]; then
		contents=$(cat .tmp | wc -l)
		if [ $contents -gt 1 ]; then
			echo "Repo: $dir"
			rm -rf .tmp
			git status -s
		fi
	fi
	rm -rf .tmp
	cd $current
done
