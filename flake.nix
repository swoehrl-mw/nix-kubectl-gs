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
          pkg_version = "5.7.2";
          # Map nix system names to download names for kubectl-gs releases
          name_mapping = {
            "x86_64-linux" = "linux-amd64";
            "aarch64-linux" = "linux-arm64";
            "x86_64-darwin" = "darwin-amd64";
            "aarch64-darwin" = "darwin-arm64";
          };
          # Hashes for the different architectures, calculated using ./calc_hashes.sh
          source_hashes = {
            "linux-amd64" = "FmtlbYsihSlF7Fqf0DWvq4p+b/whPytVa3iIgQhsOoM=";
            "linux-arm64" = "vYxL6uetlNot/8kyAITFd7I7ExRLmLNr+eh2W0iY2ZM=";
            "darwin-amd64" = "GZhMlUxgb8QXqrYUO0Gb1Ot+gvJk9YXC/AdJ9wXl8yY=";
            "darwin-arm64" = "R2LZMEQZEKOQlb9K2GuXhguO7U9GtxJ/WymegQoq13Y=";
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
