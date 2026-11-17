{ config, lib, pkgs, ... }:

{
  imports = [
    ./impermanence/nixos.nix
  ];

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      open = true;
      modesetting.enable = true;
      prime ={
        offload.enable = true;
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:2@0:0:0";
      };
    };
  };

  hardware.enableRedistributableFirmware = lib.mkDefault true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModulePackages = [ ];

  environment.persistence."/store" = {
    hideMounts = true;
    directories = [
      /var/lib/bluetooth
      /var/lib/nixos
      /var/lib/systemd
      /etc/NetworkManager/system-connections
    ];
    files = [
      /etc/machine-id
      /etc/ssh/ssh_host_ed25519_key
      /etc/ssh/ssh_host_ed25519_key.pub
      /etc/ssh/ssh_host_rsa_key
      /etc/ssh/ssh_host_rsa_key.pub
    ];
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=8G" "mode=755" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/203E-C82A";
    fsType = "vfat";
    options = [ "noatime" ];
  };

  fileSystems."/store" = {
    device = "/dev/disk/by-uuid/fb6d9ae1-6210-4f4b-9da0-7f57608482b2";
    fsType = "btrfs";
    options = [ "subvol=@store" "noatime" "compress=zstd:1" ];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/fb6d9ae1-6210-4f4b-9da0-7f57608482b2";
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" ];
  };

  fileSystems."/config" = {
    device = "/dev/disk/by-uuid/fb6d9ae1-6210-4f4b-9da0-7f57608482b2";
    fsType = "btrfs";
    options = [ "subvol=@config" "noatime" "compress=zstd:1" ];
  };

  fileSystems."/extra/Obelisk" = {
    device = "/dev/disk/by-uuid/4f43a15a-af7b-4fe7-8474-c834d1e90635";
    fsType = "ext4";
    options = [ "nofail" "noatime" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/bd8e6757-9ad0-47be-bc79-142345cebf39"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
