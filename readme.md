# #wip 
1. Aqcuire recommended nixos install
2. Flash it
3. Install nixos
4. First, ensure that you have flakes support enabled on your system. You can do this by adding the following line to your /etc/nixos/configuration.nix file:

```
nix = {
  package = pkgs.nixFlakes;
  extraOptions = "experimental-features = nix-command flakes";
};
```