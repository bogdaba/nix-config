# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "pl";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bork = {
    isNormalUser = true;
    description = "Borkwave";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "bork";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}


# Below be dragons
########
#{ pkgs, config, lib, ... }:
#{
#  imports = [
#    ../home.nix
#    ./hardware-configuration.nix
#  ];
#
#  ## Modules
#  modules = {
#    desktop = {
#      bspwm.enable = true;
#      apps = {
#        rofi.enable = true;
#        # godot.enable = true;
#      };
#      browsers = {
#        default = "firefox";
#        brave.enable = true;
#        firefox.enable = true;
#        qutebrowser.enable = true;
#      };
#      gaming = {
#        steam.enable = true;
#        # emulators.enable = true;
#        # emulators.psx.enable = true;
#      };
#      media = {
#        daw.enable = true;
#        documents.enable = true;
#        graphics.enable = true;
#        mpv.enable = true;
#        recording.enable = true;
#        spotify.enable = true;
#      };
#      term = {
#        default = "xst";
#        st.enable = true;
#      };
#      vm = {
#        qemu.enable = true;
#      };
#    };
#    dev = {
#      node.enable = true;
#      rust.enable = true;
#    #  python.enable = true;
#    };
#    editors = {
#      #default = "nvim";
#      #emacs.enable = true;
#      #vim.enable = true;
#    };
#    shell = {
#      #adl.enable = true;
#      #vaultwarden.enable = true;
#      direnv.enable = true;
#      git.enable    = true;
#      #gnupg.enable  = true;
#      #tmux.enable   = true;
#      zsh.enable    = true;
#    };
#    services = {
#      #ssh.enable = true;
#      #docker.enable = true;
#      # Needed occasionally to help the parental units with PC problems
#      # teamviewer.enable = true;
#    };
#    #theme.active = "alucard";
#  };
#
#
#  ## Local config
#  programs.ssh.startAgent = true;
#  services.openssh.startWhenNeeded = true;
#
#  networking.networkmanager.enable = true;
#
#
#  ## Personal backups
#  # Syncthing is a bit heavy handed for my needs, so rsync to my NAS instead.
#  systemd = {
#    services.backups = {
#      description = "Backup /usr/store to NAS";
#      wants = [ "usr-drive.mount" ];
#      path  = [ pkgs.rsync ];
#      environment = {
#        SRC_DIR  = "/usr/store";
#        DEST_DIR = "/usr/drive";
#      };
#      script = ''
#        rcp() {
#          if [[ -d "$1" && -d "$2" ]]; then
#            echo "---- BACKUPING UP $1 TO $2 ----"
#            rsync -rlptPJ --chmod=go= --delete --delete-after \
#                --exclude=lost+found/ \
#                --exclude=@eaDir/ \
#                --include=.git/ \
#                --filter=':- .gitignore' \
#                --filter=':- $XDG_CONFIG_HOME/git/ignore' \
#                "$1" "$2"
#          fi
#        }
#        rcp "$HOME/projects/" "$DEST_DIR/projects"
#        rcp "$SRC_DIR/" "$DEST_DIR"
#      '';
#      serviceConfig = {
#        Type = "oneshot";
#        Nice = 19;
#        IOSchedulingClass = "idle";
#        User = config.user.name;
#        Group = config.user.group;
#      };
#    };
#    timers.backups = {
#      wantedBy = [ "timers.target" ];
#      partOf = [ "backups.service" ];
#      timerConfig.OnCalendar = "*-*-* 00,12:00:00";
#      timerConfig.Persistent = true;
#    };
#  };
#}
#