#!/bin/zsh

DOTFILES_DIR=${0:A:h}
. $DOTFILES_DIR/common-setups/dotfiles/stow-config.sh

for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do
  echo "stow $folder"
  stod -D $folder
  stow $folder -t $HOME
  if (( $? == 1 )); then
    echo "stow failed, attempting to adopt $folder"
    stow --adopt $folder -t $HOME
  fi
done
