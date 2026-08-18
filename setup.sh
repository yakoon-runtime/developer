#!/usr/bin/env bash
# Set up a Yakoon developer workspace from the source repositories.
#
#   git clone https://github.com/yakoon-runtime/developer.git yakoon
#   cd yakoon && ./setup.sh
#   code yakoon.code-workspace
#
# Idempotent: safe to re-run. The repositories are public, so cloning and
# installs are credential-free. After cloning, the remotes are switched to
# SSH: pushing then works immediately with your GitHub SSH key. Without a
# key you can still use the workspace read-only.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. The yak tool (launcher from PyPI, the tool from its own repo).
if ! command -v yak >/dev/null 2>&1; then
    echo "Installing yak (pip install yakoon)…"
    python3 -m pip install --user yakoon
fi

# 2. Source repositories (each is its own git repo, cloned on demand).
for repo in runtime sdk apps launcher caps-system caps-ident caps-contacts caps-worlds caps-labs; do
    if [ ! -d "$ROOT/$repo/.git" ]; then
        echo "Cloning $repo…"
        git clone "https://github.com/yakoon-runtime/$repo.git" "$ROOT/$repo"
        git -C "$ROOT/$repo" remote set-url origin "git@github.com:yakoon-runtime/$repo.git"
    fi
done

# 3. Context + the platform as sources (developer mode: everything from
#    the checkouts, nothing released).
cd "$ROOT"
if [ ! -d "$ROOT/.yak" ]; then
    echo "Initializing the Yak context…"
    yak init
fi

echo "Installing the platform as sources…"
yak install runtime --path ./runtime --path ./sdk --path ./apps
yak install system --path ./caps-system
yak install ident --path ./caps-ident
yak install crm --path ./caps-contacts

echo
echo "Done. Open the workspace:"
echo "  code yakoon.code-workspace"
echo "and press F5 (Yakoon Runtime) to run the runtime under the debugger."
