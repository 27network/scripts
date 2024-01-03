#!/bin/bash

#TODO: add support for multiple orgs
#TODO: add support for configurable workdirs
#TODO: add config var for host service
#TODO: add templates
#TODO: add qit-commit support

ORG="27network"

FOLDER=$(dirname $(realpath $0))
if [ -f $FOLDER/_utils.sh ]; then
	source $FOLDER/_utils.sh
else
	echo "Error: _utils.sh not found"
	echo "Please update your scripts repo: https://github.com/$ORG/scripts"
	return 1
fi

function _read_prompt() {
	_PROMPT="$1"
	_DEFAULT="$2"
	_DEFAULT_PROMPT="$3"
	if [ -z "$_DEFAULT" ]; then
		_DEFAULT="Y"
		_DEFAULT_PROMPT="(Y/n) "
	fi
	user "$_PROMPT $_DEFAULT_PROMPT"
	if [[ "$SHELL" =~ "zsh" ]]; then
		read -rk 1
	else
		read -n 1
	fi
	# check if user pressed enter
	if [ -z "$REPLY" ]; then
		REPLY="$_DEFAULT"
	else
		echo
	fi
}

SCRIPT_NAME=$(basename $0)
if [ $# -lt 1 ]; then
	error "Usage: $SCRIPT_NAME <project_name> <action>"
	return 1
fi

PROJECT_NAME=$1
if [ "$PROJECT_NAME" = "-e" ]; then
	$EDITOR $0
	return 0
fi
if [ "$PROJECT_NAME" = "-u" ]; then
	_CURRENT="$PWD"
	cd $(dirname $(realpath $0))
	git pull
	git add $SCRIPT_NAME 
	git commit -sm "Update $SCRIPT_NAME"
	git push
	cd $_CURRENT
	return 0
fi

ACTIONS=("edit" "run" "goto" "update" "push" "clean" "create" "clone" "reset" "delete")
if [ "$PROJECT_NAME" = "-h" ]; then
	echo "Usage: $SCRIPT_NAME <project_name> <action>"
	echo "Actions: ${ACTIONS[@]}"
	return 0
fi

if [ "$PROJECT_NAME" = "." ]; then
	PROJECT_NAME=$(basename $(pwd))
fi
ACTION=$2

if [ $# -lt 2 ]; then
	ACTION="goto"
fi
ACTION=$(echo $ACTION | tr '[:upper:]' '[:lower:]')

WORKDIR="$HOME/Work/42/common-core"
if [[ ! " ${COMMON_CORE_PROJECTS[@]} " =~ " ${PROJECT_NAME} " ]]; then
	WORKDIR="$HOME/Work/42/projects"
fi
if [ "$PROJECT_NAME" = "scripts" ]; then
	WORKDIR="$HOME/Work/42"
fi
PROJECT_DIR="$WORKDIR/$PROJECT_NAME"

function _proj_clone() {
	git ls-remote https://github.com/$ORG/$PROJECT_NAME.git > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		error "Error: https://github.com/$ORG/$PROJECT_NAME not found"
		info "Maybe try: $SCRIPT_NAME $PROJECT_NAME create"
		return -1
	fi
	cd $WORKDIR
	git clone https://github.com/$ORG/$PROJECT_NAME.git --recursive
	cd $PROJECT_DIR
}

function _proj_update() {
	if [ ! -d $PROJECT_DIR ]; then
		error "Error: $PROJECT_DIR not found"
		info "Maybe try: $SCRIPT_NAME $PROJECT_NAME clone"
		return -1
	fi
	cd $PROJECT_DIR
	git pull 
}

function _proj_goto() {
	if [ ! -d $PROJECT_DIR ]; then
		_proj_clone
		if [ $? -ne 0 ]; then
			return -1
		fi
	fi
	_proj_update
}

function _proj_push() {
	COMMIT_MSG="$1"
	if [ -z "$COMMIT_MSG" ]; then
		user "Commit message: "
		read COMMIT_MSG
	fi
	cd $PROJECT_DIR
	git add .
	git commit -sm "$COMMIT_MSG"
	git push --set-upstream origin main
}

function _proj_clean() {
	if [ ! -d $PROJECT_DIR ]; then
		warn "$PROJECT_DIR not found, doing nothing."
		return -1
	fi
	rm -rf $PROJECT_DIR
}

function _proj_create() {
	info "Trying to create project '$PROJECT_NAME'..."
	if [ -d $PROJECT_DIR ]; then
		error "Error: $PROJECT_DIR already exists"
		info "Did you mean: $SCRIPT_NAME $PROJECT_NAME goto"
		return -1
	fi
	git ls-remote https://github.com/$ORG/$PROJECT_NAME.git > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		error "Error: https://github.com/$ORG/$PROJECT_NAME already exists"
		info "Did you mean: $SCRIPT_NAME $PROJECT_NAME clone"
		return -1
	fi
	cd $WORKDIR
	gh repo create $ORG/$PROJECT_NAME --public --clone || return -1
	cd $PROJECT_DIR
	if [ ! -d $PROJECT_DIR ]; then
		echo "Error: $PROJECT_DIR not found"
		return -1
	fi
	touch README.md
	user "Project description: "
	read DESCRIPTION
	echo "# $PROJECT_NAME" >> README.md
	echo "##### $DESCRIPTION" >> README.md
	_read_prompt "Does this repo have C code?" "Y" "(Y/n) "
	C_CODE=1
	if [[ $REPLY =~ ^[Nn]$ ]]; then
		C_CODE=0
	fi
	if [ $C_CODE -eq 1 ]; then
		touch Makefile #TODO: template
		touch .gitignore #TODO: template
		mkdir -p src
		mkdir -p include
		_read_prompt "Do you want to add libft submodule?" "Y" "(Y/n) "
		LIBFT=1
		if [[ $REPLY =~ ^[Nn]$ ]]; then
			LIBFT=0
		fi
		if [ $LIBFT -eq 1 ]; then
			git submodule add https://github.com/$ORG/libft.git libft
		fi
	fi
	_proj_push "Initial commit"
}

function _proj_reset() {
	_proj_clean
	_proj_clone
}

function _proj_delete() {
	_read_prompt "Are you sure you want to delete $PROJECT_NAME and its remote repository?" "N" "(y/N) "
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		user "If you're so sure then type the alphabet: "
		read ALPH
		if [[ "$ALPH" = "abcdefghijklmnopqrstuvwxyz" ]]; then
			TMP_BACKUP="${TMP:-/tmp}/$PROJECT_NAME"
			rm -rf $TMP_BACKUP
			mkdir -p $TMP_BACKUP
			mv $PROJECT_DIR $TMP_BACKUP
			gh repo delete $ORG/$PROJECT_NAME --yes
			rm -rf $PROJECT_DIR
		fi
	fi
}

# actions:
case $ACTION in
	"goto")
		_proj_goto
		;;
	"edit")
		cd $PROJECT_DIR
		$EDITOR $PROJECT_DIR
		;;
	"run")
		_SAVE="$PWD"
		cd $PROJECT_DIR
		ARGS="${@:3}"
		if [ -z "$ARGS" ]; then
			ARGS="all"
		fi
		$SHELL -c "$ARGS" || error "Exec failed"
		cd $_SAVE
		;;
	"update")
		_proj_update
		;;
	"push")
		_proj_push
		;;
	"clean")
		_proj_clean
		;;
	"create")
		_proj_create
		;;
	"clone")
		_proj_clone
		;;
	"reset")
		_proj_reset
		;;
	"delete")
		_proj_delete
		;;
	*)
		echo "Usage: $(basename $0) $1 <action>"
		echo "Actions: ${ACTIONS[@]}"
		return 2
		;;
esac
