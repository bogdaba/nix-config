# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: 

# I give up again
#let
#  nixgl = inputs.nixgl;
#  nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
#    mkdir $out
#    ln -s ${pkg}/* $out
#    rm $out/bin
#    mkdir $out/bin
#    for bin in ${pkg}/bin/*; do
#     wrapped_bin=$out/bin/$(basename $bin)
#     echo "exec ${lib.getExe nixgl.auto.nixGLDefault} $bin \$@" > $wrapped_bin
#     chmod +x $wrapped_bin
#    done
#  '';
#in

# why did I put it here? to be able to call unstable packages but I only use unstable channel already
#let
#  unstable = import <nixpkgs-unstable> {
#    config = config.nixpkgs.config;
#  };
#in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      #inputs.nixgl.overlay
      

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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);

      # here I tried installing etcher and needed this because electron was unsafe
      # permittedInsecurePackages = [
      #         "electron-12.2.3"
      #        ];
    };
  };
  
  # username
  home = {
    username = "bork";
    homeDirectory = "/home/bork";
  };

  # packages
  home.packages = with pkgs; [
    steam
    obsidian
    nomacs
    # Lost to the OpenGL
    #nixgl.nixGLIntel
    #(nixGLWrap pkgs.kitty)
    #(nixGLWrap pkgs.inkscape)
    #kitty
    #anki
    #flameshot
    #etcher
  ];

  # Zsh
  # Enable the Zsh shell.
  programs.zsh.enable = true;
  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.theme = "robbyrussell";

  # Set Zsh as the default shell.
  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";

  # Add aliases
  programs.zsh.shellAliases = {
    hiigara = "home-manager switch --flake '/home/bork/haven/nix-config#bork@popos'";
    updateme = "sudo apt update && sudo apt full-upgrade";
    reboot = "systemctl reboot";
  };
  
  

  #programs.zsh.initExtra = ''
  #  export PATH=$HOME/bin:/usr/local/bin:$PATH
  #  export ZSH="$HOME/.oh-my-zsh"
  #'';


# apparently it's nixos option only
#  programs.zsh.shellInit = ''
#
#   '';
#    # If you come from bash you might have to change your $PATH.
#    export PATH=$HOME/bin:/usr/local/bin:$PATH
#
#    # Path to your oh-my-zsh installation.
#    export ZSH="$HOME/.oh-my-zsh"
#
#    # Set name of the theme to load --- if set to "random", it will
#    # load a random theme each time oh-my-zsh is loaded, in which case,
#    # to know which specific one was loaded, run: echo $RANDOM_THEME
#    # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#    ZSH_THEME="robbyrussell"
#
#    # and so on...
#
#    # User configuration
#
#    # export MANPATH="/usr/local/man:$MANPATH"
#
#    # You may need to manually set your language environment
#    # export LANG=en_US.UTF-8
#    # Preferred editor for local and remote sessions
#    # if [[ -n $SSH_CONNECTION ]]; then
#    #   export EDITOR='vim'
#    # else
#    #   export EDITOR='mvim'
#    # fi
#
#    # Compilation flags
#    # export ARCHFLAGS="-arch x86_64"
#
#    # Set personal aliases, overriding those provided by oh-my-zsh libs,
#    # plugins, and themes. Aliases can be placed here, though oh-my-zsh
#    # users are encouraged to define aliases within the ZSH_CUSTOM folder.
#    # For a full list of active aliases, run `alias`.
#    #
#    # Example aliases
#    # alias zshconfig="mate ~/.zshrc"
#    # alias ohmyzsh="mate ~/.oh-my-zsh"
#  '';
#  

  # it doesn't work btw.
  # programs.bash.shellAliases = {
  #  homenew = "home-manager switch --flake /home/bork/haven/nix-config#bork@bork-desktop";
  #};

  # Flameshot
  # services.flameshot.enable = true;


  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
