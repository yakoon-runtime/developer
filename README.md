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

Requirements: `git` and Python ≥ 3.11. The repositories are public — no
GitHub account, SSH keys or token needed to set up the workspace.
`setup.sh` clones over HTTPS (credential-free) and then switches the
remotes to SSH, so pushing works immediately once you add your SSH key.

```bash
git clone https://github.com/yakoon-runtime/developer.git yakoon
cd yakoon
./setup.sh
code yakoon.code-workspace
```
`setup.sh` clones the source repositories, installs the `yak` tool
(launcher from PyPI via `pip install yakoon`, the actual tool is pulled
from `dists` on first use), initializes the context and installs the
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

## Working inside the runtime

The shell is a separate component, installed on demand:

```bash
yak install shell     # install the Yakoon shell into the context
yak shell             # open the shell, running inside the runtime
```

`yak shell` runs the shell as part of the runtime, so you can work with
the platform while F5 (Yakoon Runtime) keeps the debugger attached.

## Where things come from

```text
PyPI           yakoon (launcher)     → pip install yakoon
dists          built software        → github:yakoon-runtime/dists
sources        code you edit         → the repositories above
```

Reads (install, update) are credential-free; only `yak deploy` needs
`YAK_GITHUB_TOKEN`.
