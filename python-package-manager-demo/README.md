# Package Manager Demo

[![package-manager-demo](https://github.com/rstudio/package-manager-demo/actions/workflows/package-manager-demo.yml/badge.svg)](https://github.com/rstudio/package-manager-demo/actions/workflows/package-manager-demo.yml)

This Python package demonstrates RStudio Package Manager (RSPM) functionality.

Specifically, this demo focuses on building and uploading pre-built Python distributions using an API token with Twine. For more information see [the admin guide](https://docs.rstudio.com/rspm/admin/getting-started/configuration/).

## Table of Contents

- [Package Manager Demo](#package-manager-demo)
    - [Table of Contents](#table-of-contents)
    - [Overview](#overview)
    - [Remote Management](#remote-management)
    - [API Token Generation](#api-token-generation)
    - [Download Twine](#download-twine)
    - [Build the Python Distributions](#build-the-python-distributions)
    - [Upload the Python Distribution](#upload-the-python-distribution)
    - [Full Example](#full-example)

## Overview

The code here contains a demo Python package called `package-manager-demo` with a single function `add_one`.

Let's take a look at how to handle this Python package, build the source and binary distributions, and upload it to
Package Manager for distribution and collaboration.

For a working example, see the [.github/package-manager-demo.yml](.github/workflows/package-manager-demo.yml) Github action.

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

## Download Twine

You can install Twine using `pip`:

```bash
$ pip install --index-url https://packagemanager.rstudio.com/pypi/latest/simple twine 
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

## Upload the Python Distribution

We recommend using environment variables for the next step to avoid leaking secrets to
any log files, bash history, etc. The five necessary environment variables are:

- `REPOSITORY_URL`: This is the HTTP(S) endpoint uploading Python distributions to the RSPM instance
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
$ env | grep "REPOSITORY_URL\|TWINE"
REPOSITORY_URL=$PACKAGEMANAGER_ADDRESS/upload/pypi/local-python-api
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

rspm create source --name=local-python-api --type=local-python
rspm create repo --type=python --name=local-python-api
rspm subscribe --repo=local-python-api --source=local-python-api
rspm create token -q --sources="local-python-api" --description "Python source that contains remotely upload packages"

Solo:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwYWNrYWdlbWFuYWdlciIsImp0aSI6IjBmNzRhNWY1LWQzMzYtNDg3Yi05YzgzLWNjMzM2Y2Q4MGY5MiIsImlhdCI6MTY2NjYyNzM3MywiaXNzIjoicGFja2FnZW1hbmFnZXIiLCJzY29wZXMiOnsic291cmNlcyI6IjFlNmYxZGQ1LTJlMzktNDRkNy04N2I2LWRmYjdjOTgxYjA3NCJ9fQ.FwWsFAsVHBhF0tHvNuTylPSxDK6Q6TDEEquoaz-5_mo

Cluster:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwYWNrYWdlbWFuYWdlciIsImp0aSI6ImU4Yzc5ZmQ4LTMwOWItNGM1ZS1iMjk3LTU1MDQ5MWNmMjliMSIsImlhdCI6MTY2NjYyNzQ3NSwiaXNzIjoicGFja2FnZW1hbmFnZXIiLCJzY29wZXMiOnsic291cmNlcyI6IjFiYTY0Y2ViLTg5MDAtNDg3YS05OGZkLTkyNzFmNmIwNWU4NCJ9fQ.iFXuqP24jMaYgTKW2sbPpW6JCctDSruthnHselljrxY

S3:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwYWNrYWdlbWFuYWdlciIsImp0aSI6Ijk4ZDlhMWVkLWZkZjEtNDUzOC04OGZlLTI2OTBkZDAyMGQ4ZiIsImlhdCI6MTY2NjYyNzQzNiwiaXNzIjoicGFja2FnZW1hbmFnZXIiLCJzY29wZXMiOnsic291cmNlcyI6ImU1Y2U3MmUwLWMwNGQtNDIyYS05MjE0LWE4NGY4NzRlM2M1OCJ9fQ.hkQPGOJZNIBkF1YjtU-N3BVhz3xbRSGtKxHH9CCdsME

