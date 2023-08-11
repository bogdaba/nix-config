First, ensure that you have flakes support enabled on your system. You can do this by adding the following line to your /etc/nixos/configuration.nix file:

```
nix = {
  package = pkgs.nixFlakes;
  extraOptions = "experimental-features = nix-command flakes";
};
```
