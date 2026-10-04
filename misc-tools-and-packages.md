# Overview

This will be a dump of fun packages & tools to install and maybe play around with.

### Idea: Move to NixOS

Keeping this file in sync with what's actually installed is manual upkeep that
keeps falling behind. NixOS does this natively: packages and config are declared
in files, so the declaration *is* the record of what's installed.

Test drive before hopping: install Nix + [home-manager](https://github.com/nix-community/home-manager)
on the current distro. It manages user-level packages and dotfiles declaratively
without touching the system packages.

```sh
# Install Nix (multi-user, from https://nixos.org/download)
sh <(curl -L https://nixos.org/nix/install) --daemon
# Then follow the home-manager standalone install for your nixpkgs channel:
# https://nix-community.github.io/home-manager/#sec-install-standalone
```

Then declare tools in `~/.config/home-manager/home.nix`, e.g.:

```nix
home.packages = with pkgs; [ wl-clipboard xclip xsel ripgrep fd fzf ];
```

and apply with `home-manager switch`. If the declarative workflow sticks, most
of `home.nix` carries straight over to a NixOS install.

Full migration notes (hardware, drivers, printers, desktops, local builds, how
each current program maps over): `ZZ.OTHER-OSs/nixos/README.md`.

## Temperature

* `sudo apt-get install lm-sensors`
* `# sudo apt-get install hddtemp`
  * Not on version, use `apt-cache search hddtmep` to find alternative
  * OR:
    * As an alternative to hddtemp, use the following to load the module
    * sudo modprobe -v drivetemp
    * sensors
  * `# sudo apt install smartmontools # if wanted`
  * `gnome-disks`
* `sudo apt install nvme-cli`

### lm-sensors

```sh
sudo sensors-detect # answer defaults
sudo service kmod start
```

### nvme-cli

```sh
# get Node
sudo nvme list
# log
sudo nvme smart-log <Node>
```

## Usage:
sensors

```sh
# As an alternative to hddtemp, use the following to load the module
sudo modprobe -v drivetemp
# then execute sensors
sensors
```

## Tree

`sudo apt-get install tree`

## Hex Editors / Dumpers

xxd and hexdump are useful; hexdump can be piped into xxd.

* `sudo apt-get hexedit`

* bless
* DHEX
* wxHexEditor
* ghex
* okteta

### Vim/Neovim

* `:%!xxd` switches to hex mode
* `:%!xxd -r` exits hex mode

### Useful Related Items

* xxd
* hexdump
* objdump
  * `objdump -Slx main.exe > main.asm`
  * Read man pages to use effectively

### Links

https://itsfoss.com/hex-editors-linux/
https://stackoverflow.com/questions/5498197/need-a-good-hex-editor-for-linux
https://en.wikipedia.org/wiki/Comparison_of_hex_editors

## Memory

* https://github.com/cheat-engine/cheat-engine (WINDOWS)
* https://github.com/korcankaraokcu/PINCE
* https://github.com/scanmem/scanmem
  * `sudo apt-get install scanmem`

## CPU Emulation+

GCC may not cut it here, May want clang:

`sudo apt-get install clang lld`

### Unicorn

[Unicorn](https://github.com/unicorn-engine/unicorn)
Compile. Reqs:
  * `sudo apt install cmake pkg-config`

```sh
git clone git@github.com:unicorn-engine/unicorn.git
cd unicorn
mkdir build; cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
```

Use libs & executables how they should be used.

### qemu
[qemu](https://www.qemu.org/download/#linux)

* Emulating Full System: `apt-get install qemu-system`
* Emulating Linux binaries: `apt-get install qemu-user-static`

## Virtualization

### Virtual Machine Manager

Interacts w/qemu

`sudo apt-get install virt-manager`

### Wine

Windows compatibility layer (not an emulator).

The distro package is fine for casual use:

`sudo apt-get install wine`

For a source build with a 32-bit Unix side (needed for 32-bit Windows apps),
see [wine-from-source.md](wine-from-source.md). That path pulls in ~400 `:i386`
`-dev` packages and hits two Multi-Arch packaging bugs -- see
[enhancements_and_fixes/multiarch_dev_file_conflicts.md](enhancements_and_fixes/multiarch_dev_file_conflicts.md).
    
### Virtual Box (Oracle (ew, but Virtual Box is fun))

Just follow the current steps for the wanted platform at: https://www.virtualbox.org/wiki/Linux_Downloads

## FZF, CLI Fuzzy Finder

[GitHub](https://github.com/junegunn/fzf)

`sudo apt-get install fzf`

## cheat.sh

[GitHub(https://github.com/chubin/cheat.sh)
[Site](https://cht.sh)
[Site](https://cheat.sh)

Can Curl against, or host locally.

## stow

Local package manager

`sudo apt-get install stow`

## fd-find (fd)

[GitHub](https://github.com/sharkdp/fd)

Alternative to find. Lighter and faster, but doesn't support as much functionality.

Binary is called `fdfind` instead of `fd` on other systems. `fd` is already reserved for another package.

`sudo apt-get install fd-find`

## xfce4-terminal

`sudo apt-get install xfce4-terminal`

## tilix

Terminal emulator w/tiling.

`sudo apt-get install tilix`

## gnome-multi-writer

Bootable USBs (Debian)

Can also use `gnome-disk-utility`

`sudo apt-get install gnome-multi-writer`

## neofetch

`sudo apt-get install neofetch`

Shows some linux, distro, & computer specs.

## Clamav

Antivirus/Scanner

`sudo apt-get install clamav`

## tcsh

Just a shell

`sudo apt-get install tcsh`

## Stopwatch

`sudo apt-get install stopwatch`

## Subversion

`svn`, source control software.

`sudo apt-get install subversion`

## GIMP

`sudo apt-get install gimp`

## Webp

`sudo apt-get install webp`

## Shotcut

[GitHub Repo](https://github.com/mltframework/shotcut)
[Download](https://www.shotcut.org/download/)

## FontForge

[GitHub Repo](https://github.com/fontforge/fontforge?tab=License-1-ov-file)
[Site](https://fontforge.org/en-US/)

### Ubuntu Install

`sudo apt-get install fontforge`

### Windows Download

[Download](https://fontforge.org/en-US/downloads/windows/)

## xclip

`sudo apt-get install xclip`

## xsel

`sudo apt-get install xsel`

## wl-clipboard

Native Wayland clipboard (`wl-copy` / `wl-paste`). Preferred over `xclip`/`xsel`
in a Wayland session; nvim and the `copy` alias in `.zshrc` use it when present.

`sudo apt install wl-clipboard`

## Deno

```c
// Todo: Move to appropriate location eventually
```

`curl -fsSL https://deno.land/install.sh | sh`

Windows:
`choco install deno`

## Task

https://taskfile.dev

https://github.com/go-task/task

https://taskfile.dev/docs/installation

Modern task runner inspired by Make.

Cross-platform build tool.

```sh
curl -1sLf 'https://dl.cloudsmith.io/public/task/task/setup.deb.sh' | sudo -E bash
sudo apt-get install task
```

## Homebrew

https://github.com/homebrew

https://brew.sh

Alternative package manager, may conflict with other package managers.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Some Network Tools

```sh
sudo apt-get install nmap wireshark net-tools
```

## Libinput Tools

```sh
sudo apt-get install libinput-tools
```

## KiCad

https://www.kicad.org/download/linux

```sh
sudo add-apt-repository ppa:kicad/kicad-9.0-releases
sudo apt-get update
sudo apt-get install kicad
```

## Docker

https://github.com/docker
https://docs.docker.com/engine/install/ubuntu

It is recommended to follow the official install instructions for your distro to have it be accurate for current methods.


### Remove old Installations

```bash
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
```

### Set Up Docker's Apt Repository

```bash
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
```

### Installation and Verification

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

```bash
sudo systemctl status docker

# If Docker is not Running, then start it

sudo systemctl start docker

# Verify a Successful Run

sudo docker run hello-world
```

### Post-install

Add a new group, if necessary, and add your user to the group to run docker without sudo. If this isn't wanted, then skip.

```bash
# You can check if exists if you want, command will fail if exists
sudo groupadd docker

# Add User
sudo usermod -aG docker $USER

# Make sure group memberships are re-evaluated
## Log out and log back in, or restart machine
## Can run the following command to activate changes to groups:
newgrp docker

# Verify
dockerrun hello-world
```

## Bruno

An open sourced alternative to Postman.

```bash
sudo mkdir -p /etc/apt/keyrings
sudo apt update && sudo apt install gpg curl
curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9FA6017ECABE0266" \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/bruno.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/bruno.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/bruno.gpg] http://debian.usebruno.com/ bruno stable" \
  | sudo tee /etc/apt/sources.list.d/bruno.list
sudo apt update && sudo apt install bruno
```

## Android Debug Tools

```bash
sudo apt-get install adb fastboot
```

## htop

```bash
sdo apt-get install htop
```

## pnpm

Good alt to `npm`.

https://pnpm.io/installation

May need a pre-req:

```sh
sudo apt-get install -y libatomic1
```

```sh
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

## ack

```sh
sudo apt install -y ack-grep
# alias ack-grep to agrep
```

## silversearcher-ag

```sh
sudo apt install -y silversearcher-ag
# ag 'pattern'
# alias ag to aggrep
```

## ripgrep

### Quick Note

This is likely the main grep prog that you want. ripgrep has better performance than the others. This automatically respects the following:

* `.gitignore`
* `.ignore`
* `.rgignore`

You can ignore the ignore files as well with the `u` and `--no-ignore` flags, or other flags:

```sh
rg -uuu 'pattern'
# rg -uuu ==~ grep -Pr -a
# rg -uu --binary --max-depth 1 ==~ grep -P
# grep -P is better than egrep (grep -E)
# OR
rg --no-ignore 'pattern'
```

`-u` has different levels of ignoring:

* `-u` - like `--no-ignore`
* `-uu` - like the previous but with the `-./--hidden` flag.
* `-uuu` - like the previous but with the `--binary` flag.

`--no-ignore` implies the following flags:

* `--no-ignore`
* `--no-ignore-dot` - (this ignores ignore rules, it doesn't search hidden files)
* `--no-ignore-exclude`
* `--no-ignore-global`
* `--no-ignore-parent`
* `--no-ignore-vcs`

Misc flags:

* `-P, --pcre2` - Adds items back that grep's `-P` supports. `rg` had disabled some items by default like lookarounds, backreferences, etc.
* `-./--hidden` - searches hidden files
* `--binary` - searches binary files

### Installation / Misc

```sh
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb
sudo apt-get install ./ripgrep_14.1.1-1_amd64.deb
# sudo dpkg -i ripgrep_14.1.1-1_amd64.deb # can still add to apt with 'apt install' if dpkg was used accidentally
# NOTE: OR
sudo apt install ripgrep

# rg 'pattern'
# alias rg to rrgrep
```

## smartmontools

```sh
sudo apt install smartmontools

# Gives `smartctl` & `smartd daemon`
```

## warp-cli (Cloudflare WARP Zero Trust)

Can now also just download a deb package and install that way w/apt.

```sh
sudo apt install ./<cloudflare apt package name>.deb
```

### Repo Instructions

```sh
# Add cloudflare gpg key
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg


# Add this repo to your apt repositories
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

# NOTE: can target a prev version if your lsb_release version is too high (as was the case in another instance on another machine)
# echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ noble main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list


# Install
sudo apt-get update && sudo apt-get install cloudflare-warp
```

## flatpak

```sh
sudo apt install flatpak

# NOTE: IF gui is wanted:
sudo apt install gnome-software-plugin-flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

```

## NTFS

```sh
sudo apt-get install ntfs-3g
```

## fpart

```sh
sudo apt install fpart
```
