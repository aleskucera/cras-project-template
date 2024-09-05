# CRAS Project Template

This repository contains the deployment scripts for the Singularity container of the RoboTour project. The documentation contains following sections:

- [CRAS Project Template](#cras-project-template)
  - [Repository structure](#repository-structure)
  - [How to use](#how-to-use)
    - [Configure the project](#configure-the-project)
    - [Change the `setup.sh` script](#change-the-setupsh-script)
    - [Build the image](#build-the-image)
    - [Start the container](#start-the-container)

## Repository structure

The repository contains the following directories and files:

```
├── build
│   ├── amd64.apt
│   ├── arm64.pip
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

- `build` - contains the Apptainer definition files for building the container. More information about the build process can be found in the 
  [Build documentation](docs/build.md).
- `commands` - contains the custom commands that can be used in the container. More information about the custom commands can be found in the 
  [Commands documentation](docs/commands.md).
- `config` - contains the configuration files for the project. More information about the configuration can be found in the [Config documentation](docs/config.md).
- `env` - contains the environment scripts that are sourced when the container is started. More information about the environment scripts can be found in the [Environment documentation](docs/environment.md).
- `images` - contains the built or downloaded Apptainer images.
- `logs` - contains the logs from building the container.
- `scripts` - contains the scripts for building the container, running the container, and uploading the images to the remote server. More information 
  about the scripts can be found in the [Scripts documentation](docs/scripts.md).
- `workspace` - contains the source code of the project.
  
## How to use

To use the project, follow these steps:

### Configure the project

Configure the project by editing the files in the `config` directory. More information about the configuration can be found in the [Config documentation](docs/config.md).

### Change the `setup.sh` script

Change the `setup.sh` script to suit your needs. At least change the `cras_project` to the name of your project. Then add the following line to your `.bashrc` file:

```bash
source /path/to/setup.sh
```

Then you can use the scripts as commands. More information about the scripts can be found in the [Scripts documentation](docs/scripts.md).

### Build the image

To build the image, run the following command (change the `cras_project` to the name of your project):

```bash
cras_project build_image
```

More information about the build process can be found in the [Build documentation](docs/build.md).

### Start the container

To start the container, run the following command (change the `cras_project` to the name of your project):

```bash
cras_project start_container
```
