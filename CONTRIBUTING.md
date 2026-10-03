# Contributing to the BOMBKI test coverage

A supplementary effort for BOMBKI source code reconstruction and further ports.

## Ground truth dir layout

* `_reference/` and the machine evidence derived from it. `_reference/` is read-only.
* `_reconstructed/` and facts derived from it. `_reconstructed/` is read-only.

## Functional dir layout
* `tests\` - all things related to running tests
* `tests\scenarios` - test scenarios
* `tools\` - helpers, utils and toolings
* `build\` - ephemeral build directory
* `build\tmp` - project-scoped temp directory
* `docker\` - Dockers for CI and local runs


## Source fidelity and reconstructed names

- Reconstructed unit `.PAS` files are machine-code-equivalent to their `.TPU`
  files, including declarations, types, names, and unit ownership.
- Invented identifiers use ordinary Pascal capitalization with Polish names
  (e.g. `WybierzRase`, `PunktKontrolny`, `ZdobadzPoziom`), ALLCAPS is used only
  for names fully available in reference data.

## Docs

- `TODO.md` is the maintained active work queue; keep it current as work lands.

## Commits

One line, conventional prefix (`docs: feat: fix: refactor: ci:` etc.),
no bodies. Concise and short messages.
History rewrites on `main` are agreed first.

## Text

LF, UTF-8, Polish diacritics preserved.
Files always end with a newline; enforced locally by `.githooks/pre-commit`
(`git config core.hooksPath .githooks`).
