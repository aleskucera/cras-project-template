# Get the project folder
PROJECT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
SCRIPTS_DIR="${PROJECT_DIR}/scripts"

cras_project() {
    # Function that has multiple options: build_image, start_container, download_image, upload_image
    # If the option is selected, pass all additional arguments to the script
    
    local option="$1"
    shift

    case "$option" in
        build_image)
            # Build the image
            "${SCRIPTS_DIR}/build_image" "$@"
            ;;
        start_container)
            # Start the container
            "${SCRIPTS_DIR}/start_container" "$@"
            ;;
        download_image)
            # Download the image
            "${SCRIPTS_DIR}/transfer_image" "download" "$@"
            ;;
        upload_image)
            # Upload the image
            "${SCRIPTS_DIR}/transfer_image" "upload" "$@"
            ;;
        create_overlay)
            # Create an overlay
            "${SCRIPTS_DIR}/create_overlay" "$@"
            ;;
        *)
            echo "Invalid option: $option"
            ;;
    esac
}

# Create an autocomplete function for cras_project
_cras_project_autocomplete() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="build_image start_container download_image upload_image create_overlay"

    # Autocomplete for the main options
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    fi

    return 0
}

# Register the autocomplete function for cras_project
complete -F _cras_project_autocomplete cras_project



