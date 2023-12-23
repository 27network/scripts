#!/bin/bash

ORG="27network"

if [ $# -lt 1 ]; then
	echo "Usage: $(basename $0) <project_name> <action>"
	return 1
fi

PROJECT_NAME=$1
if [ "$PROJECT_NAME" = "-e" ]; then
	$EDITOR $0
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

COMMON_CORE_PROJECTS=("libft" "ft_printf" "get_next_line" "born2beroot" "push_swap" "fract-ol" "fdf" "so_long" "minitalk" "pipex" "minishell" "philosophers" "inception" "netpractice" "cpp-modules" "webserv" "ft_irc" "ft_transcendence")
WORKDIR="$HOME/Work/42/common-core"
if [[ ! " ${COMMON_CORE_PROJECTS[@]} " =~ " ${PROJECT_NAME} " ]]; then
	WORKDIR="$HOME/Work/42/projects"
fi
if [ "$PROJECT_NAME" = "scripts" ]; then
	WORKDIR="$HOME/Work/42"
fi
PROJECT_DIR="$WORKDIR/$PROJECT_NAME"

function _proj_clone() {
	cd $WORKDIR
	git clone https://github.com/$ORG/$PROJECT_NAME.git --recursive
	cd $PROJECT_DIR
}

function _proj_update() {
	cd $PROJECT_DIR
	git pull 
}

function _proj_goto() {
	if [ ! -d $PROJECT_DIR ]; then
		_proj_clone
	fi
	_proj_update
}

function _proj_push() {
	cd $PROJECT_DIR
	git add .
	git commit
	git push --set-upstream origin main
}

function _proj_clean() {
	rm -rf $PROJECT_DIR
}

function _proj_create() {
	cd $WORKDIR
	gh repo create $ORG/$PROJECT_NAME --public --clone || return -1
	cd $PROJECT_DIR
	if [ ! -d $PROJECT_DIR ]; then
		echo "Error: $PROJECT_DIR not found"
		return -1
	fi
	touch README.md
	read -p "Project description: " DESCRIPTION
	echo "# $PROJECT_NAME" >> README.md
	echo "##### $DESCRIPTION" >> README.md
	read -p "Does this repo have C code? [y/n]: " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		touch Makefile #TODO: template
		touch .gitignore #TODO: template
		mkdir -p src
		mkdir -p include
		read -p "Do you want to add libft submodule? [y/n] " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			git submodule add https://github.com/$ORG/libft-neo.git libft
		fi
	fi
	_proj_push
}

function _proj_reset() {
	_proj_clean
	_proj_clone
}

ACTIONS=("goto" "update" "push" "clean" "create" "clone" "reset")

# actions:
case $ACTION in
	"goto")
		_proj_goto
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
	*)
		echo "Usage: $(basename $0) $1 <action>"
		echo "Actions: ${ACTIONS[@]}"
		return 2
		;;
esac
