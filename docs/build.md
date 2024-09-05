# Apptainer Build

The Apptainer build process is defined in the `build` directory
of the project. Currently, there are three definition files in this directory: `amd64.def`, `arm64.def`, and `jetson.def`. The `amd64.def` file is used for building the container on an x86_64 machine, the `arm64.def` file is used for building the container on an aarch64 machine, and the `jetson.def` file is used for building the container on a Jetson device. 

> **Info:** Even though the `Jetson` device is an aarch64 machine, it requires a different definition file because of the different libraries and dependencies that are needed for building the container.

The build process is defined in the definition files using the syntax for the [Apptainer definition files](https://apptainer.org/docs/user/main/definition_files.html). 

> **Warning:** The build process relies heavily on the [Project Configuration]. So before changing the build process in the definition files, make sure to check the configuration files in the `config` directory.

## Building the image

To build the image, simply run

```bash
cras_project build_image
```

This script will build the image for the current architecture. If you want to build the image for a different architecture, you can specify the architecture as an argument to the script. Building the image for the different architecture is not supported yet.