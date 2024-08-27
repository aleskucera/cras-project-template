#!/bin/bash

print_usage() {
    cat <<EOF
Initialize the catkin workspace for the project. This script should
not be run directly. Instead, use the start_singularity.sh script to start the
singularity container and then run this script inside the container.
EOF
}

# ============= START: Source the variables and utility functions =============

# Source the variables and utility functions
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/vars.sh"
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/utils.sh"

# ============= END: Source the variables and utility functions =============

init_workspace() {
  # Check if the catkin workspace is initialized
  cd "${WORKSPACE_DIR}" || exit 1
  if [ ! -d build ] || [ ! -d devel ]; then
    info_log "Initializing the catkin workspace."
    source /opt/ros/noetic/setup.bash
    rosdep update
    rosdep install --from-paths src --ignore-src -r -y
    catkin build -DPYTHON_EXECUTABLE=/usr/bin/python3
  else
    info_log "The catkin workspace is already initialized."
  fi
}

update_packages() {
  if ! is_online; then
    warn_log "You do not seem to be online. Not updating the packages."
    return
  fi

  # Update the repositories specified in the packages.repos file
  cd "${WORKSPACE_DIR}/src" || exit 1
  vcs import < "/.config/packages.repos"
}

main() {
  # Check if the singularity container is running
  if [ "$APPTAINER_NAME" != "$(basename "${IMAGE_FILE}")" ]; then
    error_log "You are not inside the apptainer container. 
    Please start the container first using start_container.sh."
    exit 1
  fi

  # Update the packages
  echo
  echo "====================== UPDATING PACKAGES ======================"
  echo

  update_packages

  echo
  echo "==============================================================="
  echo

  # Initialize the workspace
  init_workspace

  # Sleep for a while to let the user read the messages
  sleep 1

  # Start the interactive bash
  info_log "Starting interactive bash"
  cd "${WORKSPACE_DIR}" || exit 1
  bash
}

main "$@"
