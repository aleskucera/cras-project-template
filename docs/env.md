# Project Environment

The project environment is defined in the `env` directory of the project. The `env` directory contains the following files:

## `bashrc.sh`

The `bashrc.sh` file is the main environment file for the project. It is copied during the build process to the `/etc/bash.bashrc` file in the container. This file is sourced every time a new shell is opened in the container. You can use this file to define environment variables that are needed for the project.

> [!Note] 
> `/etc/bash.bashrc` is the system-wide `.bashrc` file in the container. It has lower priority than the user's `.bashrc` file, so the environment variables defined in the `bashrc.sh` file will not override the user's environment variables, which is neat.

## Other `.sh` files

You can also create other `.sh` files in the `env` directory to define additional environment variables. Then you can source them in the `bashrc.sh` file. This way you can keep the environment variables organized and separated by their purpose. For example there are already some files in the `env` directory:

- `bash_aliases.sh`: This file is used to define bash aliases that are needed for the project.
- `bash_exports.sh`: This file is used to define bash exports that are needed for the project.
- `bash_functions.sh`: This file is used to define bash functions that are needed for the project.
- `bash_prompt.sh`: This file is used to define the bash prompt that is used in the container.

> [!NOTE] 
> The files in the `env` directory are sourced in the order they are listed in the `bashrc.sh` file. So make sure to list the files in the correct order to avoid conflicts between the environment variables.

## `tmux.conf`

The `tmux.conf` file is the configuration file for the `tmux` terminal multiplexer. It is copied during the build process to the `/etc/tmux.conf` file in the container. This file is sourced every time a new `tmux` session is started in the container. You can use this file to define the `tmux` configuration that is needed for the project.

We have already defined some basic configuration for the `tmux` like

```bash
set-option -g default-command "bash --rcfile /etc/bash.bashrc"
```

This line will source the `/etc/bash.bashrc` file every time a new `tmux` session is started in the container. This way you can have the same environment variables in the `tmux` session as in the shell session.

```bash
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
```

These lines will change the `tmux` prefix key from `C-b` to `C-a`. This is a common configuration that is used by many people.
