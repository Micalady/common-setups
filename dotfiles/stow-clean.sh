#!/usr/bin/zsh

DOTFILES_DIR=${0:A:h}
. $DOTFILES_DIR/common-setups/dotfiles/stow-config.sh

for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do
  echo "removing $folder"
  stow -D $folder
done
