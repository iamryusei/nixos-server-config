# NixOS Installation Guide

This guide contains all the steps for a reproducible NixOS installation.

In particular, this guide refers to NixOS 24.11 (Vicuna).

## Preparation

1. Download the minimal ISO image of the latest NixOS distro from the [official link](https://nixos.org/download/#download-nixos)
or an older version from [here](https://releases.nixos.org/?prefix=nixos) 
https://github.com/nix-community/nixos-images instead.

2. Create a bootable USB drive that will be used for installation Installation with minimal installer.

3. Boot into the nixos minimal installer.

## Installation

### 1. (Optional) Switch keyboard layout to your preferred one (in my case it's Italian)

> $ sudo loadkeys it

### 2. Open a shell as root and navigate to the `/root` directory

> $ sudo -s \
> $ cd /

### 3. (Optional) WIFI
> $ ifconfig # to check the NIC \
> $ wpa_passphrase "\$YOUR_SSID" "\$YOUR_PASSWORD" > /tmp/wpa_supplicant.conf \
> $ wpa_supplicant -B -i interface_name -c /tmp/wpa_supplicant.conf

## NOT WORKING Config ssh tunnell for easier install (optional)

> $ ssh -V \
> $ nix-env -iA nixpkgs.openssh \
> $ sudo nano /etc/ssh/sshd_config \

PasswordAuthentication yes
PermitRootLogin yes

// default: PubkeyAuthentication no
// default: ListenAddress 0.0.0.0
// ERROR: READ ONLY FILESISTEM

> $ systemctl restart sshd

Login as root with no password

## Install Disko

Source - https://nixos.asia/en/nixos-install-disko

Identify wether the system is UEFI or BIOS (legacy) by checking if `/sys/firmware/efi` exists means system uses UEFI.

Identify the disk where to install the system by using `fdisk -l` and `lsblk`.

1. Retrieve the disk configuration to a temporary location, calling it "disko.nix" (we will use it later):

// TODO SOSTITUIRE CON IL DISKO.NIX DI QUESTO PROGETTO  
> $ curl https://raw.githubusercontent.com/iamryusei/nixos-config/refs/heads/master/disko.nix - /tmp/disko.nix

NANO and change /dev/sdx to target disk

> $ nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disko.nix

check if everything is ok with `df -h` `zfs list` `zpool list` `zfs list -t snapshot`should see zroot/root mounted on /mnt, and other ...

// For BIOS/MBR:
// create a /dev/sda/sd1 partition as 1GB 
// swap 16 GB
// then the rest main partition

Generate initial NixOS configuration 
With the disk partitioned, we are ready to follow the usual NixOS installation process. The first step is to generate the initial NixOS configuration under /mnt.

Before I even mount it, I create a snapshot while it is totally blank:

> $ mkdir /mnt/etc/nixos \
> $ mkdir /mnt/persistence/etc/nixos \
> $ mount --bind /mnt/persistence/etc/nixos /mnt/etc/nixos
> $ nixos-generate-config --no-filesystems --root /mnt \

now /mnt/etc/nixos should contain configuration.nix and hardware-configuration.nix

> $ cd /mnt/etc/nixos \
> $ mv /tmp/disko.nix /mnt/etc/nixos \
> $ curl https://raw.githubusercontent.com/IamRyusei/nixos-config/refs/heads/master/flake.nix -o flake.nix \
> $ curl https://raw.githubusercontent.com/IamRyusei/nixos-config/refs/heads/master/configuration.nix -o configuration.nix \
> $ curl https://raw.githubusercontent.com/IamRyusei/nixos-config/refs/heads/master/impermanence.nix -o configuration.nix \

set networking.hostId to value of -> head -c 8 /etc/machine-id

1. Let’s check that our final configuration is correct by using nix repl. In particular, we test the fileSystems set by disko:

> $ cd /mnt/etc/nixos \
> $ nix --experimental-features "nix-command flakes" flake lock

// # Start repl
> $ nix --experimental-features "nix-command flakes" repl \
> $ :lf. \
> $ outputs.nixosConfigurations.nixos.config.fileSystems \
> $ outputs.nixosConfigurations.nixos.config.fileSystems."/" \ 
> $ outputs.nixosConfigurations.nixos.config.fileSystems."/boot" \
> $ outputs.nixosConfigurations.nixos.config.fileSystems."/nix" \
> $ outputs.nixosConfigurations.nixos.config.fileSystems."/persistence" \
> $ :q

> $ cd / \
> $ nixos-install --root /mnt --flake '/mnt/etc/nixos#nixos'
> 
# NOTE: You will be prompted to set the root password at this point.

> $ shutdown now

remove drive

reboot

