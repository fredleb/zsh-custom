#!/bin/bash

now=`date +%Y%m%d%H%M%S`

# Make backup copies from .zshrc
mv $HOME/.zshrc $HOME/.zshrc.$now


ANTIGEN_DIR=~/.antigen
mkdir -p $ANTIGEN_DIR

ANTIGEN=$ANTIGEN_DIR/antigen.zsh

# download antigen
if [ ! -f $ANTIGEN ]; then
	curl -L git.io/antigen > $ANTIGEN
fi

# Replace ~/.zshrc with our version
cp zshrc $HOME/.zshrc

