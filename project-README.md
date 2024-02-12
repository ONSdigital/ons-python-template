# project_name

[![Build Status](https://github.com/author_name/project_urlname/actions/workflows/ci.yml/badge.svg)](https://github.com/author_name/project_urlname/actions/workflows/ci.yml)
[![Build Status](https://github.com/author_name/project_urlname/actions/workflows/mega-linter.yml/badge.svg)](https://github.com/author_name/project_urlname/actions/workflows/mega-linter.yml)
[![Build Status](https://github.com/author_name/project_urlname/actions/workflows/codeql.yml/badge.svg)](https://github.com/author_name/project_urlname/actions/workflows/codeql.yml)

[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Linting: Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/charliermarsh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)
[![Checked with mypy](https://www.mypy-lang.org/static/mypy_badge.svg)](https://mypy-lang.org/)
[![poetry-managed](https://img.shields.io/badge/poetry-managed-blue)](https://python-poetry.org/)
[![License - MIT](https://img.shields.io/badge/licence%20-MIT-1ac403.svg)](https://github.com/author_name/project_urlname/blob/main/LICENSE)

project_description

---

## Contents

- [Getting Started](#getting-started)
    - [Pre-requisites](#pre-requisites)
    - [Clone this repo](#clone-this-repo)
    - [Install Python using pyenv](#install-python-using-pyenv)
    - [Install dependencies](#install-dependencies)
- [Development](#development)
    - [Run Tests](#run-tests)
    - [Run Python Linting](#run-python-linting)
    - [Run Python Formatting](#run-python-formatting)
    - [MegaLinter](#megalinter)
- [Contributing](#contributing)
- [License](#license)

## Getting Started

### Pre-requisites

1. Python installed as per `.python-version`. We recommend using [pyenv](https://github.com/pyenv/pyenv) to manage your
   Python versions. Pyenv will use the `.python-version` file in the root of this repo to install the correct version of
   Python for you.
2. [Poetry](https://python-poetry.org/) installed on your machine. This is used to manage dependencies and virtual
   environments.

### Clone this repo

```bash
git clone https://github.com/author_name/project_urlname.git
```

### Install Python using pyenv

If you are not using pyenv, you can skip this step.

```bash
pyenv install --skip-existing
```

### Install dependencies

[Poetry](https://python-poetry.org/) is used to manage dependencies in this project. For more information, read
the [Poetry documentation](https://python-poetry.org/docs/).

To install all dependencies, including development dependencies, run the following command:

```bash
make install-dev
```

To install only production dependencies, run the following command:

```bash
make install
```

## Development

Before proceeding, make sure you have the development dependencies installed using the `make install-dev` command.
A Makefile is provided to simplify common development tasks. To view all available commands, run:

```bash
make
```

### Run Tests

The unit tests are written using the [pytest](https://docs.pytest.org/en/stable/) framework. To run the tests, use the
following command:

```bash
make test
```

### Run Python Linting

The project uses [Ruff](https://github.com/astral-sh/ruff), [pylint](https://www.pylint.org/)
and [black](https://black.readthedocs.io/en/stable/) for linting and formatting of the Python code. To run the linters,
use the following command:

```bash
make lint
```

### Run Python Formatting

To autoformat the Python code, and correct fixable linting issues, use the following command:

```bash
make format
```

### MegaLinter

[MegaLinter](https://github.com/oxsecurity/megalinter) is used to lint the non-python files in the project.
It provides a single interface to run linters for multiple languages/formats allowing the adoption of best practices and
consistency across the repo without needing to install each linter individually.

To run MegaLinter, you must have [Docker](https://www.docker.com/) installed on your machine. Keep in mind that the
first run make take a while to download the Docker image. However, subsequent runs will be much faster due to Docker
caching.

**Run the linter:**

_Note: This will also auto-fix any issues that MegaLinter can fix._

```bash
make megalint
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

See [LICENSE](LICENSE) for details.
