#!/bin/bash
set -eo pipefail  # Better error handling and exiting on error

# ============= START: Source the variables and utility functions =============

# Source the variables and utility functions
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/vars.sh"
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/utils.sh"

# ============= END: Source the variables and utility functions =============

# Check if the apptainer is installed

if is_apptainer_installed; then
    info_log "Apptainer is already installed."
    exit 0
fi

sudo apt-get -y update
sudo apt -y install software-properties-common
sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt-get -y install apptainer-suid
