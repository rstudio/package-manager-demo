# Package Manager Python Package Upload Demo

[![package-manager-demo](https://github.com/rstudio/package-manager-demo/actions/workflows/package-manager-python-demo.yml/badge.svg)](https://github.com/rstudio/package-manager-demo/actions/workflows/package-manager-python-demo.yml)

This Python package demonstrates Posit Package Manager functionality.

Specifically, this demo focuses on building and uploading pre-built Python distributions using an API token with Twine. For more information see [the admin guide](https://docs.posit.co/rspm/admin/getting-started/configuration/#quickstart-local-python).

## Table of Contents

- [Package Manager Python Package Upload Demo](#package-manager-python-package-upload-demo)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Remote Management](#remote-management)
  - [API Token Generation](#api-token-generation)
  - [Download Twine](#download-twine)
  - [Build the Python Distributions](#build-the-python-distributions)
  - [Test the Python Distribution Locally](#test-the-python-distribution-locally)
  - [Upload the Python Distribution](#upload-the-python-distribution)
  - [Full Example](#full-example)

## Overview

The code here contains a demo Python package called `package-manager-demo` with a single function `add_one`.

Let's take a look at how to handle this Python package, build the source and binary distributions, and upload it to
Package Manager for distribution and collaboration.

For a working example, see the [.github/package-manager-python-demo.yml](.github/workflows/package-manager-python-demo.yml) Github action.

## Remote Management

Package Manager supports a limited subset of commands that can be performed remotely with an API Token. You can also use
Twine to upload Python distributions to Package Manager when API Tokens are enabled. This is an
opt-in feature, so the first step is configuring it for an RSPM instance:

```gcfg
...
[Authentication]
APITokenAuth = true
...
```

## API Token Generation

The next step is to generate an API Token. These can be created on a source-basis by running the following:

```bash
$ rspm create source --name="local-python-api" --type=local-python
$ rspm create token -q --sources="local-python-api" --description="Python source that contains remotely uploaded packages"
[TOKEN]
```

As always, make the source available to users by subscribing it to a repo: 
```bash
$ rspm create repo --name="local-python" --type=python --description="Internal Python Packages"
$ rspm subscribe --source="local-python-api" --repo="local-python"
```

## Download Twine

You can install Twine using `pip`:

```bash
$ pip install --index-url https://packagemanager.posit.co/pypi/latest/simple twine 
```

## Build the Python Distributions

Before uploading the Python package, we'll need to build it. This is done using Python:

```bash
$ cd package-manager-demo/python-package-manager-demo
$ python3 -m build
* Creating virtualenv isolated environment...
* Installing packages in isolated environment... (hatchling)
* Getting dependencies for sdist...
* Building sdist...
* Building wheel from sdist
* Creating virtualenv isolated environment...
* Installing packages in isolated environment... (hatchling)
* Getting dependencies for wheel...
* Building wheel...
Successfully built package_manager_demo-1.0.0.tar.gz and package_manager_demo-1.0.0-py3-none-any.whl
```

## Test the Python Distribution Locally

Before uploading the package, you can verify that it works locally. Create a new virtual environment, and install the package you just built.

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
pip install dist/package_manager_demo-1.0.1-py3-none-any.whl
```

Then, start a new Python REPL:

```bash
python
``` 

In the Python REPL, verify that you can use the package.

```python
>>> from package_manager_demo.example import add_one
>>> add_one(1 + 1)
3
```

## Upload the Python Distribution

We recommend using environment variables for the next step to avoid leaking secrets to
any log files, bash history, etc. The five necessary environment variables are:

- `TWINE_REPOSITORY_URL`: This is the HTTP(S) endpoint uploading Python distributions to the RSPM instance
- `TWINE_USERNAME`: This is always set to `__token__`
- `TWINE_PASSWORD`: This is the token from the `rspm create token` step

Once these are set, the Python distributions you built can be uploaded directly:

```bash
twine upload --skip-existing --verbose dist/*
```

## Full Example

Here are the steps above as a full example:

```bash
$ cd package-manager-demo/python-package-manager-demo
$ env | grep TWINE
TWINE_REPOSITORY_URL=$PACKAGEMANAGER_ADDRESS/upload/pypi/local-python-api
TWINE_USERNAME=__token__
TWINE_PASSWORD=[READACTED]

# Build the Python distributions
$ python3 -m build
* Creating virtualenv isolated environment...
* Installing packages in isolated environment... (hatchling)
* Getting dependencies for sdist...
* Building sdist...
* Building wheel from sdist
* Creating virtualenv isolated environment...
* Installing packages in isolated environment... (hatchling)
* Getting dependencies for wheel...
* Building wheel...
Successfully built package_manager_demo-1.0.0.tar.gz and package_manager_demo-1.0.0-py3-none-any.whl

# Upload with Twine
$ twine upload --skip-existing --verbose dist/*
```
