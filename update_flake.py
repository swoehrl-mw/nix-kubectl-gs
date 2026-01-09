import re
import sys
import subprocess


version = sys.argv[1]

if version.startswith("v"):
    version = version[1:]

# Run calc_hashes.sh

result = subprocess.run(f"bash calc_hashes.sh {version}", shell=True, capture_output=True)
result.check_returncode()
hashes = result.stdout.decode("utf-8")


# Replace version and hashes in flake.nix

with open("flake.nix") as f:
    nixfile = f.read()

nixfile = re.sub(r"pkg_version = \"(\d+\.\d+\.\d+)\";", f'pkg_version = "{version}";', nixfile)

nixfile = re.sub(r"source_hashes = {\n.*\n.*\n.*\n.*\n\s+};", f"source_hashes = {{\n{hashes}          }};", nixfile, flags=re.MULTILINE)

with open("flake.nix", "w") as f:
    f.write(nixfile)

# Replace version in README.md

with open("README.md") as f:
    readme = f.read()

readme = re.sub(r"v\d+\.\d+\.\d+", f"v{version}", readme)

with open("README.md", "w") as f:
    f.write(readme)
