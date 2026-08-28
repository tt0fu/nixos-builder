set -euo pipefail

nix run .#generate-inputs

git add --all

nh os "${1-switch}" . --show-trace "${@:2}"
