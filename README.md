# CRAS Project Template

This repository contains a template for the CRAS project, designed to provide a well-structured starting point for new projects based on the CRAS architecture. The template utilizes the Apptainer container system to ensure consistent and reproducible environments for your development and deployment processes.

## Documentation structure

The documentation is structured as follows:

- [CRAS Project Template](#cras-project-template)
  - [Documentation structure](#documentation-structure)
  - [Why use the containers?](#why-use-the-containers)
  - [Repository structure](#repository-structure)
  - [Requirements](#requirements)
  - [How to create a project's container](#how-to-create-a-projects-container)
    - [Configure the project](#configure-the-project)
    - [Build the images](#build-the-images)
    - [Upload the images to the remote server](#upload-the-images-to-the-remote-server)
  - [How to use the project's container](#how-to-use-the-projects-container)
  - [Creating Overlays for a Container](#creating-overlays-for-a-container)
- [Possible improvements](#possible-improvements)

## Why use the containers?

Containers are lightweight, portable environments that package everything needed to run a project, from code and libraries to system tools and settings. Using containers provides several advantages:

1. **Reproducibility:** A container encapsulates the entire runtime environment, ensuring that the project behaves the same regardless of where it's run. Whether it's your local machine or a remote server, as long as Apptainer is installed, the project will run identically.

2. **Isolation:** Containers isolate the project environment from the host system, which means you don’t need to worry about conflicts between dependencies on the host and those required by the project. This is especially useful when working with multiple projects with differing requirements.

3. **Portability:** You can build the container on one machine and share or deploy it on another with ease. Once the container is created, anyone with access to it can run the project without manually setting up the environment.

4. **Efficiency:** Compared to virtual machines, containers are more lightweight, with faster startup times and less overhead, making them ideal for development workflows and cloud-based environments.
  
Apptainer, used in this template, is a highly efficient container platform optimized for scientific computing and high-performance computing (HPC) workloads.

## Repository structure

The repository is organized into several key directories:

```
├── build
│   ├── amd64.def
│   ├── arm64.def
│   ├── jetson.def
│   └── ...
├── commands
├── config
├── docs
├── env
├── images
├── logs
├── scripts
└── workspace
    ├── src
    └── ...
```

- `build` - Contains Apptainer definition files, which specify how to build the container images for different architectures. More details can be found in the [Build documentation](docs/build.md).
- `commands` - Houses custom commands that can be executed within the container. Refer to the [Commands documentation](docs/commands.md) for more information.
- `config` - Configuration files for the project, including environment settings and other project-specific options. See [Config documentation](docs/config.md).
- `env` - Contains environment scripts that are sourced when the container starts. Learn more in the [Environment documentation](docs/environment.md).
- `images` - Directory where built or downloaded Apptainer images are stored.
- `logs` - Logs generated during the image-building process.
- `scripts` - Contains various scripts for tasks such as building containers, running them, and uploading images to remote servers. Check out the [Scripts documentation](docs/scripts.md) for more details.
- `workspace` - Directory for your project’s source code.
  
## Requirements

To build and use the containers, you'll need the following software installed:

- [Apptainer](https://apptainer.org/) - used for building and running the containers.
- [SSHPass](https://www.cyberciti.biz/faq/noninteractive-shell-script-ssh-password-provider/) - used to provide a password when uploading the images to a remote server.

These dependencies will be installed automatically when necessary.

## How to create a project's container

### Configure the project

Before building your project's container, you'll need to configure it by modifying files in the `config` directory. For detailed guidance on configuring the project, refer to the [Config documentation](docs/config.md).

Additionally, update the function name in the `setup.sh` script to reflect your project's name. For example, if your project is called `my_project`, update the function name as follows:

```bash
    ...
    # TODO: Change the name of this function to match 
    # the name of your project
    # | | | | | | 
    # v v v v v v
    my_project() {
        local option="$1"
        shift
    ...
```

Afterward, add the following line to your `.bashrc` file, substituting the correct path to your `setup.sh` script:

```bash
source /path/to/setup.sh
```

This will allow you to use the project’s scripts as shell commands. If you prefer not to modify your `.bashrc`, you can source the `setup.sh` script manually.

### Build the images

Once the project is configured, you can build the container images by running the following command:

```bash
cras_project build_image
```

This will generate the appropriate container image in the `images` directory. More information on the build process can be found in the [Build documentation](docs/build.md).

### Upload the images to the remote server

After building the images, you can upload them to a remote server for others to use. To do this, execute:

```bash
cras_project upload_image
```

For more on uploading and downloading images, refer to the [Scripts documentation](docs/scripts.md).

## How to use the project's container

Once the container images have been built and uploaded, you can download and run them on any machine. To download the images, use the following command:

```bash
cras_project download_image
```

After downloading the images, you can start the container and run the project with:

```bash
cras_project start_container
```

## Creating Overlays for a Container

To modify or add files to a container image, you can create an overlay. For example if you want to install a package in the container, you can follow these steps:

1. **Create an Overlay**  
   Run the following command to generate an overlay image inside the `overlays` directory:
   ```bash
   cras_project create_overlay
    ```
2. **Run the Container With the Overlay**
   Suppose you want to install the `nmap` package. To do this, start the container with the `--overlay` option using `sudo`:
    ```bash
    sudo cras_project start_container --overlay
    ```
3. **Install the Desired Package**  
   Once the container is running, install the package using `apt`:
   ```bash
   apt update
   apt install nmap
   ```
4. **Exit the Container and Run It Without `sudo`**
    After installing the package, exit the container and run it without `sudo`:
    ```bash
    cras_project start_container
    ```
5. **Verify the Package Installation**
    To confirm that the `nmap` package is installed, run:
    ```bash
    nmap --version
    ```

# Possible improvements

- [ ] Add catkin config
- [ ] Build images automatically
- [ ] Rosinstall dependencies
