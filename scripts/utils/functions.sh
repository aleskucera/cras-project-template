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

create_remote_connection() {
    debug_log "Creating a connection to the remote server..."

    # Check if sshpass is installed
    install_sshpass
    
    # Ask user if they want to specify a user for the remote server or use the current user
    info_log "Creating a connection to ${PINK}${REMOTE_SERVER}${RESET}..."
    read_input "Specify a remote username or press ${YELLOW}Enter${RESET} to use the current user: "
    USERNAME="${REPLY:-$(whoami)}"

    local attempt=0
	local max_attempts=3
    
    info_log "Attempting to connect to ${PINK}${USERNAME}@${REMOTE_SERVER}${RESET} using SSH key..."
    
	# Check if SSH key exists for the server
	if ssh -o BatchMode=yes "${USERNAME}@${REMOTE_SERVER}" true 2>/dev/null; then
		# If SSH key exists and connection is successful, set ssh_key_exists flag
		info_log "Connection to ${PINK}${REMOTE_SERVER}${RESET} successful."
		return 0
	fi

	while [ $attempt -lt $max_attempts ]; do
		if [ $attempt -eq 0 ]; then
			warn_log "No SSH key found for ${PINK}$(basename "${REMOTE_SERVER}")${RESET}. Please enter the password."
		else
			warn_log "Incorrect password. Please try again. ${RED}(Attempt $attempt/$max_attempts)${RESET}"
		fi

		read -rsp "Password: " SSH_PASSWORD
		echo

		# Attempt to connect using the provided password
		if sshpass -p "${SSH_PASSWORD}" ssh "${USERNAME}@${REMOTE_SERVER}" true 2>/dev/null; then
			export SSH_PASSWORD
            debug_log "Connection to ${PINK}${REMOTE_SERVER}${RESET} successful."
			return 0
		fi

        # Add to the attempt counter
		attempt=$((attempt + 1))
	done

	error_log "Maximum number of attempts exceeded. Exiting."
	exit 1
}

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

select_overlay() {
    debug_log "Selecting an overlay..."

    # List all available overlays (all files that end with .img inside the OVERLAYS_DIR)
    # Let the user interactively choose an overlay (list all of them each on different line and enumerate them)
    local overlays=($(ls -1 "${OVERLAYS_DIR}"/*.img))
    local overlay_count=${#overlays[@]}

    # Check if there are any overlay files
    if [ $overlay_count -eq 0 ]; then
        error_log "No overlay files found in ${OVERLAYS_DIR}. Please add an overlay file and try again."
        exit 1
    fi

    info_log "Available overlays:"
    echo ""
    for ((i = 0; i < overlay_count; i++)); do
        echo "  [$i] $(basename "${overlays[$i]}")"
    done
    echo ""

    read_input "Choose an overlay by entering the corresponding number: "
    debug_log "User input: $REPLY"

    if [[ ! $REPLY =~ ^[0-9]+$ ]]; then
        error_log "Invalid input. Exiting."
        exit 1
    fi

    if [ "$REPLY" -lt 0 ] || [ "$REPLY" -ge $overlay_count ]; then
        error_log "Invalid choice. Exiting."
        exit 1
    fi

    OVERLAY_IMAGE_FILE="${overlays[$REPLY]}"
    OVERLAY_ARG="--overlay ${OVERLAY_IMAGE_FILE}"

    debug_log "Selected overlay: ${OVERLAY_IMAGE_FILE}"
    debug_log "Overlay argument: ${OVERLAY_ARG}"
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

get_remote_image_time() {
    debug_log "Getting the remote image creation time..."

    local creation_time
    if [ -n "$SSH_PASSWORD" ]; then
        debug_log "Using sshpass to connect to the remote server..."
        creation_time=$(sshpass -p "${SSH_PASSWORD}" ssh -t ${USERNAME}@${REMOTE_SERVER} \
            "cat ${REMOTE_METADATA_FILE} 2>/dev/null | jq -r '.created_at // empty'" 2>/dev/null)
        debug_log "Remote image creation time (unformatted): $creation_time"
    else
        debug_log "Using SSH key to connect to the remote server..."
        creation_time=$(ssh -t ${USERNAME}@${REMOTE_SERVER} \
            "cat ${REMOTE_METADATA_FILE} 2>/dev/null | jq -r '.created_at // empty'" 2>/dev/null)
        debug_log "Remote image creation time (unformatted): $creation_time"
    fi
    # Trim trailing whitespace (including newline characters)
    creation_time=$(echo "${creation_time}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    debug_log "Remote image creation time (formatted): $creation_time"

    echo "${creation_time}"
}

get_local_image_time() {
    debug_log "Getting the local image creation time..."

    local creation_time=$(cat "${METADATA_FILE}" 2>/dev/null |
        jq -r '.created_at // empty')

    debug_log "Local image creation time (unformatted): $creation_time"

    echo "${creation_time}"
}

image_exists() {
    debug_log "Checking if the image file exists..."

    local location="$1"
    debug_log "Location: $location"

    install_sshpass
    
    if [ "$location" == "remote" ]; then
        if [ -n "$SSH_PASSWORD" ]; then
            debug_log "Using sshpass to connect to the remote server..."
            sshpass -p "${SSH_PASSWORD}" ssh -t ${USERNAME}@${REMOTE_SERVER} "test -f ${REMOTE_IMAGE_FILE}" 2>/dev/null
        else
            debug_log "Using SSH key to connect to the remote server..."
            ssh -t ${USERNAME}@${REMOTE_SERVER} "test -f ${REMOTE_IMAGE_FILE}" 2>/dev/null
        fi
    elif [ "$location" == "local" ]; then
        test -f "${IMAGE_FILE}"
    else
        echo "Invalid location: $location"
        return 1
    fi
}

image_files_exist() {
    debug_log "Checking if the image and metadata files exist..."

    local location="$1"
    local image_exists=false
    local metadata_exists=false

    debug_log "Location: $location"

    install_sshpass
    
    if [ "$location" == "remote" ]; then
        if [ -n "$SSH_PASSWORD" ]; then
            debug_log "Using sshpass to connect to the remote server..."
            sshpass -p "${SSH_PASSWORD}" ssh -t ${USERNAME}@${REMOTE_SERVER} "test -f ${REMOTE_IMAGE_FILE}" 2>/dev/null && image_exists=true
            sshpass -p "${SSH_PASSWORD}" ssh -t ${USERNAME}@${REMOTE_SERVER} "test -f ${REMOTE_METADATA_FILE}" 2>/dev/null && metadata_exists=true
        else
            debug_log "Using SSH key to connect to the remote server..."
            ssh -t ${USERNAME}@${REMOTE_SERVER} "test -f ${REMOTE_IMAGE_FILE}" 2>/dev/null && image_exists=true
            ssh -t ${USERNAME}@${REMOTE_SERVER} "test -f ${REMOTE_METADATA_FILE}" 2>/dev/null && metadata_exists=true
        fi
    elif [ "$location" == "local" ]; then
        [ -f "${IMAGE_FILE}" ] && image_exists=true
        [ -f "${METADATA_FILE}" ] && metadata_exists=true
    else
        echo "Invalid location: $location"
        return 1
    fi

    debug_log "Image file exists: $image_exists"
    debug_log "Metadata file exists: $metadata_exists"

    # Determine the status based on what exists
    if $image_exists && $metadata_exists; then
        return 0  # Both files exist
    elif $image_exists; then
        return 2  # Only image file exists
    elif $metadata_exists; then
        return 3  # Only metadata file exists
    else
        return 4  # Neither file exists
    fi
}


transfer_image() {
    debug_log "Transferring the image file..."

    local operation="$1"
    local source=""
    local destination=""

    debug_log "Operation: $operation"

    install_sshpass

    if [ "$operation" == "upload" ]; then
        src_image="${IMAGE_FILE}"
        src_metadata="${METADATA_FILE}"
        dest_image="${USERNAME}@${REMOTE_SERVER}:${REMOTE_IMAGE_FILE}"
        dest_metadata="${USERNAME}@${REMOTE_SERVER}:${REMOTE_METADATA_FILE}"
    elif [ "$operation" == "download" ]; then
        src_image="${USERNAME}@${REMOTE_SERVER}:${REMOTE_IMAGE_FILE}"
        src_metadata="${USERNAME}@${REMOTE_SERVER}:${REMOTE_METADATA_FILE}"
        dest_image="${IMAGE_FILE}"
        dest_metadata="${METADATA_FILE}"
    else
        echo "Invalid operation: $operation"
        return 1
    fi

    debug_log "Source image: $src_image"
    debug_log "Source metadata: $src_metadata"
    debug_log "Destination image: $dest_image"
    debug_log "Destination metadata: $dest_metadata"

    if [ -n "$SSH_PASSWORD" ]; then
        debug_log "Using sshpass to transfer the files..."
        rsync -zP --rsh="sshpass -p ${SSH_PASSWORD} ssh" "${src_image}" "${dest_image}"
        rsync -zP --rsh="sshpass -p ${SSH_PASSWORD} ssh" "${src_metadata}" "${dest_metadata}"
    else
        debug_log "Using SSH key to transfer the files..."
        rsync -zP "${src_image}" "${dest_image}"
        rsync -zP "${src_metadata}" "${dest_metadata}"
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
