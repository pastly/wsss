{ pkgs, lib, callPackage, dir_name }:
let
  contents = builtins.readDir dir_name;
  files = map (x: callPackage ./do-file.nix { file_name = dir_name + "/${x}"; }) (builtins.attrNames (lib.attrsets.filterAttrs (n: v: v == "regular") contents));
  dirs =  map (x: callPackage ./do-dir.nix  { dir_name  = dir_name + "/${x}"; }) (builtins.attrNames (lib.attrsets.filterAttrs (n: v: v == "directory") contents));
in 
  derivation {
    inherit dir_name;
    inherit files dirs;
    inherit (pkgs) coreutils;
    name = builtins.concatStringsSep "-" [(builtins.baseNameOf dir_name) "compiled"];
    builder = "${pkgs.bash}/bin/bash";
    args = [ ./do-dir.sh ];
    system = builtins.currentSystem;
  }
