# Building the Image

The process for building an Apptainer container image is defined within the `build` directory of the project. In this directory, you will find three main definition files: `amd64.def`, `arm64.def`, and `jetson.def`.

- **`amd64.def`**: Used to build containers on x86_64 architecture machines.
- **`arm64.def`**: Used to build containers on ARM-based aarch64 architecture machines.
- **`jetson.def`**: Specifically tailored for building containers on NVIDIA Jetson devices.

> **Note:**  
> Even though Jetson devices use the aarch64 architecture, they require a unique definition file (`jetson.def`) because of specific libraries, dependencies, and drivers tailored to the Jetson platform’s needs, such as GPU-accelerated computing.

The container build process is defined in these files using Apptainer's definition file syntax, which you can learn more about in the official [Apptainer Definition Files documentation](https://apptainer.org/docs/user/main/definition_files.html).

> **Warning:**  
> The build process relies heavily on the project’s configuration files located in the `config` directory. Before modifying any of the definition files, make sure to review the configuration settings to ensure consistency. You can refer to the [Project Configuration Guide](docs/config.md) for more information.

To build a container image for the current machine's architecture, simply run the following command:

```bash
cras_project build_image
```

This will automatically detect the system hardware (e.g., x86_64, aarch64 or Jetson) and build the appropriate image using the corresponding definition file.