# Configuring the Project

The project can be configured via the `config` directory. The `config` directory contains the following files:

## `config.sh`

The `config.sh` file is the main configuration file for the project. It contains the following variables:

- `IMAGE_NAME`: The name of the image that will be built. It is good practice to name the image after the project.
- `REMOTE_SERVER`: The address of the remote server where the image will be stored.
- `REMOTE_IMAGES_PATH`: The path on the remote server where the images will be stored.

Then there are the following functions that are used to configure what directories and files are mounted into the container:

- `build_common_mount_paths`: This function is used to define the directories and files that are mounted into the container at the runtime. These paths will be mounted for all architectures.
- `build_amd64_mount_paths`, `build_arm64_mount_paths`, `build_jetson_mount_paths`: These functions are used to define the directories and files that are mounted into the container at the runtime. These paths will be mounted only for the specified architecture.

These functions should return a string in the following format:

```bash
/path/on/host/1:/path/in/container/1,/path/on/host/2:/path/in/container/2
```

The first part of the string is the path on the host machine, and the second part is the path in the container. The paths are separated by a colon `:` and the different paths are separated by a comma `,`.

> [!NOTE] 
> During the dynamic build of the mount paths it can happen that the format of paths is not entirely correct. For example it can happen that the mount paths are not separated by a comma but multiple commas are used. Don't worry, the script will take care of this and will correct the format of the paths. So multiple commas will be replaced by a single comma and at the start and end of the string the commas will be removed.

## `packages.apt` and `packages.pip`

The `packages.apt` and `packages.pip` files are used to define the packages that will be installed in the container. The `packages.apt` file is used to define the packages that will be installed using the `apt` package manager, and the `packages.pip` file is used to define the packages that will be installed using the `pip` package manager.

The `packages.apt` file should contain the names of the packages that will be installed using the `apt` package manager, one package per line.

The `packages.pip` file should contain the names of the packages that will be installed using the `pip` package manager, one package per line.

## `packages.repos`

The `packages.repos` file is used to define the repositories that will be added to the container using [vcstool](https://github.com/dirk-thomas/vcstool). The syntax of the file is the same as the syntax defined by the `vcstool` tool.

