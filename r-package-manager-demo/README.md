# Package Manager R Package Upload Demo

[![package-manager-demo](https://github.com/rstudio/package-manager-demo/actions/workflows/package-manager-r-demo.yml/badge.svg)](https://github.com/rstudio/package-manager-demo/actions/workflows/package-manager-r-demo.yml)

This R package demonstrates RStudio Package Manager (RSPM) functionality. 

Specifically, this demo focuses on building and uploading pre-built binaries using an API token with the CLI. For more information see [the admin guide](https://docs.rstudio.com/rspm/admin/getting-started/configuration/#quickstart-remote-cli).

## Table of Contents

- [Package Manager Demo](#package-manager-demo)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Remote Management](#remote-management)
  - [API Token Generation](#api-token-generation)
  - [Download the CLI](#download-the-cli)
  - [Build and Install the Package](#build-and-install-the-package)
  - [Upload the R Source Package](#upload-the-r-source-package)
  - [Upload the R Binary Package](#upload-the-r-binary-package)
  - [Full Example](#full-example)

## Overview

The code here contains a demo R package called `packageManagerDemo` with a single function `hello`.

Let's take a look at how to handle this R package, build the source code, pre-compile the binary package, and upload it to
RSPM for distribution and collaboration.

For a working example, see the [.github/package-manager-r-demo.yml](.github/workflows/package-manager-r-demo.yml) Github action.

## Remote Management

Package Manager supports a limited subset of commands that can be performed remotely with an API Token. This is an
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
$ rspm create source --name="api-source"
$ rspm create token -q --sources="api-source" --description="Source that contains remotely uploaded packages"
[TOKEN]
```

## Download the CLI

Since the CLI major and minor versions need to match the server, we recommend downloading the
`rspm` tool from the server directly, e.g.:

```bash
curl -fOJH "Authorization: Bearer [TOKEN]" http(s)://[YOUR-RSPM-INSTANCE]/__api__/download
chmod +x ./rspm
```

## Build and Install an R Package

Before uploading the R package, we'll need to build and install it. This can be done using the commands `R CMD build` and `R CMD INSTALL --build`, respectively. These commands will output two files, the source, and binary packages. This will look like this:

```bash
$ cd r-package-manager-demo
$ R CMD build .
* checking for file './DESCRIPTION'... OK
...
* building ‘[SRC-PKG].tar.gz’

$ R CMD INSTALL --build .
* installing to library ‘/usr/local/lib/R/4.0/site-library’
...
packaged installation of ‘[PKG]’ as ‘[BIN-PKG].tar.gz’
* DONE ([PKG])
```

## Upload the R Source Package

We recommend using environment variables for the next step to avoid leaking secrets to
any log files, bash history, etc. The two necessary environment variables are:

- `PACKAGEMANAGER_TOKEN`: This is the token from the `rspm create token` step
- `PACKAGEMANAGER_ADDRESS`: This is the HTTP(S) endpoint for the RSPM instance

Once these are set, the file from the `R CMD build` step can be uploaded directly:

```bash
rspm add --source=api-source --path=[PKG].tar.gz
```

## Upload the R Binary Package

Package Manager will autodetect the CPU architecture, R version, and package version for binary
packages, but the user will need to input a valid distro. Once the distro is known, upload the
binary package similarly:

```bash
rspm add binary --source=api-source --distribution=[DISTRO] --path=[BIN-PKG].tar.gz
```

## Full Example

Here are the steps above as a full example:

```bash
$ cd package-manager-demo/r-package-manager-demo
$ env | grep PACKAGEMANAGER
PACKAGEMANAGER_TOKEN=[REDACTED]
PACKAGEMANAGER_ADDRESS=[REDACTED]

# Build the R package
$ R CMD build .
* checking for file ‘./DESCRIPTION’ ... OK
* preparing ‘packageManagerDemo’:
* checking DESCRIPTION meta-information ... OK
* checking for LF line-endings in source and make files and shell scripts
* checking for empty or unneeded directories
* building ‘packageManagerDemo_1.0.0.tar.gz’

# Download and install the Package Manager CLI
$ curl -fOJH "Authorization: Bearer ${PACKAGEMANAGER_TOKEN}" ${PACKAGEMANAGER_ADDRESS}/__api__/download
curl: Saved to filename 'rspm'
$ chmod +x ./rspm

# Add the R source package
$ ./rspm add --source=local-api --path=packageManagerDemo_1.0.0.tar.gz
Added package 'packageManagerDemo_1.0.0.tar.gz'

# Add the R binary package
$ ./rspm add binary --source=local-api --distribution=focal --path=packageManagerDemo_1.0.0_R_x86_64-pc-linux-gnu.tar.gz
Added packageManagerDemo with version 1.0.0 for focal and R 4.1 for any architecture
```
