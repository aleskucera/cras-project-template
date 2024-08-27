#!/bin/bash

# Source the variables and utility functions from external scripts
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/vars.sh"

# ============= START: LOGGING =============

debug_log() {
    echo -e "${VIOLET}[DEBUG]${RESET} $1"
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

check_ssh_key_or_prompt_password() {
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
	return 1
}

is_online() {
    # Try to fetch headers from a reliable website
    curl -s --head http://www.google.com/ > /dev/null 2>&1

    # Check the exit status and return true/false
    if [ $? -eq 0 ]; then
        return 0  # true (online)
    else
        return 1  # false (offline)
    fi
}

in_apptainer() {
	[ -n "$APPTAINER_CONTAINER" ]
}

is_apptainer_installed() {
    command -v apptainer &>/dev/null
}

get_remote_image_time() {
    local creation_time
    if [ -n "$SSH_PASSWORD" ]; then
        creation_time=$(sshpass -p "${SSH_PASSWORD}" ssh -t ${USERNAME}@${REMOTE_SERVER} \
            "cat ${REMOTE_METADATA_FILE} 2>/dev/null | jq -r '.created_at // empty'" 2>/dev/null)
    else
        creation_time=$(ssh -t ${USERNAME}@${REMOTE_SERVER} \
            "cat ${REMOTE_METADATA_FILE} 2>/dev/null | jq -r '.created_at // empty'" 2>/dev/null)
    fi
    # Trim trailing whitespace (including newline characters)
    creation_time=$(echo "${creation_time}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    echo "${creation_time}"
}

get_local_image_time() {
    local creation_time=$(cat "${METADATA_FILE}" 2>/dev/null |
        jq -r '.created_at // empty')

    echo "${creation_time}"
}

compare_times() {
    local operation="$1"

    local local_image_exists=$(image_exists "local")
    local remote_image_exists=$(image_exists "remote")

    if [ "$local_image_exists" == "false" ] && [ "$operation" == "upload" ]; then
        error_log "There is no local image to upload. Exiting."
        exit 1
    fi

    if [ "$remote_image_exists" == "false" ] && [ "$operation" == "download" ]; then
        error_log "There is no remote image to download. Exiting."
        exit 1
    fi

    local local_image_time=$(get_local_image_time)
    local remote_image_time=$(get_remote_image_time)

    local local_timestamp=$(date -d "${local_image_time}" +%s 2>/dev/null)
    local remote_timestamp=$(date -d "${remote_image_time}" +%s 2>/dev/null)

    if [ -z "$local_image_time" ]; then 
        info_log "Local image does not exist. Downloading a new one." 
    elif [ -z "$remote_image_time" ]; then
        info_log "Remote image does not exist. Uploading a new one."
    elif [[ "$local_timestamp" -eq "$remote_timestamp" ]]; then  # Times are equal
        read_input "The remote image was created at the same time (${local_image_time}) as the local one. Do you want to continue? [y/N] "
    elif [[ "$local_timestamp" -gt "$remote_timestamp" ]]; then # Local time is strictly newer
        read_input "The local image was created more recently (${local_image_time}) than the remote one (${remote_image_time}). Do you want to continue? [y/N] "
    else # Remote time is strictly newer
        read_input "The remote image (${remote_image_time}) was created more recently than the local one (${local_image_time}). Do you want to continue? [y/N] "
    fi

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info_log "Aborting the $operation."
        exit 0
    fi
}

image_exists() {
    local location="$1"
    
    if [ "$location" == "remote" ]; then
        if [ -n "$SSH_PASSWORD" ]; then
            sshpass -p "${SSH_PASSWORD}" ssh -t ${USERNAME}@${REMOTE_SERVER} "test -f ${REMOTE_IMAGE_FILE}" 2>/dev/null
        else
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
    local location="$1"
    local image_exists=false
    local metadata_exists=false
    
    if [ "$location" == "remote" ]; then
        if [ -n "$SSH_PASSWORD" ]; then
            sshpass -p "${SSH_PASSWORD}" ssh -t ${USERNAME}@${REMOTE_SERVER} "test -f ${REMOTE_IMAGE_FILE}" 2>/dev/null && image_exists=true
            sshpass -p "${SSH_PASSWORD}" ssh -t ${USERNAME}@${REMOTE_SERVER} "test -f ${REMOTE_METADATA_FILE}" 2>/dev/null && metadata_exists=true
        else
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
    local operation="$1"
    local source=""
    local destination=""

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

    if [ -n "$SSH_PASSWORD" ]; then
        rsync -zP --rsh="sshpass -p ${SSH_PASSWORD} ssh" "${src_image}" "${dest_image}"
        rsync -zP --rsh="sshpass -p ${SSH_PASSWORD} ssh" "${src_metadata}" "${dest_metadata}"
    else
        rsync -zP "${src_image}" "${dest_image}"
        rsync -zP "${src_metadata}" "${dest_metadata}"
    fi
}
