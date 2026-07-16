"""Smoke tests for Copier-based template generation."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import pytest


def read_readme(destination: Path) -> str:
    """Read the generated README content."""
    return (destination / "README.md").read_text(encoding="utf-8")


def read_ci_workflow(destination: Path) -> str:
    """Read the generated CI workflow content."""
    return (destination / ".github" / "workflows" / "ci.yml").read_text(encoding="utf-8")


def read_makefile(destination: Path) -> str:
    """Read the generated Makefile content."""
    return (destination / "Makefile").read_text(encoding="utf-8")


def read_pre_commit_config(destination: Path) -> str:
    """Read the generated pre-commit configuration."""
    return (destination / ".pre-commit-config.yaml").read_text(encoding="utf-8")


def assert_public_visibility_outputs(destination: Path) -> None:
    """Assert the public-repository specific files and README content."""
    assert (destination / "LICENSE").exists()
    assert (destination / ".github" / "workflows" / "codeql.yml").exists()
    assert not (destination / "PIRR.md").exists()
    assert "## License" in read_readme(destination)


def assert_non_public_visibility_outputs(destination: Path) -> None:
    """Assert the private/internal specific files and README content."""
    assert not (destination / "LICENSE").exists()
    assert not (destination / ".github" / "workflows" / "codeql.yml").exists()
    assert (destination / "PIRR.md").exists()
    assert "## License" not in read_readme(destination)


def test_public_generation(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """A public repo should include the public-only files and README section."""
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="poetry")

    assert_public_visibility_outputs(generated_project_dir)


def test_private_generation(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """A private repo should omit public-only files and include a PIRR."""
    copier_runner.copy(generated_project_dir, repository_visibility="private", package_manager="poetry")

    assert_non_public_visibility_outputs(generated_project_dir)


def test_internal_generation(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """An internal repo should behave the same as a private repo."""
    copier_runner.copy(generated_project_dir, repository_visibility="internal", package_manager="poetry")

    assert_non_public_visibility_outputs(generated_project_dir)


def test_regeneration_public_to_private_cleans_stale_files(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """Regenerating into the same directory should remove stale public files."""
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="poetry")
    copier_runner.copy(generated_project_dir, repository_visibility="private", package_manager="poetry")

    assert_non_public_visibility_outputs(generated_project_dir)


def test_regeneration_private_to_public_cleans_stale_files(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """Regenerating into the same directory should remove stale private files."""
    copier_runner.copy(generated_project_dir, repository_visibility="private", package_manager="poetry")
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="poetry")

    assert_public_visibility_outputs(generated_project_dir)


def test_poetry_generation_outputs(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """The Poetry option should emit Poetry files and omit Pipenv files."""
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="poetry")

    assert (generated_project_dir / "pyproject.toml").exists()
    assert (generated_project_dir / "poetry.lock").exists()
    assert (generated_project_dir / ".pre-commit-config.yaml").exists()
    assert not (generated_project_dir / "Pipfile").exists()
    assert not (generated_project_dir / "Pipfile.lock").exists()
    assert 'pre-commit = "^4.3.0"' in (generated_project_dir / "pyproject.toml").read_text(encoding="utf-8")
    assert "poetry run pre-commit run --all-files" in read_makefile(generated_project_dir)
    assert "entry: make mypy" in read_pre_commit_config(generated_project_dir)
    assert "entry: poetry check" in read_pre_commit_config(generated_project_dir)
    assert "entry: poetry lock" in read_pre_commit_config(generated_project_dir)


def test_pipenv_generation_outputs(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """The Pipenv option should emit Pipenv files and remove Poetry lock data."""
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="pipenv")

    assert (generated_project_dir / "pyproject.toml").exists()
    assert (generated_project_dir / "Pipfile").exists()
    assert (generated_project_dir / "Pipfile.lock").exists()
    assert (generated_project_dir / ".pre-commit-config.yaml").exists()
    assert not (generated_project_dir / "poetry.lock").exists()
    assert 'pre-commit = "*"' in (generated_project_dir / "Pipfile").read_text(encoding="utf-8")
    assert "pipenv run pre-commit run --all-files" in read_makefile(generated_project_dir)
    assert "entry: pipenv verify" in read_pre_commit_config(generated_project_dir)
    assert "entry: pipenv lock" in read_pre_commit_config(generated_project_dir)


def test_uv_generation_outputs(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """The uv option should emit uv files and omit Poetry and Pipenv files."""
    copier_runner.copy(
        generated_project_dir,
        repository_visibility="public",
        package_manager="uv",
        confirm_uv_prerelease="true",
    )

    readme = read_readme(generated_project_dir)

    assert (generated_project_dir / "pyproject.toml").exists()
    assert (generated_project_dir / "uv.lock").exists()
    assert (generated_project_dir / ".pre-commit-config.yaml").exists()
    assert not (generated_project_dir / "poetry.lock").exists()
    assert not (generated_project_dir / "Pipfile").exists()
    assert not (generated_project_dir / "Pipfile.lock").exists()
    assert '"pre-commit>=4.3.0"' in (generated_project_dir / "pyproject.toml").read_text(encoding="utf-8")
    assert "We recommend using [uv](https://docs.astral.sh/uv/)" in readme
    assert "pyenv" not in readme
    assert "cache: uv" not in read_ci_workflow(generated_project_dir)
    assert "pipx install uv==0.11.26" in read_ci_workflow(generated_project_dir)
    assert "uv run pre-commit run --all-files" in read_makefile(generated_project_dir)
    assert "entry: uv lock --check" in read_pre_commit_config(generated_project_dir)
    assert "entry: uv lock" in read_pre_commit_config(generated_project_dir)


def test_regeneration_poetry_to_uv_cleans_stale_files(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """Switching from Poetry to uv should remove Poetry-only files."""
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="poetry")
    copier_runner.copy(
        generated_project_dir,
        repository_visibility="public",
        package_manager="uv",
        confirm_uv_prerelease="true",
    )

    assert (generated_project_dir / "uv.lock").exists()
    assert not (generated_project_dir / "poetry.lock").exists()
    assert not (generated_project_dir / "Pipfile").exists()
    assert not (generated_project_dir / "Pipfile.lock").exists()


def test_regeneration_pipenv_to_uv_cleans_stale_files(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """Switching from Pipenv to uv should remove Pipenv-only files."""
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="pipenv")
    copier_runner.copy(
        generated_project_dir,
        repository_visibility="public",
        package_manager="uv",
        confirm_uv_prerelease="true",
    )

    assert (generated_project_dir / "uv.lock").exists()
    assert not (generated_project_dir / "poetry.lock").exists()
    assert not (generated_project_dir / "Pipfile").exists()
    assert not (generated_project_dir / "Pipfile.lock").exists()


def test_regeneration_uv_to_poetry_cleans_stale_files(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """Switching from uv to Poetry should remove uv files."""
    copier_runner.copy(
        generated_project_dir,
        repository_visibility="public",
        package_manager="uv",
        confirm_uv_prerelease="true",
    )
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="poetry")

    assert (generated_project_dir / "poetry.lock").exists()
    assert not (generated_project_dir / "uv.lock").exists()
    assert not (generated_project_dir / "Pipfile").exists()
    assert not (generated_project_dir / "Pipfile.lock").exists()


def test_regeneration_uv_to_pipenv_cleans_stale_files(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """Switching from uv to Pipenv should remove uv files."""
    copier_runner.copy(
        generated_project_dir,
        repository_visibility="public",
        package_manager="uv",
        confirm_uv_prerelease="true",
    )
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="pipenv")

    assert (generated_project_dir / "Pipfile").exists()
    assert (generated_project_dir / "Pipfile.lock").exists()
    assert not (generated_project_dir / "poetry.lock").exists()
    assert not (generated_project_dir / "uv.lock").exists()


def test_uv_generation_requires_confirmation(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """The uv option should reject an explicit decision not to use uv."""
    import subprocess

    with pytest.raises(subprocess.CalledProcessError) as exc_info:
        copier_runner.copy(
            generated_project_dir,
            repository_visibility="public",
            package_manager="uv",
            confirm_uv_prerelease="false",
        )

    assert "You must confirm the use of uv to continue" in exc_info.value.stderr
