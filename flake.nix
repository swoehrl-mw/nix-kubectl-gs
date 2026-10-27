{
  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        let 
          pkgs = nixpkgsFor.${system};
          pkg_version = "5.11.15";
          # Map nix system names to download names for kubectl-gs releases
          name_mapping = {
            "x86_64-linux" = "linux-amd64";
            "aarch64-linux" = "linux-arm64";
            "x86_64-darwin" = "darwin-amd64";
            "aarch64-darwin" = "darwin-arm64";
          };
          # Hashes for the different architectures, calculated using ./calc_hashes.sh
          source_hashes = {
            "linux-amd64" = "oV11VmMr4Weq3nZvSHxs0NYucbgZ3v6rLx6Fuzv+IrA=";
            "linux-arm64" = "6EdZc27fNvfTSx/0o5k7bbZuH8zVcUTeXyMglwE+0Zw=";
            "darwin-amd64" = "g2iU0wUaArMm9WmSNSa1Ot2GC5+ymsRWGX2sZVxBQJg=";
            "darwin-arm64" = "mdKVXotx6xJxGCG+CRXbSnb8m+9YPLWq4zJygJyMOro=";
          };
        in rec {
          kubectl-gs = pkgs.stdenv.mkDerivation rec {
            pname = "kubectl-gs";
            version = "${pkg_version}";
            src = pkgs.fetchurl {
              url =
                "https://github.com/giantswarm/kubectl-gs/releases/download/v${pkg_version}/kubectl-gs-v${pkg_version}-${name_mapping.${system}}.tar.gz";
              sha256 = "${source_hashes.${name_mapping.${system}}}";
            };
            sourceRoot = ".";

            dontConfigure = true;
            dontBuild = true;
            installPhase = ''
              mkdir -p $out/bin
              cp kubectl-gs $out/bin
            '';
          };
          default = kubectl-gs;
        });
    };
}
