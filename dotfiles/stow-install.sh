#!/bin/zsh

# NOTE: may need to implement a refresh of sorts of what binaries/executables
# are on the path. This is useful in the case of removed items no longer being
# owned by stow, and not available on path anymore.

DOTFILES_DIR=${0:A:h}
. $DOTFILES_DIR/common-setups/dotfiles/stow-config.sh

for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do
  echo "stow $folder"
  stow $folder -t $HOME
  if (( $? == 1 )); then
    echo "stow failed, attempting to adopt $folder"
    stow --adopt $folder -t $HOME
  fi
done
