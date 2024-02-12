# ONS Python Template

This repository serves as a template for creating a generic Python repository, equipped with basic tooling and
configuration.
The Python code in this repository is merely a placeholder, not intended for practical use. The concept is that one can
create a new repository from
this template and add their own code, whilst inheriting the necessary tooling and configuration.

This uses
the [Use this template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)
feature to create the repo contents.
See this [demo repository](https://github.com/ONSdigital/ons-python-template-demo) for an example created from this
template.

## Contents

- [What does this template include?](#what-does-this-template-include)
- [How to use this template](#how-to-use-this-template)
    - [Post-Clone Steps](#post-clone-steps)
        - [Repository Settings](#repository-settings)
        - [MegaLinter](#megalinter)
            - [Auto-fixing linting issues via GitHub Actions](#auto-fixing-linting-issues-via-github-actions)
- [Structure](#structure)
- [Design Decisions](#design-decisions)
- [Alternatives Software/Tools](#alternatives-softwaretools)
- [TODO](#todo)

## What does this template include?

- Python package management with [Poetry](https://python-poetry.org/).
- Python Linting/Formatting with:
    - [Ruff](https://github.com/astral-sh/ruff) (An all-in-one alternative to tools such as)
        - [flake8](https://flake8.pycqa.org/en/latest/)
        - [isort](https://pycqa.github.io/isort/)
        - [pydocstyle](https://www.pydocstyle.org/en/stable/index.html)
        - [pyupgrade](https://github.com/asottile/pyupgrade)
        - [autoflake](https://github.com/PyCQA/autoflake)
    - [pylint](https://www.pylint.org/)
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

## How to use this template

> **DO NOT FORK** this repository. Instead, use the
> **[Use this template](https://github.com/ONSdigital/ons-python-template/generate)** feature.

To get started with this template:

1. Click on **[Use this template](https://github.com/ONSdigital/ons-python-template/generate)**.
2. Name your new repository and provide a description, then click **Create repository**. Note: the repository name
   should be lowercase and use
   hyphens (`-`) instead of spaces.
3. GitHub Actions will process the template and commit to your new repository shortly after you click **Create
   repository**.. **Wait until the first
   run of GitHub Actions CI to finish!**
4. Once the **Rename Project** CI action has run, clone the repo and start working on your project.

> **NOTE**: **WAIT** until first CI run of **Rename Project** job before cloning your new project.

### Post-Clone Steps

#### Repository Settings

Familiarise yourself with the [ONS GitHub Policy](https://github.com/ONSdigital/ons-template/wiki#github-policy) and
ensure your repository is compliant with the policy.

Few key points to note are:

- **[Branch Protection](https://github.com/ONSdigital/ons-template/wiki/5.7-Branch-Protection-rules)**: Ensure
  the `main` or any other primary branch
  is protected.
- **[Signed Commits](https://github.com/ONSdigital/ons-template/wiki/5.8-Signed-Commits)**: Use GPG keys to sign your
  commits.
- **[Security Alerts](https://github.com/ONSdigital/ons-template/wiki/6.2-Security)**: Make use of Secret scanning and
  Dependabot alerts.

#### MegaLinter

##### Auto-fixing linting issues via GitHub Actions

If you would like to auto-fix any issues that MegaLinter can fix in GitHub Actions, you can will need to create a
**Personal Access Token** and add it as a secret to your repository.
Without a **PAT** token, commits/PRs made by workflows do not trigger other workflows, including the MegaLinter
workflow.
This is a security feature of GitHub Actions to prevent infinite loops.
For more info,
see [MegaLinter: Auto-fixing issues](https://megalinter.io/latest/config-apply-fixes/#apply-fixes-issues).

## Structure

The structure of the templated repo is as follows:

<!-- markdownlint-disable MD013 -->

```plaintext
├── .github                           # Contains GitHub-specific configurations, including Actions workflows for CI/CD processes.
│   ├── linters                       # Directory for linting config files used by MegaLinter, e.g. .markdown-lint.json, .yaml-lint.yml etc.
│   ├── workflows                     # Directory for GitHub Actions workflows.
│   │   ├── ci.yml                    # Workflow for Continuous Integration, running tests and other checks on commits to `main` and on pull requests.
│   │   ├── codeql.yml                # CodeQL workflow for automated identification of security vulnerabilities in the codebase. (Public Repos Only)
│   │   └── mega-linter.yml           # MegaLinter workflow for linting the project.
│   ├── dependabot.yml                # Configuration for Dependabot, which automatically checks for outdated dependencies and creates pull requests to update them.
│   ├── ISSUE_TEMPLATE.md             # Template for issues raised in the repository.
│   ├── PULL_REQUEST_TEMPLATE.md      # Template for pull requests raised in the repository.
│   └── release.yml                   # Configuration on how to categorise changes into a structured changelog when using 'Generate release notes' feature.
├── project_name                      # Main Python package directory for the project, containing source code.
│   ├── __init__.py                   # Initialises the directory as a Python package, allowing its modules to be imported.
│   └── calculator.py                 # Demonstrates a simple Python class for demonstration purposes.
└── tests                             # Contains all test files.
│   ├── __init__.py                   # Marks the directory as a Python package, enabling the discovery of test modules by testing frameworks.
│   └── unit                          # Directory for unit tests, containing tests for individual components of the project.
│       ├── __init__.py               # Further organises tests into a Python package structure.
│       ├── conftest.py               # Contains pytest fixtures and configurations, applicable to all tests in the directory.
│       └── test_calculator.py        # Unit tests for the functionality provided by demo `calculator.py`.
├── .editorconfig                     # Configuration file for maintaining consistent coding styles for multiple developers working on the same project across various editors and IDEs.
├── .gitattributes                    # Git attributes file for defining attributes per path, such as line endings and merge strategies.
├── .gitignore                        # Specifies intentionally untracked files to ignore when using Git, like build outputs and temporary files.
├── .mega-linter.yml                   # Configuration file for MegaLinter, specifying the linters and code analyzers to be used.
├── .pylintrc                         # Configuration file for Pylint.
├── .python-version                   # Specifies the Python version to be used with pyenv.
├── CODE_OF_CONDUCT.md                # A code of conduct for the project, outlining the standards of behaviour for contributors.
├── CONTRIBUTING.md                   # Guidelines for contributing to the project, including information on how to raise issues and submit pull requests.
├── LICENSE                           # The license under which the project is made available.
├── Makefile                          # A script used with the make build automation tool, containing commands to automate common tasks.
├── poetry.lock                       # Lock file for Poetry, pinning exact versions of dependencies to ensure consistent builds.
├── pyproject.toml                    # Central project configuration file for Python, used by build systems like Poetry and tools like Ruff, black etc.
├── README.md                         # The main README file providing an overview of the project, setup instructions, and other essential information.
└── SECURITY.md                       # A security policy for the project, providing information on how to report security vulnerabilities.
```

<!-- markdownlint-enable MD013 -->

## Design Decisions

Although this template is opinionated, there are many alternatives to the tools used in this template which you may
prefer. See
the [Alternatives Software/Tools](#alternatives-softwaretools) section for more information.

1. Why use Poetry?

    - Poetry is a modern Python package management tool that simplifies dependency management and packaging. It is also
      a build tool that can be used
      to package your project into a distributable format.
    - Poetry is also a dependency manager that allows you to declare the libraries your project depends on and it will
      manage (install/update) them
      for you.
    - Poetry also creates a virtual environment for your project and manages the dependencies in that environment.

2. Why isn't this template made as a [Cookiecutter](https://cookiecutter.readthedocs.io/en/stable/) template?

    - Cookiecutter is a great tool for creating project templates, but it is not as well integrated with GitHub as the "
      Use this template" feature.
      The "Use this template" feature offers a more user-friendly way to create a new repository from a template, making
      it more accessible to new
      users
    - However, Cookiecutter could allow for more configuration flexibility, so it may be considered for future use.

3. Why use Ruff?

    - Ruff is a newer all-in-one alternative to tools such as flake8, isort, pydocstyle, pyupgrade, and autoflake. It is
      designed to be a more modern
      and user-friendly alternative to these tools.
    - Ruff is also designed to be more extensible and configurable than the tools it replaces.

4. Why use pylint and black when Ruff already includes these tools?

    - Ruff is a newer tool that does not yet fully implement the features of pylint and black. While fuller support is
      under development, using these
      tools in addition to Ruff is recommended for now. Once Ruff has fuller support for these tools, it is recommended
      to use Ruff as the primary
      tool for linting and formatting.

5. Why use mypy for type checking instead of pytype, pyright, or pyre?

    - mypy is a static type checker for Python that is designed to be easy to use and understand.
    - mypy is also the most widely used type checker for Python and has the most extensive documentation and community
      support.
    - However, pytype, pyright, and pyre are also good alternatives to mypy and may be considered in the future as
      alternatives or even in addition to
      mypy.

6. Why use pytest for testing instead of unittest?

    - pytest is a modern testing framework for Python that is designed to be easy to use and understand.
    - pytest is more developer-friendly than unittest and has a more extensive ecosystem of plugins and extensions.

7. What is MegaLinter?

    - MegaLinter is a ready-to-run collection of linters and code analyzers, to help validate your source code. The
      goal of super-linter is to help
      you establish best practices and consistent formatting across multiple programming languages, formats and ensure
      developers are adhering to those conventions.
    - MegaLinter is enabled in GitHub Actions and locally via Docker for languages other than Python, such as YAML,
      GitHub Actions, Shell scripts etc. It can only be run locally via Docker.
    - It is being used for other languages/extensions as a catch-all and a quick-win, however, as your project grows,
      you may want
      to consider using individual linters for each language.

8. Why is MegaLinter not used for Python?

    - While MegaLinter provides convenience by bundling multiple linters into a single package, opting for individual
      tools allows for greater flexibility and customisation to match project-specific requirements and coding
      standards.
    - You are not able to control the versions of the linters used in MegaLinter, which can lead to issues with
      compatibility and consistency.
    - Although it can easily run in CI, it requires Docker to run locally. For a basic repository with small amounts of
      Python it might be sufficient, but for more complex projects, tooling managed via pyproject.toml is encouraged.

9. Why not use SuperLinter?

    - SuperLinter is a similar tool to MegaLinter, but it is not as developer-friendly and does not have as extensive
      documentation.
    - SuperLinter does not allow auto-fixing of issues, which is a feature of MegaLinter.

10. Why this doesn't provide a full example of a Python project, i.e a Flask app, FastAPI app, etc?

    - This template is intended as a starting point for new Python projects, not as a comprehensive example. The Python
      code in this repo is not
      intended to be used for anything, it is just a placeholder. The idea is that you can create a new repo from this
      template and then add your own
      code to it but have necessary the tooling and configuration already set up.
    - However, alternative templates, such as for a Flask or FastAPI app, might be considered in the future.

11. My projects don't have a CodeQL workflow. Why?

    - CodeQL is only available for public repositories. If your repository is private/internal, the CodeQL workflow will
      not be included as it
      requires GitHub Advanced Security Enterprise plan which is currently not available for our organisation.
    - CodeQL will attempt to run when you first clone the repo, however it will fail if the repo is private/internal.
      You can safely ignore this
      failure and or remove the [CodeQL workflows run](https://github.com/author_name/project_urlname/actions) from your
      repo

## Alternatives Software/Tools

- Python package management with:

    - [pipenv](https://pipenv.pypa.io/en/latest/)
    - [pdm](https://pdm.fming.dev/)

- Linting/Formatting with:

    - [SuperLinter](https://github.com/super-linter/super-linter)
    - [pylint](https://www.pylint.org/)
    - [flake8](https://flake8.pycqa.org/en/latest/)
    - [black](https://black.readthedocs.io/en/stable/)
    - [isort](https://pycqa.github.io/isort/)
    - [pydocstyle](https://www.pydocstyle.org/en/stable/index.html)
    - [pyupgrade](https://github.com/asottile/pyupgrade)
    - [autoflake](https://github.com/PyCQA/autoflake)

- Type checking with:

    - [pytype](https://github.com/google/pytype) (Google)
    - [pyright](https://github.com/microsoft/pyright) (Microsoft)
    - [pyre](https://pyre-check.org/) (Facebook)

- Security with:

    - [bandit](https://pypi.org/project/bandit/)
    - [safety](https://pypi.org/project/safety/)

## TODO

- Add support for pre-commit hooks?
- Add CONTRIBUTING.md
- Generation using [Cookiecutter](https://cookiecutter.readthedocs.io/en/stable/) with a `cookiecutter.json` file?
    - Ability to choose your own Package Manager (Poetry, Pipenv, PDM, etc.)
    - Ability to choose your own Linting/Formatting tools
    - Ability to choose your own Type Checking tools
    - Ability to auto create the GitHub repo post generation

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

See [LICENSE](LICENSE) for details.
