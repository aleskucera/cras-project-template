#!/bin/bash

# Source the variables and utility functions from external scripts
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/vars.sh"

# ============= START: LOGGING =============

debug_log() {
    if [ "$DEBUG_MODE" != "true" ]; then
        return
    fi

    echo -e "${VIOLET}[DEBUG]${RESET} $1" >&2
}

info_log() {
    echo -e "${GREEN}[INFO]${RESET} $1"
}

warn_log() {
    echo -e "${YELLOW}[WARNING]${RESET} $1"
}

error_log() {
    echo -e "${RED}[ERROR]${RESET} $1" >&2
}

read_input() {
    echo -en "${CYAN}[INPUT]${RESET} $1"
    read -r REPLY
}

# ============= END: LOGGING =============

is_online() {
    debug_log "Checking internet connection..."

    # Try to fetch headers from a reliable website
    curl -s --head http://www.google.com/ > /dev/null 2>&1

    # Check the exit status and return true/false
    if [ $? -eq 0 ]; then
        debug_log "Online."
        return 0  # true (online)
    else
        debug_log "Offline."
        return 1  # false (offline)
    fi
}

is_robot() {
    debug_log "Checking if running on a robot..."

    source $HOME/.bashrc

    if [[ "$IS_ROBOT" == "true" ]]; then
        debug_log "Running on a robot."
        return 0
    else
        debug_log "Not running on a robot."
        return 1
    fi
}

in_apptainer() {
    debug_log "Checking if inside the apptainer container..."
	
    [ -n "$APPTAINER_CONTAINER" ]
}

is_apptainer_installed() {
    debug_log "Checking if apptainer is installed..."

    command -v apptainer &>/dev/null
}

install_sshpass() {
    debug_log "Checking if sshpass is installed..."

    if ! is_online; then
        error_log "You are offline. Please connect to the internet and try again."
        exit 1
    fi

    if ! command -v sshpass &>/dev/null
    then
        info_log "Installing sshpass..."
        sudo apt-get -y update
        sudo apt-get -y install sshpass
    fi
}

install_apptainer() {
    debug_log "Checking if apptainer is installed..."

    if ! is_online; then
        error_log "You are offline. Please connect to the internet and try again."
        exit 1
    fi

    if is_apptainer_installed; then
        info_log "Apptainer is already installed."
        exit 0
    fi

    info_log "Installing apptainer..."
    sudo apt-get -y update
    sudo apt -y install software-properties-common
    sudo add-apt-repository -y ppa:apptainer/ppa
    sudo apt-get -y install apptainer-suid
}

check_anaconda() {    
    debug_log "Checking if Conda is in ~/.bashrc..."

    source $HOME/.bashrc

    if [[ -n "$CONDA_PREFIX" ]]; then
        error_log "It appears that your ~/.bashrc file includes the Conda initialization script."
        error_log "Please modify it to prevent it from loading within the container."
        exit 1
    fi
}

debug_variables() {
    echo ""
    echo "==================== DEBUGGING VARIABLES ===================="
    echo ""

    # Debug main variables
    debug_log "${BOLD}Main variables:${RESET}"
    debug_log "IMAGE_NAME: $IMAGE_NAME"
    debug_log "PROJECT_NAME: $PROJECT_NAME"
    echo ""
    
    # Debug remote server
    debug_log "${BOLD}Remote server:${RESET}"
    debug_log "REMOTE_SERVER: $REMOTE_SERVER"
    debug_log "REMOTE_IMAGES_PATH: $REMOTE_IMAGES_PATH"
    debug_log "REMOTE_USERNAME: $REMOTE_USERNAME"
    echo ""

    # Debug hardware type
    debug_log "${BOLD}Local hardware type:${RESET}"
    debug_log "HARDWARE_TYPE: $HARDWARE_TYPE"
    echo ""

    # Debug project paths
    debug_log "${BOLD}Project paths:${RESET}"
    debug_log "PROJECT_DIR: $PROJECT_DIR"
    debug_log "ENV_DIR: $ENV_DIR"
    debug_log "LOGS_DIR: $LOGS_DIR"
    debug_log "BUILD_DIR: $BUILD_DIR"
    debug_log "CONFIG_DIR: $CONFIG_DIR"
    debug_log "IMAGES_DIR: $IMAGES_DIR"
    debug_log "SCRIPTS_DIR: $SCRIPTS_DIR"
    debug_log "OVERLAYS_DIR: $OVERLAYS_DIR"
    debug_log "COMMANDS_DIR: $COMMANDS_DIR"
    debug_log "WORKSPACE_DIR: $WORKSPACE_DIR"
    echo ""

    # Debug file paths
    debug_log "${BOLD}File paths:${RESET}"
    debug_log "IMAGE_FILE_NAME: $IMAGE_FILE_NAME"
    debug_log "METADATA_FILE_NAME: $METADATA_FILE_NAME"
    debug_log "IMAGE_FILE: $IMAGE_FILE"
    debug_log "METADATA_FILE: $METADATA_FILE"
    debug_log "REMOTE_IMAGE_FILE: $REMOTE_IMAGE_FILE"
    debug_log "REMOTE_METADATA_FILE: $REMOTE_METADATA_FILE"
    debug_log "BUILD_LOG_FILE: $BUILD_LOG_FILE"
    debug_log "DEFINITION_FILE: $DEFINITION_FILE"
    debug_log "WORKSPACE_SETUP_FILE: $WORKSPACE_SETUP_FILE"
    echo ""

    # Debug mount paths
    debug_log "${BOLD}Mount paths:${RESET}"
    debug_log "MOUNT_PATHS - AMD64: ${MOUNT_PATHS["amd64"]}"
    debug_log "MOUNT_PATHS - ARM64: ${MOUNT_PATHS["arm64"]}"
    debug_log "MOUNT_PATHS - JETSON: ${MOUNT_PATHS["jetson"]}"
}
