# Package Manager Demo

[![package-manager-demo](https://github.com/rstudio/package-manager-demo/actions/workflows/package-manager-demo.yml/badge.svg)](https://github.com/rstudio/package-manager-demo/actions/workflows/package-manager-demo.yml)

This repository is a template and demonstrates RStudio Package Manager (RSPM) functionality.

## Overview

The code here contains a demo R package called `packageManagerDemo` with a single function `hello`.

Let's take a look at how to handle this R package, build the source code, pre-compile the binary package, and upload it to
RSPM for distribution and collaboration.

For a working example, see the [.github/package-manager-demo.yml](./.github/package-manager-demo.yml) Github action.

### Remote Management

Package Manager supports a limited subset of commands that can be performed remotely with an API Token. This is an
opt-in feature, so the first step is configuring it for an RSPM instance:

```gcfg
...
[Authentication]
APITokenAuth = true
...
```

### API Token Generate

The next step is to generate an API Token. These can be created on a source-basis by running the following:

```bash
$ rspm create source --name="api-source"
$ rspm create token -q --sources="api-source" --description="Source that contains remotely uploaded packages"
[TOKEN]
```

### Download the CLI

Since the CLI major and minor versions need to match the server, we recommend downloading the
`rspm` tool from the server directly, e.g.:

```bash
curl -O -J -H "Authorization: Bearer [TOKEN]" http(s)://[YOUR-RSPM-INSTANCE]/__api__/download
chmod +x ./rspm
```

### Build and Install the Package

Before uploading the R package, we'll need to build and install it. This can be done using the commands `R CMD build` and `R CMD INSTALL --build`, respectively. These commands will output two files, the source, and binary packages. This will look like this:

```bash
$ R CMD build .

* checking for file './DESCRIPTION'... OK
...
* building ‘[SRC-PKG].tar.gz’
$ R CMD INSTALL --build .
* installing to library ‘/usr/local/lib/R/4.0/site-library’
...
packaged installation of ‘[PKG]’ as ‘[BIN-PKG].tgz’
* DONE ([PKG])

```

### Upload the source package

We recommend using environment variables for the next step to avoid leaking secrets to
any log files, bash history, etc. The two necessary environment variables are:

- `PACKAGEMANAGER_TOKEN`: This is the token from the `rspm create token` step
- `PACKAGEMANAGER_ENDPOINT`: This is the HTTP(S) endpoint for the RSPM instance

Once these are set, the file from the `R CMD build` step can be uploaded directly:

```bash
rspm add --source=api-source --path=[PKG].tar.gz
```

### Upload the binary package

Package Manager will autodetect the CPU architecture, R version, and package version for binary
packages, but the user will need to input a valid distro. Once the distro is known, upload the
binary package similarly:

```bash
rspm add binary --source=api-source --distribution=[DISTRO] --path=[BIN-PKG].tar.gz
```
