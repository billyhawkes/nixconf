{ lib, pkgs, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  odinWithRaylib = pkgs.writeShellScriptBin "odin" ''
    export CPATH="${pkgs.raylib}/include''${CPATH:+:$CPATH}"
    export LIBRARY_PATH="${pkgs.raylib}/lib''${LIBRARY_PATH:+:$LIBRARY_PATH}"
    export NIX_LDFLAGS="-L${pkgs.raylib}/lib -rpath ${pkgs.raylib}/lib ''${NIX_LDFLAGS:-}"
    export PKG_CONFIG_PATH="${pkgs.raylib}/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    exec ${lib.getExe pkgs.odin} "$@"
  '';
in
{
  imports = [
    ./neovim.nix
  ];

  environment = {
    etc."bunfig.toml".text = ''
      [install]
      minimumReleaseAge = 259200
      minimumReleaseAgeExcludes = ["@krak-stack/auth"]
    '';

    systemPackages =
      with pkgs;
      [
        mysql84

        # Nix
        nh
        statix
        deadnix
        shellcheck
        cmake

        # Typescrypt
        bun
        nodejs_24
        prettierd
        typescript
        typescript-language-server
        vscode-langservers-extracted

        # Rust
        cargo
        clippy
        rust-analyzer
        rustc
        rustfmt

        # Zig
        zig

        # CLI's
        awscli2
        lazygit
        gh
        ripgrep
      ]
      ++ lib.optionals isLinux [
        odinWithRaylib
        pkg-config
        raylib
      ];
  }
  // lib.optionalAttrs isLinux {
    sessionVariables = {
      CPATH = "${pkgs.raylib}/include";
      LIBRARY_PATH = "${pkgs.raylib}/lib";
      PKG_CONFIG_PATH = "${pkgs.raylib}/lib/pkgconfig";
    };
  };
}
