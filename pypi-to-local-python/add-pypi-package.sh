#!/bin/bash

###########################
# Configuration Variables #
###########################

# top level temp directory to download packages.  Each package will download to a new subdirectory
TEMPDIR=/tmp

# if false, delete the temporary download directories after uploading
KEEP_PACKAGES=false

# name of the Package Manager python local source to add packages to
PACKAGEMANAGER_SOURCE=python

# Package Manager address and API token with permission to upload to source
PACKAGEMANAGER_ADDRESS=http://localhost:4242
PACKAGEMANAGER_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwYWNrYWdlbWFuYWdlciIsImp0aSI6ImQwOTIxZmJhLTcwNTUtNDU4Ni1iNTkwLWNkZDJiODJjMWI0NiIsImlhdCI6MTY4OTg3MjgzNCwiaXNzIjoicGFja2FnZW1hbmFnZXIiLCJzY29wZXMiOnsic291cmNlcyI6IjUzYmZlNGQyLTExYTUtNGI5Yi1iM2Q3LTc2NjU5YjExYWVlMiJ9fQ.KKTmNw32JM6IM30XCeJbadJSxGw3z6bNW0BqMwSqdus

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

####################################
# Download package files from PyPI #
####################################

PACKAGE=$1
if [ "$2" = "" ]
then
    VERSION=.info.version
else
    VERSION=\"$2\"
fi

PKGDIR=$TEMPDIR/$PACKAGE
mkdir $PKGDIR

echo
echo Downloading package files for "$PACKAGE" from PyPI...
echo

curl https://pypi.org/pypi/$PACKAGE/json | jq ".releases[$VERSION][] | .url" | xargs -n1 curl --retry 2 -O --output-dir $PKGDIR

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

######################
# Cleanup temp files #
######################

if [ "$KEEP_PACKAGES" = "false" ]
then
    rm -rf $PKGDIR
fi
exit 0
