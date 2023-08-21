{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # Import home-manager's NixOS module
    inputs.home-manager.nixosModules.home-manager
    
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      # Import your home-manager configuration
      bork = import ./home.nix;
    };
  };


  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      permittedInsecurePackages = [
        "python3.10-django-3.1.14"
      ];
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };


  networking.hostName = "bork-desktop";
  networking.networkmanager.enable = true;
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

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
  
  # --- Nvidia ---
  # Make sure opengl is enabled
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Option         "TripleBuffer" "True"
  # Option         "RegistryDwords" "PerfLevelSrc=0x3322; PowerMizerDefaultAC=0x1"
  # Tell Xorg to use the nvidia driver (also valid for Wayland)
  services.xserver.videoDrivers = ["nvidia"];
  #services.xserver.screenSection = ''
  #Section "Screen"
  #  Identifier     "Screen0"
  #  Device         "Device0"
  #  Monitor        "Monitor0"
  #  DefaultDepth    24
  #  Option         "Stereo" "0"
  #  Option         "nvidiaXineramaInfoOrder" "DFP-2"
  #  Option         "metamodes" "HDMI-0: nvidia-auto-select +1920+1920 {ForceCompositionPipeline=On}, DP-2: nvidia-auto-select +0+1920 {ForceCompositionPipeline=On}, DP-4: nvidia-auto-select +2304+0 {rotation=left, ForceCompositionPipeline=On}"
  #  Option         "SLI" "Off"
  #  Option         "MultiGPU" "Off"
  #  Option         "BaseMosaic" "off"
  #  SubSection     "Display"
  #      Depth       24
  #  EndSubSection
  #EndSection
  #'';

  hardware.nvidia = {
    modesetting.enable = true; # needed for most Wayland compositors.
    open = false; # Use the open source version of the kernel module
    nvidiaSettings = true; # Enable the nvidia settings menu
    # https://forums.developer.nvidia.com/t/flickering-at-the-top-of-the-screen/256447
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Optionally, you may need to select the appropriate driver version for your specific GPU. or stable
  };


  # --- Nvidia settings ---
  #
  # Open Nvidia X Server Settings.
  # In OpenGL Settings uncheck Allow Flipping.
  # In XScreen0 > X Server XVideo Settings > Sync to this display device select your monitor.
  # Force composition pipeline (not full)


  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # --- Wayland land ---
  services.xserver.displayManager.gdm.wayland = true;
  programs.xwayland.enable = true; # Whether to use XWayLand
  #environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1"; # Firefox
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # For electron

  environment.sessionVariables.LEDGER_FILE = "/home/bork/haven/vault/finance/2023.journal";
  environment.sessionVariables.PATH = "/home/bork/scripts";

  # Configure keymap in X11
  services.xserver = {
    layout = "pl";
    xkbVariant = "";
  };

  security.polkit.enable = true;

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

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
  
  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "bork";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  #home.file.".config/redshift/redshift.conf".text = ''
  #  [redshift]
  #  ; Set the day and night screen temperatures
  #  temp-day=5800
  #  temp-night=4800
  #
  #  ; Enable/Disable a smooth transition between day and night
  #  ; 0 will cause a direct change from day to night screen temperature.
  #  ; 1 will gradually increase or decrease the screen temperature
  #  transition=1
  #  
  #  ; Set the screen brightness. Default is 1.0
  #  ;brightness=0.9
  #  ; It is also possible to use different settings for day and night since version 1.8.
  #  ;brightness-day=0.7
  #  ;brightness-night=0.4
  #  ; Set the screen gamma (for all colors, or each color channel individually)
  #  gamma=0.9
  #  
  #  ;gamma=0.8:0.7:0.8
  #  ; Set the location-provider: 'geoclue', 'gnome-clock', 'manual'
  #  ; type 'redshift -l list' to see possible values
  #  ; The location provider settings are in a different section.
  #  location-provider=manual
  #  
  #  ; Set the adjustment-method: 'randr', 'vidmode'
  #  ; type 'redshift -m list' to see all possible values
  #  ; 'randr' is the preferred method, 'vidmode' is an older API
  #  ; but works in some cases when 'randr' does not.
  #  ; The adjustment method settings are in a different section.
  #  adjustment-method=randr
  #  
  #  ; Configuration of the location-provider:
  #  ; type 'redshift -l PROVIDER:help' to see the settings
  #  ; e.g. 'redshift -l manual:help'
  #  [manual]
  #  lat=43
  #  lon=1
  #  
  #  ; Configuration of the adjustment-method
  #  ; type 'redshift -m METHOD:help' to see the settings
  #  ; ex: 'redshift -m randr:help'
  #  ; In this example, randr is configured to adjust screen 1.
  #  ; Note that the numbering starts from 0, so this is actually the second screen.
  #  [randr]
  #  screen=0
  #'';

  services.syncthing.enable = true;
  services.syncthing.user = "bork";
  services.syncthing.dataDir = "/home/bork";

  # 127.0.0.1:8384
  services.mullvad-vpn.enable = true;
  #services.redshift.enable = true;
  #location.longitude = 21.01; 
  #location.latitude = 52.22;

  # Backup service
  systemd.services.rdiff-home = {
    serviceConfig = {
      Type = "oneshot";
      User = "bork";
    };
    path = with pkgs; [ bash rdiff-backup ];
    script = ''
      bash /home/bork/scripts/rdiff.sh
    '';
  };

  systemd.timers.rdiff-home = {
    wantedBy = [ "timers.target" ];
    partOf = [ "rdiff-home.service" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = "true";
      Unit = "rdiff-home.service";
    };
  };
 
  #systemd.timers."hello-world" = {
  #  wantedBy = [ "timers.target" ];
  #    timerConfig = {
  #      OnBootSec = "5m";
  #      OnUnitActiveSec = "5m";
  #      Unit = "hello-world.service";
  #    };
  #};

  #systemd.timers."backup-home" = {
  #  wantedBy = [ "timers.target" ];
  #    timerConfig = {
  #      OnBootSec = "5m";
  #      OnUnitActiveSec = "5m";
  #      Unit = "backup-home.service";
  #    };
  #};

  #systemd.user.services.foo = {
  #script = ''
  #  echo "Doing some X11 stuff"
  #'';
  #wantedBy = [ "graphical-session.target" ];
  #partOf = [ "graphical-session.target" ];
  #};

  #systemd.user.services."keepassxc" = {
  #  script = ''
  #    keepassxc
  #  '';
  #  serviceConfig = {
  #    Type = "oneshot";
  #    User = "bork";
  #  };
  #  wantedBy = [ "graphical-session.target" ];
  #  partOf = ["graphical-session.target"];
  #};


  #systemd.services."hello-world" = {
  #  script = ''
  #    set -eu
  #    ${pkgs.coreutils}/bin/echo "Hello World"
  #  '';
  #  serviceConfig = {
  #    Type = "oneshot";
  #    User = "bork";
  #  };
  #};

  #systemd.services."backup-home" = {
  #  script = ''
  #    rdiff-backup /home/bork /basement/test
  #  '';
  #  serviceConfig = {
  #    Type = "oneshot";
  #    User = "bork";
  #  }; 
  programs.dconf.enable = true;
  programs.fish.enable = true;
  programs.fish.shellAliases = {
    nixos-rebuild = "nix-channel --update && sudo nixos-rebuild switch --upgrade --flake /home/bork/nix-config#desktop";
    nixos-checkflake = "nix flake check /home/bork/nix-config";
    nixos-cleanup = "nix-collect-garbage";
  };

  programs.firefox.enable = true;
  #programs.firefox.package = (pkgs.wrapFirefox.override { libpulseaudio = pkgs.libpressureaudio; }) pkgs.firefox-unwrapped { };
  #programs.zsh.enable = true;
  #programs.zsh.ohMyZsh.theme = "robbyrussell";
  #programs.fish.enable = true;
  programs.git.enable = true;
  programs.git.config = {
    init = {
      defaultBranch = "main";
    };
    user.name = "bogdaba";
    user.email = "bogdaba@github.com";
  };
  programs.steam.enable = true;
  #environment.sessionVariables.LD_LIBRARY_PATH = "/run/current-system/sw/lib microsoft-edge-dev";

  qt.platformTheme = "qt5ct";

  users.users = {
    bork = {
      isNormalUser = true;
      #home.sessionVariables = {
      #  NIX_PATH = "nixos-config=/etc/nixos/configuration.nix:/etc/nixos/nixpkgs";
      #};
      description = "Borkwave";
      extraGroups = [ "networkmanager" "wheel" ];

      packages = with pkgs; [
        gnome.gnome-tweaks
        thunderbird
        vscode-fhs
        keepassxc
        obsidian
        rdiff-backup
        inxi
        glxinfo
        xorg.xdpyinfo
        neofetch
        nomacs
        gimp-with-plugins
        mpv
        yt-dlp
        celluloid
        flameshot
        gnome.gnome-tweaks
        anki
        speedtest-cli
        archivebox
        #looking-glass-client
        ffmpeg_6-full
        wineWowPackages.waylandFull
        wineWow64Packages.waylandFull
        aseprite
        blender
        openscad
        godot_4
        python3Full
        gammastep #redshift for Wayland
        hledger
        okular
        mc
        nnn
        libsForQt5.dolphin
        libsForQt5.qt5ct
        libsForQt5.breeze-icons
        libsForQt5.kdenlive
        qbittorrent
        scrcpy
        calibre
        krita
        libwacom
        duplicity
        #davinci-resolve
        deja-dup
        #piper-tts
        #libratbag
        piper
        solaar
        #microsoft-edge-dev # easy tts
        tts
        espeak-classic
        tree
      ];
    };
  };

  fonts.packages = with pkgs; [
    nerdfonts
    mplus-outline-fonts.githubRelease
    noto-fonts
    iosevka
  ];
  fonts.fontconfig.defaultFonts.sansSerif = [
    "M PLUS 2"
  ];

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    settings.PermitRootLogin = "no";
    # Use keys only. Remove if you want to SSH using password (not recommended)
    settings.PasswordAuthentication = false;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
