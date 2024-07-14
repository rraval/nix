{ pkgs, ... }:
let
  jsvinePlugins = pkgs.fetchFromGitHub {
    owner = "jsvine";
    repo = "visidata-plugins";
    rev = "aacf35da59e72c0df20b82458aaa93f2fa1b5ff4";
    hash = "sha256-1JSP3eVtmLWFmIx+TD7aDRLx2nNeomm2+2k+r50b1U8=";
  };
in {
  home = {
    packages = [ pkgs.visidata ];

    file = {
      ".visidata/plugins/dedupe.py".source =
        builtins.toPath "${jsvinePlugins}/plugins/dedupe.py";
      ".visidatarc".text = ''
        import plugins.dedupe
      '';
    };
  };
}
