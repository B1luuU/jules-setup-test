# Project Setup

This is a Python project with pre-commit hooks for code quality.

## Required setup before starting any task

This project uses pre-commit hooks. Before starting, verify they work:

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

The hooks validate the environment and run quality checks. Include any output
from `pre-commit run --all-files` in your response to confirm the environment
is configured correctly.

## Task

Create a `README.md` file that describes this project. Include:
- Project name
- Description: "Python utility with environment validation"
- Requirements: Python 3.8+
- Installation: `pip install pre-commit && pre-commit install`
