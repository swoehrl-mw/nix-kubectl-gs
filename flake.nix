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
          pkg_version = "4.7.0";
          # Map nix system names to download names for kubectl-gs releases
          name_mapping = {
            "x86_64-linux" = "linux-amd64";
            "aarch64-linux" = "linux-arm64";
            "x86_64-darwin" = "darwin-amd64";
            "aarch64-darwin" = "darwin-arm64";
          };
          # Hashes for the different architectures, calculated using ./calc_hashes.sh
          source_hashes = {
            "linux-amd64" = "jhFKinVeMSVKs4tsqltrq529U2pzHpcJv2jpuulkU8w=";
            "linux-arm64" = "KsDyuglFV97uN4uowQkFbPKDDzv0Lbhh0dhI5C57hGI=";
            "darwin-amd64" = "SZ3v4uNZk/BYNdaoBZaVgry2+36QRecXhKizD+lGH0o=";
            "darwin-arm64" = "59dfMDpTsn+HSBdwp30btK64W7zjydlNaSoGEwB/M4g=";
          };
        in {
          kubectl-gs = pkgs.stdenv.mkDerivation rec {
            pname = "kubectl-gs";
            version = "${pkg_version}";
            src = pkgs.fetchurl {
              url =
                "https://github.com/giantswarm/kubectl-gs/releases/download/v${pkg_version}/kubectl-gs-v${pkg_version}-${name_mapping.${system}}.tar.gz";
              sha256 = "${source_hashes.${name_mapping.${system}}}";
            };

            dontConfigure = true;
            dontBuild = true;
            installPhase = ''
              mkdir -p $out/bin
              cp kubectl-gs $out/bin
            '';
          };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.kubectl-gs);
    };
}
