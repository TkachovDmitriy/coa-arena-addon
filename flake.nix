{
  description = "CoA Arena addon development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              lua5_1
              luajitPackages.luacheck
              ripgrep
            ];

            LUA_COMPILER = "${pkgs.lua5_1}/bin/luac";
            LUA_RUNTIME = "${pkgs.lua5_1}/bin/lua";
          };
        }
      );
    };
}
