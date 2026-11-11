{ config, ... }:
{
  imports = [
    ../agent-tools.nix
    ../darwin.nix
  ];

  home.username = "vanducng";
  home.homeDirectory = "/Users/${config.home.username}";
  home.stateVersion = "26.05";
}
