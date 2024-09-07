#!/bin/bash

# Define the workspace directory
WORKSPACE_DIR=${WORKSPACE_DIR:-/.workspace}

# Install custom repositories
cd /.workspace/src || exit 1
vcs import < "/.config/packages.repos"

# For each repository, check if it has a *.rosinstall file and install the dependencies
for repo in $(ls); do
    if [ -f "/.workspace/src/$repo/dependencies.rosinstall" ]; then
        rosinstall . "/.workspace/src/$repo/dependencies.rosinstall"
    fi
done


# Install rosdep dependencies
cd /.workspace || exit 1
rosdep update
rosdep install --from-paths src --ignore-src -y
