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

# 2b. Python environment (.venv) — installs the checked-out Yakoon
# Python packages and the test tooling as editable/reproducible local
# state. VSCode resolves `${workspaceFolder}/.venv/bin/python` to this.
PY="$ROOT/.venv/bin/python"
if [ ! -x "$PY" ]; then
    echo "Creating virtual environment (.venv)…"
    python3 -m venv "$ROOT/.venv"
fi

echo "Installing test tooling and Yakoon packages as editable sources…"
"$ROOT/.venv/bin/pip" install --quiet pytest pytest-asyncio

# Python packages from the just-cloned source repositories. Each is
# installed editable from its own checkout; none comes from PyPI.
"$PY" -m pip install --quiet -e \
    "$ROOT/runtime/packages/runtime-api" \
    "$ROOT/runtime/packages/runtime-boot" \
    "$ROOT/runtime/packages/runtime-engine" \
    "$ROOT/runtime/packages/runtime-llm" \
    "$ROOT/runtime/packages/runtime-store" \
    "$ROOT/runtime/packages/runtime-transport" \
    "$ROOT/runtime/caps/caps-root" \
    "$ROOT/sdk/sdk-python" \
    "$ROOT/apps/apps-yak" \
    "$ROOT/apps/apps-console" \
    "$ROOT/apps/apps-runtime" \
    "$ROOT/apps/apps-shell" \
    "$ROOT/apps/apps-web" \
    "$ROOT/launcher" \
    "$ROOT/caps-system" \
    "$ROOT/caps-ident" \
    "$ROOT/caps-contacts" \
    "$ROOT/caps-worlds" \
    "$ROOT/caps-labs"

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
