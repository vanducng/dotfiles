{ ... }:
{
  imports = [
    ../agent-tools.nix
    ../linux.nix
  ];

  home.username = "friday";
  home.homeDirectory = "/home/friday";
  home.stateVersion = "26.05";
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "/workspace/.npm-global";
    PI_CODING_AGENT_DIR = "/workspace/.pi/agent";
  };
  home.sessionPath = [ "/workspace/.npm-global/bin" ];
}
