set -euo pipefail

nix run .#generate-inputs

nh os "${1-switch}" . --show-trace "${@:2}"
