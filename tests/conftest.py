"""Shared fixtures and helpers for template generation tests."""

from __future__ import annotations

import shutil
import subprocess
from collections.abc import Iterator
from pathlib import Path

import pytest

REQUIRED_TEMPLATE_ANSWERS = {
    "repository_name": "test-template",
    "repository_description": "Template generation smoke test",
    "repository_owner": "ONSdigital",
    "code_owner": "@ONSdigital/test-team",
    "default_branch": "main",
    "set_up_git_repo": "false",
}


class CopierRunner:
    """Render the template into a destination directory."""

    def __init__(self, template_root: Path, poetry_bin: str) -> None:
        self.template_root = template_root
        self.poetry_bin = poetry_bin

    def copy(self, destination: Path, **answers: str) -> subprocess.CompletedProcess[str]:
        """Run `copier copy` with a stable set of defaults for tests."""
        command = [
            self.poetry_bin,
            "run",
            "copier",
            "copy",
            "--trust",
            "--defaults",
            "--overwrite",
            "--vcs-ref=HEAD",
        ]

        merged_answers = {**REQUIRED_TEMPLATE_ANSWERS, **answers}
        for key, value in merged_answers.items():
            command.extend(["--data", f"{key}={value}"])

        command.extend([str(self.template_root), str(destination)])

        return subprocess.run(
            command,
            check=True,
            capture_output=True,
            text=True,
            cwd=self.template_root,
        )


@pytest.fixture(scope="session")
def template_root() -> Path:
    """Return the repository root containing the Copier template."""
    return Path(__file__).resolve().parents[1]


@pytest.fixture(scope="session")
def copier_bin() -> str:
    """Resolve the Poetry executable required for generation tests."""
    poetry = shutil.which("poetry")
    if poetry is None:
        pytest.skip("poetry executable is not available")
    return poetry


@pytest.fixture
def copier_runner(template_root: Path, copier_bin: str) -> CopierRunner:
    """Provide a helper that renders the template into temporary directories."""
    return CopierRunner(template_root=template_root, poetry_bin=copier_bin)


@pytest.fixture
def generated_project_dir(tmp_path: Path) -> Iterator[Path]:
    """Yield a stable destination path for repeat-render tests."""
    destination = tmp_path / "generated-project"
    yield destination
