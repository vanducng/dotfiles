{ ... }:
{
  imports = [
    ../agent-tools.nix
    ../darwin.nix
  ];

  home.username = "vanducng";
  home.homeDirectory = "/Users/me";
  home.stateVersion = "26.05";
}
