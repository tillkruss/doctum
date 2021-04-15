#!/bin/sh

##
# @license http://unlicense.org/UNLICENSE The UNLICENSE
# @author William Desportes <williamdes@wdes.fr>
##

set -e

VERSION="$(cat ./build/VERSION)"
VERSION_RANGE="$(cat ./build/VERSION_RANGE)"
VERSION_MAJOR="$(cat ./build/VERSION_MAJOR)"
IS_DEV_VERSION="$(echo "${VERSION_RANGE}" | grep -F -q -e '-dev' && echo '1' || echo '0')"
PHAR_COMMIT="$(git rev-parse --verify HEAD)"
# Manual switch
IS_LTS_MODE="0"

git checkout gh-pages

VERSION_ENV="dev"
VERSION_TEXT="#dev"
VERSION_TEXT_EXTRA=""

if [ ${IS_DEV_VERSION} = "0" ]; then
    VERSION_ENV="latest"
    VERSION_TEXT="#normal"
fi

if [ ${IS_LTS_MODE} = "1" ]; then
    VERSION_TEXT_EXTRA="#lts"
fi

updateLatestFolders() {
    SOURCE_FOLDER="$1"
    # Yes that could be symlinks but diffs between releases would be missed
    rm -rf releases/${VERSION_ENV}
    # Copy latest/dev to version name (example: latest to 5.1.0)
    cp -rp "${SOURCE_FOLDER}/*" ./releases/${VERSION_ENV}/
    git add -A ./releases/${VERSION_ENV}/*

    git commit -S -m "Update ${VERSION_ENV} release" -m "version: ${VERSION}" -m "version-env: ${VERSION_ENV}" -m "version-range: ${VERSION_RANGE}" -m "version-major: ${VERSION_MAJOR}" -m "${VERSION_TEXT}" -m "${VERSION_TEXT_EXTRA}" -m "Commit: ${PHAR_COMMIT}"
}

doChangesForRelease() {
    SOURCE_FOLDER="$1"
    COMMIT_TEXT="Update version ${VERSION}"
    if [ ! -d ./releases/${VERSION}/ ]; then
        COMMIT_TEXT="Release ${VERSION}"
    fi
    # Do not update major for LTS releases
    if [ ! -d ./releases/${VERSION}/ ] && [ ${IS_LTS_MODE} = "0" ]; then
        if [ -L ./releases/${VERSION_MAJOR} ]; then
            # Unlink version env
            unlink ./releases/${VERSION_MAJOR}
        fi
        # The release did not exist, so we need to update the major symlink to point to the version
        ln -s -r ./releases/${VERSION} ./releases/${VERSION_MAJOR}
        ls -lah ./releases/${VERSION_MAJOR}
        git add -A "./releases/${VERSION_MAJOR}"
    fi
    # Delete version folder even if it does not exist
    rm -rf ./releases/${VERSION}
    # Move source folder to version folder
    mv "${SOURCE_FOLDER}" ./releases/${VERSION}
    # Add to GIT index
    git add -A ./releases/${VERSION}/
    if [ -L ./releases/${VERSION_RANGE} ]; then
        # Unlink version env
        unlink ./releases/${VERSION_RANGE}
    fi
    # Link version to version range or link latest/dev to version range
    ln -s -r ./releases/${VERSION} ./releases/${VERSION_RANGE}
    ls -lah ./releases/${VERSION_RANGE}
    # Add to GIT index
    git add -A "./releases/${VERSION_RANGE}"
    # Commit the changes
    git commit -S -m "${COMMIT_TEXT}" -m "version: ${VERSION}" -m "version-range: ${VERSION_RANGE}" -m "${VERSION_TEXT}" -m "${VERSION_TEXT_EXTRA}" -m "Commit: ${PHAR_COMMIT}"
}

doChangesForRelease "./build"

if [ ${IS_LTS_MODE} = "0" ]; then
    echo 'Updating the version named folder'
    updateLatestFolders "./releases/${VERSION}"
else
    echo 'LTS mode, skipping update of version ENVs'
fi

rm -rf build/*

git checkout -
