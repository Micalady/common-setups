# NixOS Migration Notes

Notes for a possible move from Kubuntu to NixOS: what carries over, what needs
rework, and how to handle each piece of the current setup. Gathered 2026-10-03.

Option names below are from memory of recent NixOS releases; verify them at
https://search.nixos.org/options before relying on them. They do get renamed
(e.g. `hardware.opengl` -> `hardware.graphics`).

## Why

`misc-tools-and-packages.md` is a manual record of what's installed, and it keeps
falling behind. On NixOS the config *is* the record: packages, services, and
dotfiles are declared in files, so nothing gets installed that the config doesn't
know about. On Ubuntu, finding locally installed stuff means diffing system dirs
against dpkg's file lists.

Openness: Ubuntu and NixOS are both fully open source. NixOS is more transparent
and under your control: every package's build recipe lives in one public repo
(`nixpkgs`) that you can read, override, or patch from your own config, and it's
community-run rather than company-led. Non-free software (NVIDIA driver, Chrome,
etc.) needs an explicit `allowUnfree`, so the config states exactly what's
proprietary. Ubuntu has Canonical's choices on top (Snap Store backend is closed
source, snaps pushed by default, Ubuntu Pro prompts).

## Test Drive First

### home-manager on the current distro

Install Nix + [home-manager](https://github.com/nix-community/home-manager)
on Ubuntu. It manages user-level packages, dotfiles, and user services
declaratively, without touching system packages. See the install snippet in
`misc-tools-and-packages.md`.

What carries over: `home.nix` moves to NixOS almost unchanged (home-manager runs
as a NixOS module there). nvim setup, shell config, CLI tools all come across.

What doesn't: anything system-level. Bootloader, kernel, drivers, desktop and
login screen, system services (Docker, printing), networking, and users go in
`configuration.nix`, written fresh at hop time. The hop is still a reinstall;
`/home` data moves the usual way.

Gotcha while test driving on Ubuntu: GPU apps installed through Nix may not find
the graphics driver (see OpenGL / Vulkan below). CLI tools are unaffected.

### Live USB for hardware

Boot the NixOS live ISO and check Wi-Fi, Bluetooth, GPU, audio, and network
discovery before installing. This is the cheap way to find out about hardware
problems.

## Hardware (this machine)

Desktop: ASUS ROG Crosshair VIII Hero. The ROG Strix laptop is also in scope; see
"ROG Strix laptop" below.

| Hardware | Current driver | NixOS |
| --- | --- | --- |
| NVIDIA RTX 2080 | NVIDIA open kernel module 595.x | `hardware.nvidia.open = true;` (Turing supports it) |
| Intel AX200 Wi-Fi | `iwlwifi` | in-kernel, needs firmware: `hardware.enableRedistributableFirmware = true;` |
| Intel AX200 Bluetooth | `btusb` | `hardware.bluetooth.enable = true;` |
| Realtek RTL8125 2.5GbE | `r8169` | in-kernel |
| Intel I211 GbE | `igb` | in-kernel |

NixOS uses the same kernel and `linux-firmware` as everyone else, so driver
support matches other distros. The difference is that it's declared instead
of installed.

### Graphics

```nix
hardware.graphics.enable = true;
hardware.graphics.enable32Bit = true;   # Steam / Wine games
services.xserver.videoDrivers = [ "nvidia" ];   # needed even on Wayland
hardware.nvidia = {
  open = true;
  modesetting.enable = true;
};
nixpkgs.config.allowUnfree = true;
```

The driver and kernel module are built together, so they can't drift out of
sync the way they sometimes do on other distros.

### Printers and network discovery

NixOS enables its firewall by default, which blocks mDNS. That alone makes
printers and other machines "invisible" if you forget it.

```nix
services.printing.enable = true;   # CUPS
services.avahi = {
  enable = true;
  nssmdns4 = true;       # resolve .local names
  openFirewall = true;   # mDNS through the firewall
};
# Discovering / being discovered by Windows machines:
services.samba-wsdd = { enable = true; openFirewall = true; };
```

Most network printers from roughly the last decade are driverless (IPP
Everywhere / AirPrint): once Avahi can see them, CUPS uses them with no driver.
Older or vendor-specific ones go in `services.printing.drivers`, e.g.
`gutenprint`, `hplip`, `brlaser`, `epson-escpr2`. Vendor drivers that only ship
as a `.deb` are harder than on Ubuntu; check nixpkgs before buying a printer.
Scanners: `hardware.sane.enable = true;` plus `sane-airscan` for network ones.

### ROG Strix laptop

The printer trouble on the Strix under Kubuntu came from its Wi-Fi chip, not the
distro. NixOS runs the same kernel drivers, so the same chip will behave the same
way. Strix models usually ship MediaTek (MT7921/MT7922) or Realtek (rtw89) Wi-Fi,
both with a history of drops and power-save bugs. Check with
`lspci -nn | grep -i network` on the laptop, or from the live USB.

What NixOS makes easier (declared, and rollback-able if it makes things worse):

```nix
boot.kernelPackages = pkgs.linuxPackages_latest;   # newest driver fixes
networking.networkmanager.wifi.powersave = false;  # power save can drop mDNS multicast
boot.extraModprobeConfig = ''
  options mt7921e disable_aspm=1
'';                                                # example quirk, MediaTek only
```

Wi-Fi power saving dropping multicast traffic is a common reason network
discovery finds printers intermittently or not at all.

The hardware fix: Strix laptops generally use a replaceable M.2 2230 Wi-Fi card.
Swapping in an Intel AX210 (cheap, `iwlwifi`, very well supported) removes the
problem on any distro.

Laptop or board-specific quirks: check
[nixos-hardware](https://github.com/NixOS/nixos-hardware) for a profile.

### Desktops

Both KDE Plasma and Hyprland are packaged, and both can be installed at once and
picked at the login screen.

```nix
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;
programs.hyprland.enable = true;
```

## OpenGL / Vulkan

On Ubuntu with Nix (test drive): Nix packages never look in `/usr/lib`, and on
NixOS they find the driver at `/run/opengl-driver`, which Ubuntu doesn't have.
So Nix-installed GPU apps can't find the host driver. Don't force it with
`LD_LIBRARY_PATH` (mixes two glibc builds). Use `nixGL` to launch them, or
home-manager's `targets.genericLinux` options (check current GPU support).

On NixOS: not an issue for nixpkgs apps once `hardware.graphics` is enabled.

## Non-Standard Filesystem Layout

NixOS has almost no `/usr`; `/usr/local` isn't on `PATH` and the linker doesn't
search it. Prebuilt binaries that expect a standard layout (dynamically linked
downloads, AppImages, pip wheels with native code) won't run as-is.

Fallbacks, lightest to heaviest:

1. `nix-ld` for prebuilt binaries (`programs.nix-ld.enable = true;`)
2. `steam-run` or `buildFHSEnv` to give a program a standard Linux layout
3. `appimage-run` for AppImages
4. Distrobox: a full Ubuntu container that shares your home directory and
   display, for anything that really refuses to cooperate

## Building Locally

`sudo make install` into system paths and `sudo pip` into system Python don't
work. Binaries compiled on Ubuntu won't carry over (they link Ubuntu's glibc);
rebuild them.

There are two ways to build locally on NixOS:

1. Quick: open a shell with the build dependencies
   (`nix-shell -p cmake pkg-config libfoo`), build, and install to `~/.local`.
   There's a catch: the binary references library paths in `/nix/store`. Nix's
   garbage collector (`nix-collect-garbage`) can delete those later, which
   silently breaks the binary. This works for experiments but not for anything
   you keep.
2. Proper: write a small package definition. For a standard autotools, CMake or
   Meson project it's often about 10 lines, because Nix runs the configure,
   build and install steps for you. Then it's declared in your config, can be
   rebuilt anytime, and is safe from garbage collection. Your own projects, like
   `maid`, would get a `flake.nix`.

Dev experience: use `direnv` + `nix-direnv` (home-manager:
`programs.direnv = { enable = true; nix-direnv.enable = true; };`). With a
`devShell` in the project's `flake.nix` and `use flake` in `.envrc`, `cd`-ing
into the repo loads the toolchain and libraries automatically. That covers most
of the day-to-day friction.

### maid

Actively developed, so it gets a `flake.nix` with a `devShell` (for working on
it) and a `package` (for installing it from the system or home config).

`ldd` on the v0.4.6 build shows it links only the C/C++ runtime (`libstdc++`,
`libgcc_s`, `libc`, `libm`), no third-party shared libraries. Packaging it
should be straightforward. Static linking is also an option via `pkgsStatic`.

`maid-lock` is currently installed to `/usr/local/sbin`; that moves into the
package too.

### LLM / AI tooling

* Ollama: dropped in favor of maid's `llama.cpp` integration. nixpkgs has
  `llama-cpp`; CUDA build via `pkgs.llama-cpp.override { cudaSupport = true; }`
  if it's used as a library/tool rather than vendored.
* No pip / uv for LLM work anymore.
* ComfyUI: run in Docker (maid needs updating to drive it in a container).
  GPU in containers on NixOS:

  ```nix
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;
  ```

  then `docker run --device nvidia.com/gpu=all ...` (CDI). This is also the
  least fragile option on NixOS, since prebuilt PyTorch/CUDA wheels are the
  classic pain point there.

## Current Programs -> NixOS

From an inventory of this machine on 2026-10-03.

| Now | On NixOS |
| --- | --- |
| nvim (tarball in `~/program-files`) | `neovim` from nixpkgs; config via home-manager |
| `wl-clipboard`, `xclip`, `xsel` | `home.packages` |
| arduino-cli (static), arduino-ide | nixpkgs (the static binary also runs as-is) |
| Go, Deno, uv, .NET, Flutter, Rust | nixpkgs / dev shells per project |
| Bruno, Brave, Chrome, KeePassXC | nixpkgs |
| Snaps: Firefox, Thunderbird, Element, Krita | nixpkgs (no snap) |
| GIMP, FontForge, KiCad, Logisim | nixpkgs |
| Docker, QEMU / virt-manager, VirtualBox | NixOS modules (`virtualisation.*`) |
| Steam | `programs.steam.enable = true;` (builds its own FHS env) |
| Custom Wine in `/usr/local` | Docker (already planned), or `wineWowPackages` |
| `/usr/bin/winetricks` (unowned) | `winetricks` from nixpkgs |
| `cloudflared`, `warp-cli` | nixpkgs |
| Oracle Java | a nixpkgs JDK |
| m68k cross gcc | `pkgsCross` |
| RMG, Unity Hub (AppImages) | nixpkgs packages, or `appimage-run` |
| Claude Code (native installer) | `claude-code` in nixpkgs (may lag releases), or `nix-ld` |
| maid | own `flake.nix` (see above) |
| Old pip tools in `~/.local/bin` (jupyter, django, flask, ...) | per-project dev shells |
| vcpkg, Android SDK, npm native deps | may hit layout issues; dev shells / `nix-ld` |
