{
  description = "FHS environment to run SnekTake2 Godot binaries on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          fhs = pkgs.buildFHSEnv {
            name = "snektake2-env";
            targetPkgs = pkgs: with pkgs; [
              # Graphics
              vulkan-loader
              libGL
              libGLU
              mesa

              # X11
              xorg.libX11
              xorg.libXcursor
              xorg.libXrandr
              xorg.libXinerama
              xorg.libXi
              xorg.libXext
              xorg.libXfixes
              xorg.libXrender

              # Wayland
              wayland
              libxkbcommon

              # Audio
              alsa-lib
              libpulseaudio

              # System
              glib
              dbus
              fontconfig
              freetype
              udev
              libdecor
            ];
            runScript = "bash";
          };
        in
        {
          default = fhs.env;
        }
      );
    };
}
