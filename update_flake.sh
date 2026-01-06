#!/bin/sh
# Updates flake.nix with a new version and hashes
# Usage: ./update_flake.sh <version> <hashes_file>

set -e

VERSION="$1"
HASHES_FILE="$2"

if [ -z "$VERSION" ] || [ -z "$HASHES_FILE" ]; then
    echo "Usage: $0 <version> <hashes_file>"
    exit 1
fi

if [ ! -f "$HASHES_FILE" ]; then
    echo "Error: Hashes file not found: $HASHES_FILE"
    exit 1
fi

# Update version
sed -i.bak "s/pkg_version = \".*\"/pkg_version = \"$VERSION\"/" flake.nix

# Update hashes - replace everything between "source_hashes = {" and the closing "};"
awk -v hashes_file="$HASHES_FILE" '
  /source_hashes = \{/ {
    print
    while ((getline line < hashes_file) > 0) {
      print line
    }
    close(hashes_file)
    in_block=1
    next
  }
  in_block && /^[[:space:]]*\};/ {
    print "          };"
    in_block=0
    next
  }
  !in_block { print }
' flake.nix > flake.nix.tmp

mv flake.nix.tmp flake.nix
rm -f flake.nix.bak

echo "✓ Updated flake.nix to version $VERSION"
