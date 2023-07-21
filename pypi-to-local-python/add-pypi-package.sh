#!/bin/bash

###########################
# Configuration Variables #
###########################

# top level temp directory to download packages.  Each package will download to a new subdirectory
TEMPDIR=${TEMPDIR:-${TMPDIR:-/tmp}}

# if false, delete the temporary download directories after uploading
KEEP_PACKAGES=${KEEP_PACKAGES:-false}

# name of the Package Manager python local source to add packages to
PACKAGEMANAGER_SOURCE=${PACKAGEMANAGER_SOURCE:-python}

# Package Manager address
PACKAGEMANAGER_ADDRESS=${PACKAGEMANAGER_ADDRESS:-http://localhost:4242}


#########
# Usage #
#########

if [ "$1" = "" ]
then
    cat <<EOF
Usage: $0 package [version]

    package   name of PyPI package
    version   version of package to add.  Defaults to latest available.

EOF
    exit 1
fi

if [[ "$PACKAGEMANAGER_TOKEN" == "" ]]; then
  echo "Set the PACKAGEMANAGER_TOKEN environment variable before using this script."
  exit 1
fi

####################################
# Download package files from PyPI #
####################################

PACKAGE=$1
VERSION=${2:+\"$2\"}
VERSION=${VERSION:-.info.version}

PKGDIR=$TEMPDIR/$PACKAGE
mkdir -p $PKGDIR

cleanup () {
  if [[ "$KEEP_PACKAGES" == "false" ]]; then
    rm -rf $PKGDIR
  fi
}
trap cleanup EXIT

echo
echo Downloading package files for "$PACKAGE" from PyPI...
echo

# Get the JSON data from PyPI
url=https://pypi.org/pypi/$PACKAGE/json
json=$(curl -sf $url)
if [[ "$?" -ne 0 ]]; then
  echo "Unable to find package $PACKAGE at $url"
  exit $?
fi

# Download the files
echo $json | jq ".releases[$VERSION][] | .url" | xargs -n1 curl --retry 2 -O --output-dir $PKGDIR

#######################################################
# Add package files to internal Posit Package Manager #
#######################################################

export TWINE_REPOSITORY_URL=$PACKAGEMANAGER_ADDRESS/upload/pypi/$PACKAGEMANAGER_SOURCE
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=$PACKAGEMANAGER_TOKEN

echo
echo Uploading package files to Package Manager...
echo

twine upload --skip-existing $PKGDIR/*
