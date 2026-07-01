"""Smoke tests for Copier-based template generation."""

from __future__ import annotations

from pathlib import Path
from typing import Any


def read_readme(destination: Path) -> str:
    """Read the generated README content."""
    return (destination / "README.md").read_text(encoding="utf-8")


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
    assert not (generated_project_dir / "Pipfile").exists()
    assert not (generated_project_dir / "Pipfile.lock").exists()


def test_pipenv_generation_outputs(
    copier_runner: Any,
    generated_project_dir: Path,
) -> None:
    """The Pipenv option should emit Pipenv files and remove Poetry lock data."""
    copier_runner.copy(generated_project_dir, repository_visibility="public", package_manager="pipenv")

    assert (generated_project_dir / "pyproject.toml").exists()
    assert (generated_project_dir / "Pipfile").exists()
    assert (generated_project_dir / "Pipfile.lock").exists()
    assert not (generated_project_dir / "poetry.lock").exists()
