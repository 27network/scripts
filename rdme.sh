#!/bin/bash

ORG="27network"

FOLDER=$(dirname $(realpath $0))
if [ -f $FOLDER/_utils.sh ]; then
	source $FOLDER/_utils.sh
else
	echo "Error: _utils.sh not found"
	echo "Please update your scripts repo: https://github.com/$ORG/scripts"
	return 1
fi

ARG=$1
if [ -z "$ARG" ]; then
	ARG="create"
fi

README="README.md"

function _rdme_help() {
	
}

case $ARG in
	"create")
		echo "Creating $README"
		touch $README
		echo "# $README" >> $README
		echo "Created $README"
		;;
	"edit")
		echo "Editing $README"
		vim $README
		;;
	"view")
		echo "Viewing $README"
		less $README
		;;
	"delete")
		echo "Deleting $README"
		rm $README
		;;
	*)
		echo "Invalid argument"
		;;
esac
