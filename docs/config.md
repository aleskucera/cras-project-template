# Configuring the Project

The project configuration is managed through the `config` directory, which contains several key files that control different aspects of the project setup. Below is a breakdown of the files and how they are used.

## `config.sh`

The `config.sh` file serves as the main configuration file for the project. It contains variables and functions that define critical aspects of the project’s behavior.

### Key Variables

- **`IMAGE_NAME`**: Specifies the name of the container image to be built. It’s recommended to name the image after your project for easy identification.
- **`REMOTE_SERVER`**: The address of the remote server where the container image will be uploaded and stored.
- **`REMOTE_IMAGES_PATH`**: The directory path on the remote server where the container images will be stored.

### Key Functions

There are several functions within the `config.sh` file that define what directories and files will be mounted into the container at runtime:

- **`build_common_mount_paths`**: Defines directories and files that will be mounted into the container across all architectures. These paths are shared regardless of whether you are building for x86_64, ARM, or Jetson.
- **`build_amd64_mount_paths`**, **`build_arm64_mount_paths`**, **`build_jetson_mount_paths`**: These functions define the directories and files to be mounted specifically for each respective architecture.

Each of these functions should return a string in the following format:

```bash
/path/on/host/1:/path/in/container/1,/path/on/host/2:/path/in/container/2
```

The first part represents the path on the host machine, while the second part represents the corresponding path inside the container. Paths are separated by a colon (`:`), and multiple paths are separated by commas (`,`).

> [!NOTE] 
> When generating these mount paths dynamically, there may be formatting issues, such as extra commas. However, the script will automatically correct these issues by removing any redundant commas and ensuring the format is clean before use.

## `packages.apt` and `packages.pip`

These files list the packages that will be installed inside the container.

- `packages.apt`: This file contains a list of packages to be installed via the `apt` package manager. Each package should be listed on a new line.

- `packages.pip`: This file lists Python packages that will be installed using `pip`. Like `packages.apt`, each package should be written on a separate line.
  
For both files, the installation happens during the container build process, ensuring that the necessary software dependencies are included in the environment.

## `packages.repos`

The `packages.repos` file is used to define repositories that will be cloned into the container using [vcstool](https://github.com/dirk-thomas/vcstool). This file follows the syntax defined by `vcstool` and allows you to specify version-controlled source repositories for your project.

### Supported Protocols for Repositories

In the `url` field of the `packages.repos` file, you can specify URLs using either the `https` or `git` protocol. It’s important to choose the correct protocol based on the type of repository you are working with:

- For repositories hosted on GitLab (private repositories), the `git` protocol is recommended for cloning, as it doesn’t require a password and robots have their own ssh key for pulling the repositories. This is also crucial because many users may not have a password for their GitLab accounts.
- For GitHub repositories, it is recommended to use the `https` protocol for both cloning (we assume that the repositories are public). The pushing is different, we use the `https` protocol for pushing to GitHub repositories on robots and `git` protocol for pushing to GitHub repositories on local computers.

### Summary of the Protocol Usage

Here’s a quick summary of which protocols should be used for pulling and pushing repositories:

1. #### Robots:
    - **gitlab**:
        - `push` https
        - `pull` git
    - **github**:
        - `push` https
        - `pull` https
2. #### Local Computers:
    - **gitlab**:
        - `push` git
        - `pull` git
    - **github**:
        - `push` git
        - `pull` https

By following these guidelines, you’ll ensure that repository access and authentication are handled correctly, depending on the environment and repository location.