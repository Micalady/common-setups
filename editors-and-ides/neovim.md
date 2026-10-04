# Neovim

Some things may also whack. I may or may not fix this later with a different setup/config.

The old config used `Packer` as a package manager, but this has been abandoned for a couple of years. I've switched to `lazy.nvim` for my package management. This is nice, due to package management being mostly automated now.

`deno` and `lua` are hard requirements for some of the dependencies, but the setup should still be mostly OK without it. It just won't have the correct functionality for some of the packages.

## Note

The env var + command `NVIM_APPNAME=nvim_0.10.4 nvim` will tell neovim to look in `~/.config/nvim_0.10.4` instead of the default location, and won't persist on exit. This also changes where plugins are added/looked-for by package managers.

Also, `echo "$(cat nvim-linux-x86_64.tar.gz.sha256sum)" |  sha256sum -c` is a useful command structure if you have the sha256sum stored in a file.

```sh
# nvim-linux-x86_64.tar.gz.sha256sum
95aaa8e89473f5421114f2787c13ae0ec6e11ebbd1a13a1bd6fcf63420f8073f  nvim-linux-x86_64.tar.gz
```

## From Packer to Lazy.nvim

This should be after you install all prerequisites for neovim if needed:

* libreadline-dev or readline-devel
* lua
* luarocks
* deno
* yarn
* ripgrep
* fzf - fuzzyfinder (sorta optional?)
* build-essential (or equivalent)
* clangd (or equivalent)
  * And the libc++ or libstdc++ dev version that it uses
* Hack nerd font (or other wanted font instead)


### Windows

* Delete or move these directories to backup folder:
  * ~/AppData/Local/nvim
  * ~/AppData/Local/nvim-data
* `cp -r ~/common-setups/dotfiles/nvim/.config/nvim ~/AppData/Local`
* `nvim .`

### Linux

This was primarily done on Ubuntu distros. If you have a different distro and it's not the same, you likely know how to figure out the correct things to do anyway. Which brings up the issue of using `stow` to install dotfiles, may need some elbow grease.

* Delete or move these directories to a backup folder:
  * ~/.config/nvim 
    * NOTE: may not be necessary if the stow-install command works without issue.
  * ~/.local/share/nvim
* `cd ~/common-setups/dotfiles`
* `./stow-install.sh`
  * NOTE: may need to be reran if issues occur
* `nvim .`


## Very Important Tree-Sitter thing

Run `:TSUpdate` every now and then if tree sitter is giving you issues.

## Installs

If on Debian, or a Debian based distro you can use `sudo apt-get install neovim`, but the repo does not have latest stable. 

```sh
# Primary clipboard driver on Wayland. nvim prefers wl-copy when $WAYLAND_DISPLAY is set,
# avoiding the X11 <-> Wayland clipboard sync (stale pastes in Wayland-native terminals)
sudo apt install wl-clipboard
# Useful for yanking to system clipboard (X11, or fallback under XWayland)
sudo apt-get install xsel
# sudo apt-get install yank # ??
```

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
# curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
chmod u+x nvim.appimage
./nvim.appimage
```

If you use the shell script, add an alias to whatever rc/profile file is necessary.

OR EVEN BETTER, follow the instructions to extract the appimage, and store that where you want.

I have mine within a dir called `cust-bin`.

OR EVEN BETTERRER (not a word lol), extract from an archive for your architecture and put it in `~/bin`!

```sh
# The you shouldn't have to execute the below command if you've already curled it
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
# ./nvim.appimage

./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version

mv squashfs-root ~/cust-bin
sudo ln -s /home/$USER/cust-bin/squashfs-root/AppRun /usr/bin/nvim
nvim .
```

```sh
# Getting from archive instead
# Curl if needed, and make sure you curl for your architecture
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
# Be sure to get the correct checksum for your download! This is for a specific version!
echo "92ecb2dbdfbd0c6d79b522e07c879f7743c5d395d0a4f13b0d4f668f8565527a  nvim-linux-x86_64.tar.gz" | sha256sum -c
# If you don't have a place for raw program files, then create one. Use whatever naming convention you want.
mkdir ~/program-files # If not exists, and want this name
mkdir ~/bin # If not exists.
tar -xzvf nvim-linux-x86_64.tar.gz -C ~/program-files
# `ln` needs full pathing, so use home var
ln -s $HOME/program-files/nvim-linux-x86_64/bin/nvim $HOME/bin
```

If you need to uninstall/update it, remove the link, remove the extraction, re-curl it, extract the appimage, and re-link to `/usr/bin/nvim`. A simple `ll` or `ls -la` against `/usr/bin` should tell you what's a link and if your `nvim` is a link. (Hint: It should be if you followed these steps. If you installed it via a package manager, use that to uninstall/update nvim as you see fit)

### WSL Clipboard

* https://stackoverflow.com/questions/44480829/how-to-copy-to-clipboard-in-vim-of-bash-on-windows/61864749#61864749
* https://github.com/microsoft/WSL/issues/4440
* https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl

Refer to README.md in this dir for download.

Somewhere in your neovim init files:

`vim.opt.clipboard = "unnamedplus"`

FOR VIM:

```vim
set clipboard=unnamedplus

autocmd TextYankPost * call system('win32yank.exe -i --crlf', @")

function! Paste(mode)
    let @" = system('win32yank.exe -o --lf')
    return a:mode
endfunction

map <expr> p Paste('p')
map <expr> P Paste('P')
```

### If CLI only - fontconfig & unzip

```sh
sudo apt-get install fontconfig -y
sudo apt-get install unzip
```

Create a .fonts dir in your user dir and run the following to load new fonts:

`fc-cache -f -v`

If fonts come in a .zip file:

`unzip Target.zip -d dest_dir`

And then move all fonts to the .fonts dir and re-run the fc-cache command.

### Maybe Missing Essential: FUSE - (AppImage)

If you don't have fuse, you can't use the curl method. So use apt or install fuse. If you're not having issues, then ignore this section.

https://docs.appimage.org/user-guide/troubleshooting/fuse.html#ref-ug-troubleshooting-fuse-fuse3

`sudo apt-get install fuse libfuse2`

After installing run the following commands:

```sh
sudo addgroup fuse
sudo adduser $USER fuse
```

### Maybe Missing Essentials: c, clangd, FUSE(AppImage)

`sudo apt-get install build-essential`

If you plan on having a clang server, you may need the following as well:

`sudo apt-get install clangd --install-suggests`
OR (Likely the correct solution below):

```sh
sudo apt-get install clangd-12
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-12 100
```

```sh
# Install the standard lib, check to see what it's trying to use `clang++ --verbose`
sudo apt-get install libstdc++-13-dev # GCC 13
# AND/OR
sudo apt-get install libstdc++-14-dev # GCC 14
# AND/OR
sudo apt-get install libc++-18-dev # Clang 18
```

This solution started working after a few starts of neovim. I thought I was going to have to look into it a bit more heavily.

If not missing, skip this section.

### ripgrep

This is required for the "<leader>ps" keybinding (grep files easily)

https://github.com/BurntSushi/ripgrep#installation

Ubuntu/Debian

```sh
# Or use `sudo apt-get install ripgrep #??`
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb
sudo apt-get install ./ripgrep_14.1.1-1_amd64.deb
# sudo dpkg -i ripgrep_14.1.1-1_amd64.deb
```

### tmux

Required for the <C-f> keybinding

`sudo apt-get install tmux`

## LEGACY DO NOT USE: Package Manager (May change later)

https://github.com/wbthomason/packer.nvim

Script:

```sh
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

<!-- create pathing if not exist-->
`nvim ~/.config/nvim/lua/cragady/packer.lua`

Basic file:

```lua
-- ~/.config/nvim/lua/cragady/packer.lua
-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
end)

```

Write file, then `:so` and `:PackerSync`

## Fuzzy Finder

https://github.com/nvim-telescope/telescope.nvim

Snippet will already be in file

```lua
-- ~/.config/nvim/lua/cragady/packer.lua
-- in require func
use {
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
    -- or                            , branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
}
```

`:so`
`:PackerSync`

## Color Scheme - May Change Quickly 

https://github.com/rose-pine/neovim

## Treesitter (Maybe not explicitly needed after lazy?)

https://github.com/nvim-treesitter/nvim-treesitter

May need to install the `tree-sitter-cli`.

https://github.com/tree-sitter/tree-sitter/blob/master/cli/README.md

cargo (rust):

```sh
cargo install tree-sitter-cli
```

npm (node):

```sh
# Missing global flag? Taken from docs.
npm install tree-sitter-cli
```

## Harpoon

https://github.com/ThePrimeagen/harpoon

## Undotree

https://github.com/mbbill/undotree

## vim-fugitive

https://github.com/tpope/vim-fugitive

## LSP

Prime's vid is using the red in [this link](https://github.com/VonHeikemen/lsp-zero.nvim/commit/e7695ff341ed2144dcda9a85d8cbeaa7bc921d4e). If the LSP is feeling like it's lacking, then look into this a bit more.

## TODO Tree

<!-- TODO: test -->

Todos won't be highlighted in the MD file (at least not with my setup), but it will show up if you use the command `:TodoQuickFix`

https://github.com/folke/todo-comments.nvim

Install Requirements and download + install wanted font.

https://www.nerdfonts.com/font-downloads - Hack Nerd Font
# For windows, download CascadiaCode from https://github.com/ryanoasis/nerd-fonts/releases, and then set the terminal to use this for Ubuntu, or any other shell that needs cli icons
# copy CaskaydiaCoveNerdFont(Mono?)-* to "C:\Windows\Fonts" and they will be automatically installed
# Note, Above works with: MesloLG Nerd Font (MesloLGSNerdFont-*) and Hack (HackNerdFont-*)

(cli) `wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip -P ~/Downloads`
(cli) `unzip Hack.zip -d Hack`
(cli) `mv Hack ~/.fonts/misc`
(cli) `sudo fc-cache -f -v ~/.fonts/misc/Hack`


May need to revisit the deps for this package

