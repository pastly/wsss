{ pkgs, file_name }:
derivation {
  inherit file_name;
  inherit (pkgs) coreutils xz;
  name = builtins.concatStringsSep "-" [(builtins.baseNameOf file_name) "compiled"];
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./do-file.sh ];
  system = builtins.currentSystem;
}

