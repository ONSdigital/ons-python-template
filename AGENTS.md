# AGENTS.md

Guidance for coding agents working in this repository.

## Repository Purpose

This repository is a Copier template for generating ONS Python projects. The root repository is maintained with Poetry, while generated projects can use Poetry, Pipenv, or uv.

The important distinction is:

- Root repo files configure and test the template itself.
- `project_template/` contains files rendered into generated projects.
- `copier.yml` controls Copier questions, computed variables, and post-generation tasks.
- `scripts/package_manager_helper/` is maintainer tooling used to refresh generated package-manager artifacts.

## Common Commands

Use Poetry for this repository's own tooling:

```bash
poetry install
poetry run pytest -n auto tests
make test
```

`make test` must stay scoped to `tests/`; do not include `project_template/tests` in root test runs.

To render the current local template for manual testing, use:

```bash
poetry run copier copy --trust --defaults --overwrite --vcs-ref=HEAD \
  --data repository_name=test-template \
  --data repository_description="Template generation smoke test" \
  --data repository_owner=ONSdigital \
  --data code_owner=@ONSdigital/test-team \
  --data default_branch=main \
  --data set_up_git_repo=false \
  --data repository_visibility=public \
  --data package_manager=poetry \
  . /tmp/generated-project
```

Use `package_manager=uv` with `--data confirm_uv_prerelease=true` when testing uv output.

Because this repository is a VCS-backed Copier template, always include `--vcs-ref=HEAD` when validating current local changes. Plain `copier copy . ...` can render a tagged or older template revision instead of the current worktree.

## Source of Truth

Do not fix generated output only. If an issue is found in a rendered project, apply the fix to the relevant source template file under `project_template/`, `copier.yml`, or the helper scripts.

Generated directories such as `/tmp/generated-project` are for validation only and must not be treated as the final source of truth.

## Template Structure

Key files and directories:

- `copier.yml`: questions, validators, computed variables, and post-copy tasks.
- `project_template/README.md.jinja`: generated README.
- `project_template/Makefile.jinja`: generated project commands.
- `project_template/.github/workflows/ci.yml.jinja`: generated CI workflow.
- `project_template/copier_scripts/run_tasks.sh`: task entrypoint run after generation.
- `project_template/copier_scripts/setup_package_manager.sh`: removes unselected package-manager files and appends tool config.
- `project_template/copier_scripts/cleanup_conditional_files.sh`: removes stale conditional files when regenerating into an existing directory.
- `tests/`: smoke tests that render the template with Copier and assert generated output.

Jinja is used in both file contents and filenames. Treat filenames like `project_template/{% if poetry_no_copier %}pyproject.toml{% endif %}.jinja` as intentional.

## Copier Variables

Keep package-manager condition names consistent with `copier.yml`:

- `poetry_copier`
- `poetry_no_copier`
- `pipenv_copier`
- `pipenv_no_copier`
- `uv_copier`
- `uv_no_copier`

Visibility behavior is controlled by `repository_visibility` and computed `is_public_repo`:

- Public repositories include `LICENSE` and CodeQL workflow output.
- Private/internal repositories include `PIRR.md` and omit public-only files.
- Cleanup scripts must handle users regenerating after changing visibility or package manager.

## Copier Regeneration

When testing regeneration behaviour, render once, then rerun Copier into the same destination with changed answers.

This is especially important for:

- package manager changes
- repository visibility changes
- conditional files
- cleanup scripts
- generated README and CI output

Regeneration should remove stale files from previous choices where the template expects that behaviour.

## Package-Manager Artifacts

Generated package-manager files under `project_template/` are maintained via:

```bash
make update-template-packages
```

That command runs `scripts/package_manager_helper/update_template_packages.sh` and requires the relevant CLIs locally: `poetry`, `pipenv`, and `uv`.

When changing dependency sets or lockfile generation:

- Edit helper inputs in `scripts/package_manager_helper/`.
- Update `update_template_packages.sh` if the generation process changes.
- Run `make update-template-packages`.
- Review generated artifacts in `project_template/`.

Avoid hand-editing generated lockfiles or generated package-manager pyproject/Pipfile outputs unless the change is a small template-placeholder correction that the helper script also preserves.

uv-specific notes:

- uv is pre-v1 and has a confirmation prompt in `copier.yml`.
- `actions/setup-python` does not support `cache: uv`; generated uv CI must not emit that setting.
- uv lockfiles can contain a virtual root package. The helper rewrites the root package name to `{{ repository_name }}` before copying lockfiles into the template.

## Package Manager Compatibility

Do not add behaviour for only one package manager unless the change is intentionally package-manager-specific.

For dependency, install, lint, test, CI, or Makefile behaviour, check Poetry, Pipenv, and uv outputs together. If one package manager intentionally differs, document that difference in the relevant template or test.

## Generated Project Behavior

Generated project `make` targets are package-manager-specific:

- Poetry uses `poetry run`, `poetry install`, and `poetry install --only main`.
- Pipenv uses `pipenv run`, `pipenv install`, and `pipenv install --dev`.
- uv uses `uv run`, `uv sync`, and `uv sync --no-dev`.

When adding package-manager behavior, update all of these together:

- `copier.yml`
- generated package files in `project_template/`
- `project_template/Makefile.jinja`
- `project_template/README.md.jinja`
- `project_template/.github/workflows/ci.yml.jinja`
- `project_template/copier_scripts/setup_package_manager.sh`
- `project_template/copier_scripts/cleanup_conditional_files.sh`
- `scripts/package_manager_helper/update_template_packages.sh`
- `tests/test_template_generation.py`

## Conditional File Cleanup

When adding a new conditional file, update cleanup logic so that stale files are removed when users regenerate with different answers.

This applies to files controlled by:

- package manager choice
- repository visibility
- Copier/no-Copier variants
- public/private/internal repository behaviour

## GitHub Actions

All GitHub Actions workflow references must be pinned to a full commit SHA, not a mutable tag.

Use this form:

```yaml
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
```

Do not use this form:

```yaml
- uses: actions/checkout@v4
```

When updating an action, update the SHA and add a short comment if helpful to indicate the human-readable upstream version.

Generated GitHub Actions workflows must also respect package-manager-specific constraints. For example, `actions/setup-python` does not support `cache: uv`, so uv-generated workflows must not emit that setting.

## Testing Expectations

For changes to template rendering, add or update smoke tests in `tests/test_template_generation.py`.

Minimum checks for package-manager or visibility changes:

- public, private, and internal repository visibility output
- generated package-manager files included and unselected files omitted
- regeneration into the same destination cleans stale conditional files
- CI workflow output for package-manager-specific constraints

Run:

```bash
poetry run pytest -n auto tests
```

If tests cannot be run, state the reason clearly.

## Validation Approach

When changing Jinja templates, validate the rendered output rather than relying only on the template diff.

For each affected option, render the template and inspect the generated files. Pay particular attention to:

- YAML indentation in GitHub Actions
- Markdown spacing in README output
- TOML validity in generated `pyproject.toml`
- shell syntax in generated scripts
- omitted conditional files
- stale files after regeneration

## Test Style

Prefer tests that assert generated behaviour and file presence rather than duplicating large rendered files.

Good tests check:

- expected files exist
- unselected files do not exist
- relevant generated command snippets are present
- invalid combinations are rejected
- rendered config is syntactically valid where practical

## Copier Script Safety

Scripts under `project_template/copier_scripts/` run during trusted Copier generation. Keep them idempotent, predictable, and safe to rerun.

Avoid assumptions about the current working directory unless explicitly set. Prefer clear guards before deleting files, and avoid broad glob removals.

## Editing Rules

- Preserve existing Jinja whitespace controls unless changing rendered spacing intentionally.
- Be careful with README spacing around conditional blocks; render both true and false paths when changing conditionals.
- Keep generated project docs concise and user-facing. Do not document implementation details in generated READMEs unless users need them.
- Do not remove `copier_scripts` from the template; generated projects remove that directory during post-copy tasks.
- Do not use destructive git commands. The worktree may contain user changes.
- Use `rg` for searches and `apply_patch` for manual edits.

## High-Risk Areas

Take extra care when changing:

- `copier.yml`
- conditional filenames under `project_template/`
- generated GitHub Actions workflows
- generated package-manager files
- cleanup scripts
- post-copy scripts
- README sections with package-manager-specific instructions

Small-looking changes in these areas can affect several generated project variants.

## Before Finishing

Before completing a change, check:

- the root test suite still targets `tests/`
- the affected template variants have been rendered
- generated output is valid and readable
- stale conditional files are cleaned up on regeneration
- package-manager-specific docs and commands agree
- any GitHub Actions references are pinned to full SHAs
- no user worktree changes were overwritten
