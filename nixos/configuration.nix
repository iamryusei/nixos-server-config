{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./impermanence.nix
  ];

  # System
  system.stateVersion = "24.11"; # DO NOT MODIFY! - Version of NixOS initial installation.

  # Virtualization (ONLY FOR QEMU / PROXMOX)
  # See: https://wiki.nixos.org/wiki/Category:Virtualization
  # virtualisation.libvirtd.enable = true;
  # services.qemuGuest.enable =true;
  # services.spice-vdagentd.enable = true;

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true; # for legacy BIOS use false
  boot.loader.grub.efiInstallAsRemovable = true; # for legacy BIOS use false
  boot.initrd.postResumeCommands = lib.mkAfter ''
    zfs rollback -r zpool/root@blank
  '';

  fileSystems."/persistence".neededForBoot = true;

  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Timezone
  time.timeZone = "Europe/Rome";
  time.hardwareClockInLocalTime = false;

  # Networking
  networking.hostId = "${hostId}";
  networking.hostName = "nixos-server";

  # Logind
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";

  # Console
  console = {
    enable = true;
    earlySetup = false;
    useXkbConfig = false;
    keyMap = "it";
    font = "Lat2-Terminus16";
    colors = [];
    packages = [];
  };


  # Docker
  # (see: https://nixos.wiki/wiki/Docker )
#  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
##  virtualisation.docker.daemon.settings = {
#  data-root = "/some-place/to-store-the-docker-data";
#  };

  # Packages
  environment.systemPackages = with pkgs; [
    gh # GitHub CLI tool
    git # Distributed version control system
    nano # Small, user-friendly console text editor
    neofetch
  ];

  # OpenSSH
  services.openssh.enable = true;
  services.openssh = {
 #   port = 22;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  users = {
    mutableUsers = false;
    enforceIdUniqueness = true;
    allowNoPasswordLogin = false;
#    defaultUserHome = "/home";
#    defaultUserShell = pkgs.bash;

    groups = {
      # todo
    };

    users = {
      "root" = {
        uid = 0;
        group = "root";
        hashedPassword = "$6$1jyu6h3.Aui/WBIn$Xv5OORdaM5mXzoSIhLzhh9t1Ev1tx5AhtobTqPRvf1/y3Av47rmznLzCl66CH/6YnZZ.KMpZI.kto7a.LtjOm.";
      };
      "leonard0" = {
        uid = 1000;
        isNormalUser = true;
        description = "Leonardo Spaccini";
        hashedPassword = "$6$1jyu6h3.Aui/WBIn$Xv5OORdaM5mXzoSIhLzhh9t1Ev1tx5AhtobTqPRvf1/y3Av47rmznLzCl66CH/6YnZZ.KMpZI.kto7a.LtjOm.";
        extraGroups = [ "wheel" ]; # Enable "sudo" for the user.
      };
    };
  };

}

