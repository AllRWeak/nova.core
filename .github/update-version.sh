#!/bin/bash

# Setting variables
version_file="${{ vars.PROJECT_VERSION_FILE }}"

# Configuring git
git config --global user.name "${{ vars.PROJECT_CI_USERNAME }}"
git config --global user.email "${{ vars.PROJECT_CI_EMAIL }}"

# Updating the version if UPDATE_VERSION is true
if [ ${{ vars.PROJECT_UPDATE_VERSION }} = true ]; then

    # Updating the version
    version_row_old=$(grep "version: " $version_file)
    version=$(echo $version_row_old | cut -d: -f2)
    major=$(echo $version | cut -d. -f1)
    minor=$(echo $version | cut -d. -f2)
    patch=$(echo $version | cut -d. -f3)
    patch_new=$(( $patch+1 ))
    version_row_new="version: $major.$minor.$patch_new"
    sed -i "s/$version_row_old/$version_row_new/" $version_file

    TAG_NAME="v$major.$minor.$patch_new"
    echo "LATEST_TAG=$TAG_NAME" >> $GITHUB_ENV

    # Adding the changed file to git
    git add $version_file

    # Committing the change
    git commit -m "Set ${{ vars.PROJECT_NAME }} version to $major.$minor.$patch_new"
    git push

fi

# Tagging and pushing the change
git tag $TAG_NAME
git push origin $TAG_NAME

# Creating temp changelog file
git log --pretty=format:"- %s" $(git describe --tags --abbrev=0 HEAD^^)..HEAD > CHANGELOG.md