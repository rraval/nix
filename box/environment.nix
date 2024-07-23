{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      fish
      git
      neovim
    ];

    shells = [ pkgs.fish ];

    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Automatically load fish direnv hook
    # https://github.com/nix-community/home-manager/pull/2408#issuecomment-951079054
    pathsToLink = [ "/share/fish" ];
  };

  programs.fish.enable = true;
}
