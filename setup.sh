#!/usr/bin/env bash
# Set up a Yakoon developer workspace from the source repositories.
#
#   git clone https://github.com/yakoon-runtime/developer.git yakoon
#   cd yakoon && ./setup.sh
#   code yakoon.code-workspace
#
# Idempotent: safe to re-run. The repositories are public, so cloning and
# installs are credential-free. Only pushing later needs your own GitHub
# credentials (SSH or a configured remote).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. The yak tool (launcher from PyPI, tool from dists).
if ! command -v yak >/dev/null 2>&1; then
    echo "Installing yak (pip install yakoon)…"
    python3 -m pip install --user yakoon
fi

# 2. Source repositories (each is its own git repo, cloned on demand).
for repo in runtime sdk apps launcher pack-system pack-ident pack-crm pack-luma pack-labs .github; do
    if [ ! -d "$ROOT/$repo/.git" ]; then
        echo "Cloning $repo…"
        git clone "https://github.com/yakoon-runtime/$repo.git" "$ROOT/$repo"
    fi
done

# 3. Context + the platform as sources (developer mode: everything from
#    the checkouts, nothing from dists).
cd "$ROOT"
if [ ! -d "$ROOT/.yak" ]; then
    echo "Initializing the Yak context…"
    yak init
fi

echo "Installing the platform as sources…"
yak install runtime --path ./runtime --path ./sdk --path ./apps
yak install system --path ./pack-system
yak install ident --path ./pack-ident
yak install crm --path ./pack-crm

echo
echo "Done. Open the workspace:"
echo "  code yakoon.code-workspace"
echo "and press F5 (Yakoon Runtime) to run the runtime under the debugger."
