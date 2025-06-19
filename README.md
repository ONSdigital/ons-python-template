# ONS Python Template

[![Build Status](https://github.com/ONSdigital/ons-python-template/actions/workflows/ci.yml/badge.svg)](https://github.com/ONSdigital/ons-python-template/actions/workflows/ci.yml)
[![Build Status](https://github.com/ONSdigital/ons-python-template/actions/workflows/mega-linter.yml/badge.svg)](https://github.com/ONSdigital/ons-python-template/actions/workflows/mega-linter.yml)
[![License - MIT](https://img.shields.io/badge/licence%20-MIT-1ac403.svg)](https://github.com/ONSdigital/ons-python-template/blob/main/LICENSE)

This repository serves as a template for creating a Python project, complete with fundamental tooling and
configuration. It is meant to help new python projects get started quickly, letting the user focus on writing code. The
template takes care of the minutia of directory structures, tool configurations, and automated testing until the user is
ready to take over.

This template is generated using [Copier](https://github.com/copier-org/copier), an open source tool for rendering
project from templates and natively supports updating projects as the original template matures.

See this [demo repository](https://github.com/ONSdigital/ons-python-template-demo) for an example created from this
template.

## Table of Contents

[//]: # (:TODO: Enable link checking once https://github.com/tcort/markdown-link-check/issues/250 is resolved.)
<!-- markdown-link-check-disable -->

- [Features](#features)
- [Getting Started](#getting-started)
    - [Using GitHub Template Feature](#using-github-template-feature)
    - [Using Copier Locally](#using-copier-locally)
    - [Post-Clone Steps](#post-clone-steps)
- [Updating Project with Template Changes][updating-project]
- [Structure](#structure)
- [Design Decisions](#design-decisions)
- [Alternatives Software/Tools][alternative-software-tools]
- [Future Plans](#future-plans)
- [Contributing](#contributing)
- [License](#license)

<!-- markdown-link-check-enable -->

## Features

This template includes a number of features to help you get started developing your Python project quickly:

- Python package/environment management with [Poetry](https://python-poetry.org/)
  or [Pipenv](https://pipenv.pypa.io/en/latest/)
- Python Linting/Formatting with:
    - [Ruff](https://github.com/astral-sh/ruff) - An all-in-one alternative to tools such as flake8, isort, pydocstyle,
      pyupgrade, autoflake etc.
    - [pylint](https://pylint.pycqa.org/en/latest/index.html)
    - [black](https://black.readthedocs.io/en/stable/)
- Type checking with [mypy](http://mypy-lang.org/).
- Testing with [pytest](https://docs.pytest.org/en/stable/)
- Code Coverage with [pytest-cov](https://pytest-cov.readthedocs.io/en/latest/)
- Continuous Integration using [GitHub Actions](https://docs.github.com/en/actions) with jobs to lint and test your
  project.
- Security with:
    - GitHub [Dependabot](https://docs.github.com/en/code-security/getting-started/dependabot-quickstart-guide)
      Security & Version Updates
    - GitHub [CodeQL](https://codeql.github.com/) Scanning (Public Repos Only)
- A Makefile containing commands to automate common tasks such as installing, testing, linting, formatting the project.
- A GitHub Issue and Pull Request template to help you get started with your project.
- Basic configuration for [EditorConfig](https://editorconfig.org/) to maintain consistent coding styles across various
  editors and IDEs.
- Extensible Python linting and formatting configuration using pyproject.toml, ensuring adherence to best practices.
- Linting the rest of the repository files/formats such as YAML, GitHub Actions, Shell scripts etc.
  using [Mega Linter](https://github.com/oxsecurity/megalinter)
- **GitHub Usage Policy Compliance** including:
    - CODEOWNERS file generation
    - Repository naming validation
    - PIRR template for private/internal repositories
    - Compliance checklist in generated README
    - Enhanced security patterns in .gitignore

## Getting Started

You have two options for project generation from this template:

- **GitHub Template Feature**: Utilise
  the [Use this template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)
  feature on GitHub to create a new repository based on this template directly from the web interface. While convenient
  and fast, this method offers limited customisation options compared to local generation.
- **Running Copier Locally**: Use Copier locally to tailor the template to your specific requirements. This method
  allows for further customisation according to your project's needs and automatically set up the repository and branch
  protection.

### Using GitHub Template Feature

> [!NOTE]
> **DO NOT FORK** this repository. Instead, use the
> **[Use this template](https://github.com/ONSdigital/ons-python-template/generate)** feature.

To get started:

1. Click on **[Use this template](https://github.com/ONSdigital/ons-python-template/generate)**
2. Name your new repository and provide a description, then click **Create repository**. *Note: the repository name
   should be lowercase and use hyphens (`-`) instead of underscores.*
3. GitHub will now copy the contents over and GitHub Actions will process the template and commit to your new repository
   shortly after you click **Create repository**.
4. **Wait until the "Rename Project from Template" job in GitHub Actions finished running!**
5. Once the **Rename Project from Template** action has run, you can clone your new repository and start working on your
   project. :rocket:

#### Known Limitations

- Some GitHub Actions workflows will fail on the first run post-clone since the repository will not be fully
  configured until the "Rename Project from Template" job has finished running. This is expected behaviour and can be
  safely ignored. Subsequent runs will not have this issue.

### Using Copier Locally

#### Prerequisites

1. **Python 3.10+**: We recommend using [pyenv](https://github.com/pyenv/pyenv) for managing Python versions.
2. **[Pip](https://pip.pypa.io/en/stable/installation/) or [Pipx](https://pipx.pypa.io/stable/)**
3. **[Copier](https://github.com/copier-org/copier)**: Install Copier using pip or pipx.

   ```bash
   pip install --user copier
   # OR
   # Install pipx and add it to your PATH and then install Copier
   pip install --user pipx && pipx ensurepath
   pipx install copier
   ```

4. **Operation System**: Ubuntu/MacOS
5. **[Git](https://git-scm.com/)**: Ensure Git is installed and configured.
6. **[GitHub CLI](https://cli.github.com/)**: [OPTIONAL] Ensure GitHub CLI is installed and you are
   authenticated (`gh auth login`) if you would like to automate the repository creation and configuration like branch
   protection.

#### Generate Project from Template

Copier will ask you a series of questions to customise the project to your needs. Once you have answered all the
questions, Copier will generate the project for you.

To generate the project run:

```bash
copier copy --trust gh:ONSdigital/ons-python-template /path/to/your/new/project
```

Replace `/path/to/your/new/project` with the path to the directory where you want to create your new project. This
directory should match the name of the repository you want to create.

#### Initialising a Git Repository and Pushing to GitHub

**This step is only required if you answered `No` to the `Do you want to set up the git repository?` question.
Otherwise, this would
have been automatically done for you.**

1. Go to your project directory, and initialise a git repository and make the initial commit

   ```bash
   cd /path/to/your/new/project
   git init -b main
   git add .
   git commit -m "Initial commit"
   ```

2. Create a new repo in GitHub.
   See [GitHub How-to](<https://docs.github.com/en/repositories/creating-and-managing-repositories/quickstart-for-repositories>]

3. Push your project to the repository on GitHub:

   ```bash
   git remote add origin https://github.com/<repository_owner>/<repository_name>.git
   git push -u origin main
   ```

Now you can start working on your project. :rocket:

To update your project when the template changes,
see [Updating Project with Template Changes][updating-project]

### Post-Clone Steps

There are a few steps you should take after cloning your new repository to ensure it is fully configured and ready for
use.

#### 1. Private Internal Reasoning Record (PIRR)

If your repository is private/internal, you should update the `PIRR.md` file in the root of your repository with the
reasoning for the private/internal status of the repository.

#### 2. Repository Settings

Familiarise yourself with the [ONS GitHub Policy](https://github.com/ONSdigital/ons-template/wiki#github-policy) and
ensure your repository is compliant with the policy.
Few key points to note are:

- **[Branch Protection](https://github.com/ONSdigital/ons-template/wiki/5.7-Branch-Protection-rules)**: Ensure
  the `main` or any other primary branch is protected.
- **[Signed Commits](https://github.com/ONSdigital/ons-template/wiki/5.8-Signed-Commits)**: Use GPG keys to sign your
  commits.
- **[Security Alerts](https://github.com/ONSdigital/ons-template/wiki/6.2-Security)**: Make use of Secret scanning and
  Push protection. Dependabot alerts will be enabled by default when using this template.

If you answered `Yes` to the `Do you want to set up the git repository?` question, then these settings would have been
automatically configured for you. However, it is recommended to review these settings to ensure they meet your
requirements.

#### 3. GitHub Usage Policy Compliance

This template helps ensure compliance with the ONS GitHub Usage Policy by automatically including:

- **CODEOWNERS file**: Automatically created with the specified code owners for the repository
- **Repository naming validation**: Enforces lowercase, hyphen/underscore naming conventions
- **Private/Internal Repository Reasoning Record (PIRR)**: Generated for non-public repositories with guidance for completion
- **Compliance checklist**: Added to the generated README to guide developers through required steps
- **Enhanced .gitignore**: Includes patterns to prevent accidental commit of sensitive files

#### 4. MegaLinter

##### Reducing the Docker image size for MegaLinter

MegaLinter is set up to use the largest Docker image by default, containing all available linters and code analysis
tools. This setup is designed for comprehensive coverage and serves as a solid starting point for new projects. However,
you might not need every tool included in this image, as it can be quite large.

To save space and optimise your setup, you can choose a more specific MegaLinter Docker image, called
a [flavor](https://megalinter.io/latest/flavors/). Each flavor includes a subset of linters and tools suited for
particular languages or frameworks.

If you're unsure which flavor is best for you, try running MegaLinter with the default set up after your project has
matured. After the run, MegaLinter will analyse the output and suggest a more suitable flavor if necessary. This helps
you customise your setup to include only the tools you need, reducing the Docker image size and improving efficiency.

##### Auto-fixing linting issues via GitHub Actions

If you would like to auto-fix issues using MegaLinter and commit the changes back to the PR, you can will need to create
a **Personal Access Token** and add it as
a [secret to your repository](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions).
Without a **PAT** token, commits/PRs made by workflows do not trigger other workflows, including the MegaLinter
workflow.
This is a security feature of GitHub Actions to prevent infinite loops.
For more info,
see [MegaLinter: Auto-fixing issues](https://megalinter.io/latest/config-apply-fixes/#apply-fixes-issues).

### Updating Project with Template Changes

> [!CAUTION]
> **CURRENTLY UNSUPPORTED**: This is currently unsupported due to
> an [upstream issue](https://github.com/copier-org/copier/issues/240) with Copier.
> Once the issue is resolved, this section will be updated with instructions on how to update your project with changes.

<details>
  <summary>View Details</summary>

You can update your project with changes made to the template since you generated your project. This is useful to keep
your project up to date with the latest tooling and configuration.

If you always used Copier with this project, getting last updates with Copier is simple:

```bash
cd ~/path/to/your/project
make copier-update
```

Copier will ask you all questions again, but default values will be those you answered last time. Just hit Enter to
accept those defaults, or change them if needed or you can use `poetry run copier update --force` instead to avoid
answering the questions again.

For more see [Copier docs](https://copier.readthedocs.io/en/stable/updating/) and `poetry run copier --help-all`.
</details>

## Structure

The structure of the templated repo is as follows:

<!-- markdownlint-disable MD013 -->

```plaintext
├── .github                           # Contains GitHub-specific configurations, including Actions workflows for CI/CD processes.
│   ├── linters                       # Directory for config files used by linter run via MegaLinter, e.g. .markdown-lint.json, .yaml-lint.yml etc.
│   ├── workflows                     # Directory for GitHub Actions workflows.
│   │   ├── ci.yml                    # Workflow for Continuous Integration, running tests and other checks on commits to `main` and on pull requests.
│   │   ├── codeql.yml                # CodeQL workflow for automated identification of security vulnerabilities in the codebase. (Public Repos Only)
│   │   └── mega-linter.yml           # MegaLinter workflow for linting the project.
│   ├── dependabot.yml                # Configuration for Dependabot, which automatically checks for outdated dependencies and creates pull requests to update them.
│   ├── ISSUE_TEMPLATE.md             # Template for issues raised in the repository.
│   ├── PULL_REQUEST_TEMPLATE.md      # Template for pull requests raised in the repository.
│   └── release.yml                   # Configuration on how to categorise changes into a structured changelog when using 'Generate release notes' feature.
├── app                               # Main Python package directory for the project, containing source code.
│   ├── __init__.py                   # Initialises the directory as a Python package, allowing its modules to be imported.
│   └── calculator.py                 # A simple Python class for demonstration purposes.
└── tests                             # Contains all test files.
│   ├── __init__.py                   # Marks the directory as a Python package, enabling the discovery of test modules by testing frameworks.
│   └── unit                          # Directory for unit tests, containing tests for individual components of the project.
│       ├── __init__.py               # Further organises tests into a Python package structure.
│       ├── conftest.py               # Contains pytest fixtures and configurations, applicable to all tests in the directory.
│       └── test_calculator.py        # Unit tests for the functionality provided by sample python code for demonstration purposes.
├── .copier-answers.yml               # Configuration file for Copier, specifying the answers to prompts when generating the project. Required for project updates.
├── .editorconfig                     # Configuration file for maintaining consistent coding styles for multiple developers working on the same project across various editors and IDEs.
├── .gitattributes                    # Git attributes file for defining attributes per path, such as line endings and merge strategies.
├── .gitignore                        # Specifies intentionally untracked files to ignore when using Git, like build outputs and temporary files.
├── .mega-linter.yml                  # Configuration file for MegaLinter, specifying the linters and code analysers to be used.
├── .pylintrc                         # Configuration file for Pylint.
├── .python-version                   # Specifies the Python version to be used with pyenv.
├── CODE_OF_CONDUCT.md                # A code of conduct for the project, outlining the standards of behaviour for contributors.
├── CONTRIBUTING.md                   # Guidelines for contributing to the project, including information on how to raise issues and submit pull requests.
├── LICENSE                           # The license under which the project is made available.
├── Makefile                          # A script used with the make build automation tool, containing commands to automate common tasks.
├── PIRR.md                           # Private Internal Reasoning Record (PIRR) for the repository, documenting the reasoning for the private/internal status of the repository. (Private/Internal Repos Only)
├── poetry.lock                       # Lock file for Poetry, pinning exact versions of dependencies to ensure consistent builds. (Exists if poetry is selected as the package manager)
├── pyproject.toml                    # Central project configuration file for Python, used by Poetry package manager and tools like Ruff, black etc.
├── Pipfile                           # Used by pipenv package manager to specify dependencies and their versions. (Exists if pipenv is selected as the package manager)
├── Pipfile.lock                      # Lock file for Poetry, pinning exact versions of dependencies to ensure consistent builds. (Exists if pipenv is selected as the package manager)
├── README.md                         # The main README file providing an overview of the project, setup instructions, and other essential information.
└── SECURITY.md                       # A security policy for the project, providing information on how to report security vulnerabilities.
```

<!-- markdownlint-enable MD013 -->

## Design Decisions

Although this template is opinionated, there are many alternatives to the tools used in this template which you may
prefer. See the [Alternatives Software/Tools][alternative-software-tools] section for more information.

*1. Why use Poetry?*

- *Poetry is a modern Python package management tool that simplifies dependency management and packaging. It is also
  a build tool that can be used*
  to package your project into a distributable format.
- *Poetry is also a dependency manager that allows you to declare the libraries your project depends on, and it will
  manage (install/update) them
  for you.*
- *Poetry also creates a virtual environment for your project and manages the dependencies in that environment.*
- *When running manually you can choose to use `pipenv` instead of `poetry` via the `package_manager` selection
  question.*

*2. What is Ruff and why use Ruff?*

- *Ruff is a newer all-in-one alternative to tools such as flake8, isort, pydocstyle, pyupgrade, and autoflake. It is
  designed to be a more modern and user-friendly alternative to these tools while being extremely fast since it is
  written in Rust.*
- *Ruff is also designed to be more extensible and configurable than the tools it replaces.*

*3. Why use pylint and black when Ruff offers similar functionality?*

- *Ruff is a newer tool that does not yet fully implement the features of pylint and black. While fuller support is
  under development, using these tools in addition to Ruff is recommended for now. Once Ruff has fuller support for
  these tools, it is recommended to use Ruff as the primary tool for linting and formatting.*

*4. Why use mypy for type checking instead of pytype, pyright, or pyre?*

- *mypy is a static type checker for Python that is designed to be easy to use and understand.*
- *mypy is also the most widely used type checker for Python and has the most extensive documentation and community
  support.*
- *Pytype, pyright, and pyre are also good alternatives to mypy and may be considered in the future as
  alternatives or even in addition to
  mypy.*

*5. Why use pytest for testing instead of unittest?*

- *pytest is a modern testing framework for Python that is designed to be easy to use and understand.*
- *pytest is more developer-friendly than unittest and has a more extensive ecosystem of plugins and extensions.*

*6. What is MegaLinter?*

- *MegaLinter is a ready-to-run collection of linters and code analysers, to help validate your source code. The
  goal of super-linter is to help you establish best practices and consistent formatting across multiple programming
  languages, formats and ensure developers are adhering to those conventions.*
- *MegaLinter is enabled in GitHub Actions and locally via Docker for languages other than Python, such as YAML,
  GitHub Actions, Shell scripts etc.*
- *It is being used for other languages/extensions as a catch-all and a quick-win, however, as your project grows,
  you may want
  to consider using individual linters for each language.*

*7. Why is MegaLinter not used for Python?*

- *While MegaLinter provides convenience by bundling multiple linters into a single package, opting for individual
  tools allows for greater flexibility and customisation to match project-specific requirements and coding
  standards.*
- *You are not able to control the versions of the linters used in MegaLinter, which can lead to issues with
  compatibility and consistency.*
- *Although it can easily run in CI, it requires Docker to run locally. For a basic repository with small amounts of
  Python it might be sufficient, but for more complex projects, tooling managed via your chosen package manager is
  encouraged.*

*8. Why not use SuperLinter?*

- *SuperLinter is a similar tool to MegaLinter, but it is not as developer-friendly and does not have as extensive
  documentation.*
- *SuperLinter does not allow auto-fixing of issues, which is a feature of MegaLinter.*

*9. Why does this not provide a full example of a Python project, i.e a Flask app, FastAPI app, Python package etc.?*

- *This template is intended as a starting point for new Python projects, not as a comprehensive example. The Python
  code in this repo is not intended to be used for anything, it is just a placeholder. The idea is that you can create a
  new repo from this template and then add your own code to it but have necessary the tooling and configuration already
  set up.*
- *Flavoured templates, such as for a Flask or FastAPI app, might be considered in the future.*

*10. My projects do not have a CodeQL workflow. Why?*

- *CodeQL is only available for public repositories. If your repository is private/internal, the CodeQL workflow will
  not be included as it requires GitHub Advanced Security Enterprise plan which is currently not available for our
  organisation.*
- *CodeQL will attempt to run when you first clone the repo, however it will fail if the repo is private/internal.
  You can safely ignore this failure and or remove the CodeQL workflows run from your repo*

*11. Why is Secret Scanning and Push Protection not enabled?*

- *Secret scanning and push protection are enabled for public repositories.*
- *Private/Internal repositories cannot use these without GitHub Advanced Security Enterprise plan which is currently
  not available for our organisation.*

## Alternatives Software/Tools

There are many alternatives to the tools used in this template, and you may prefer to use some of these alternatives.

- *Python package management with:*

    - [pdm](https://pdm.fming.dev/)
- *Linting/Formatting with:*

    - [SuperLinter](https://github.com/super-linter/super-linter)
    - [pylint](https://pylint.pycqa.org/en/latest/index.html)
    - [flake8](https://flake8.pycqa.org/en/latest/)
    - [black](https://black.readthedocs.io/en/stable/)
    - [isort](https://pycqa.github.io/isort/)
    - [pydocstyle](https://www.pydocstyle.org/en/stable/index.html)
    - [pyupgrade](https://github.com/asottile/pyupgrade)
    - [autoflake](https://github.com/PyCQA/autoflake)
- *Type checking with:*

    - [pytype](https://github.com/google/pytype) (Google)
    - [pyright](https://github.com/microsoft/pyright) (Microsoft)
    - [pyre](https://pyre-check.org/) (Facebook)
- *Security with:*

    - [bandit](https://pypi.org/project/bandit/)
    - [safety](https://pypi.org/project/safety/)

## Future Plans

- Add tests
- Add more documentation and developer guidance
- Add support for pre-commit hooks
- Further customisation options for the template:
    - Ability to choose your own Package Manager (Poetry, Pipenv, PDM, etc.)
    - Ability to choose your own Linting/Formatting tools
    - Ability to choose your own Type Checking tools
    - Ability to configure the GitHub repo setting post-generation via GitHub Template feature.
- Integrate with the ONS Software Developer Portal.
- Ability to update the project with the latest template changes.

## Development

:TODO: Add instructions for development

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

See [LICENSE](LICENSE) for details.

---

[//]: # (:TODO: Enable link checking once https://github.com/tcort/markdown-link-check/issues/250 is resolved.)
<!-- markdown-link-check-disable -->

[alternative-software-tools]: #alternatives-softwaretools

[updating-project]: #updating-project-with-template-changes
<!-- markdown-link-check-enable -->
