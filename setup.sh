# Get the project folder
PROJECT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
SCRIPTS_DIR="${PROJECT_DIR}/scripts"

cras_project() {
    # Function that has multiple options: build_image, start_container, download_image, upload_image
    # If the option is selected provide additional arguments to the script
    
    local option="$1"

    case "$option" in
        build_image)
            # Build the image
            "${SCRIPTS_DIR}/build_image" "$2"
            ;;
        start_container)
            # Start the container
            "${SCRIPTS_DIR}/start_container"
            ;;
        download_image)
            # Download the image
            "${SCRIPTS_DIR}/transfer_image" "download" "$2"
            ;;
        upload_image)
            # Upload the image
            "${SCRIPTS_DIR}/transfer_image" "upload" "$2"
            ;;
        *)
            echo "Invalid option: $option"
            ;;
    esac
}