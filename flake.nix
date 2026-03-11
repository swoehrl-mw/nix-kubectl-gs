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
          pkg_version = "5.0.2";
          # Map nix system names to download names for kubectl-gs releases
          name_mapping = {
            "x86_64-linux" = "linux-amd64";
            "aarch64-linux" = "linux-arm64";
            "x86_64-darwin" = "darwin-amd64";
            "aarch64-darwin" = "darwin-arm64";
          };
          # Hashes for the different architectures, calculated using ./calc_hashes.sh
          source_hashes = {
            "linux-amd64" = "jSmEz0wfUGkJ4ADLDH6COfUHVa+Gb5wI1CAgEKqySwM=";
            "linux-arm64" = "oq+CDIkKviNwqHaYwgKloN0Rx3Pj1ZEkitwISG764wI=";
            "darwin-amd64" = "94ahB/dpUMkCA72adqC/rsQLYGQ6s3/qM12NRuGzRjw=";
            "darwin-arm64" = "g+ofr+YYZBY1kRZLGh6Ur0SlZ/6zTPnmluPDvOk+6Ns=";
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
