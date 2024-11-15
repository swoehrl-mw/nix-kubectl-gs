# Nix Flake for kubectl-gs

This repository contains a very basic [Nix Flake](https://nixos.wiki/wiki/Flakes) providing the [Giantswarm Kubectl plugin](https://github.com/giantswarm/kubectl-gs) as a package. It is intended to be added to dev shells.

## Usage

To reference this flake use the following format: `github:swoehrl-mw/nix-kubectl-gs/v<version>`. If you just want the latest version and don't care about version pinning, remove the `/v<version>` part.

Example: `github:swoehrl-mw/nix-kubectl-gs/v4.5.0`

To use the package with [devbox](https://www.jetify.com/devbox/docs/), simply add the reference to your `devbox.json` `packages`:

```json
{
    "packages": [
        "kubectl@latest",
        "github:swoehrl-mw/nix-kubectl-gs/v4.5.0"
    ]
}
```

To add the package to a classic [nix-shell](https://nix.dev/tutorials/first-steps/declarative-shell), use the following snippet in your `shell.nix`:

```nix
pkgs.mkShellNoCC {
  packages = [
    pkgs.kubectl
    (builtins.getFlake "github:swoehrl-mw/nix-kubectl-gs/v4.5.0").packages.${builtins.currentSystem}.kubectl-gs
  ];
}
```

## Development

Steps to update the Flake to a new version:

1. Change the version in `calc_hashes.sh` and run the script
2. Edit `flake.nix`:
   1. Paste the output of the script into the `source_hashes` block
   2. Change the `pkg_version`
3. Commit and push the changes
4. Tag the commit with the new version
