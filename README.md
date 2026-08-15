# Yakoon Developer Workspace

The entry point for developing Yakoon. This repository is **not** a Yak
source: it is glue. It fetches the source repositories, sets up the Yak
context, and provides the editor configuration. The concrete editor stays
the developer's choice — `.vscode/` is a convenience, not an architecture.

## Layout

After `setup.sh` this directory holds:

```text
developer/
├── .vscode/            VS Code convenience (F5 → runtime under debugger)
├── yakoon.code-workspace
├── setup.sh
├── README.md
├── runtime/            source repositories (own git repos, cloned)
├── sdk/
├── apps/
├── launcher/
├── pack-system/  … pack-labs/
└── .yak/               local context (machine state, ignored)
```

## Setup

Requirements: `git` (SSH access to the `yakoon-runtime` org), Python ≥ 3.11.

```bash
git clone git@github.com:yakoon-runtime/developer.git yakoon
cd yakoon
./setup.sh
code yakoon.code-workspace
```

`setup.sh` clones the source repositories, installs the `yak` launcher
from PyPI (`pip install yakoon`), initializes the context and installs the
platform as sources:

```text
runtime → ./runtime ./sdk ./apps      (source)
system  → ./pack-system               (source)
ident   → ./pack-ident                (source)
crm     → ./pack-crm                  (source)
```

Everything is editable from the checkouts: the venv at `.venv` uses the
code you edit. F5 starts the runtime under the debugger and breakpoints
land directly in `runtime/`, `sdk/`, `apps/` and the packs.

## Where things come from

```text
PyPI           yakoon (launcher)     → pip install yakoon
dists          built software        → github:yakoon-runtime/dists
sources        code you edit         → the repositories above
```

Reads (install, update) are credential-free; only `yak deploy` needs
`YAK_GITHUB_TOKEN`.
