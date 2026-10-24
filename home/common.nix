{ pkgs, ... }:
{
  home.packages = with pkgs; [
    age
    delta
    direnv
    fd
    fzf
    git
    jq
    lazygit
    mise
    neovim
    ripgrep
    stow
    starship
    tmux
    tree
    unzip
    vim
    zoxide
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.home-manager.enable = true;

  xdg.configFile."structured/config.toml".text = ''
    layout = "side"
    detail_percent = 46
  '';
}
