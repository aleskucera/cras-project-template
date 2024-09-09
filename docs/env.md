# Project Environment

The project environment is configured through the `env` directory, which contains various files to manage and set up the environment for your project.

## `bashrc.sh`

The `bashrc.sh` file is the primary environment file for the project. During the build process, this file is copied into the container as `/etc/bash.bashrc`, which is sourced every time a new shell is launched inside the container. You can use this file to define project-specific environment variables.

> **Note:**  
> The `/etc/bash.bashrc` file applies system-wide within the container but has lower priority than a user's personal `.bashrc`. This means any environment variables defined in `bashrc.sh` will not override user-defined variables, making it a safer way to set global variables.

## Additional `.sh` Files

You can also create other `.sh` files in the `env` directory to organize and manage additional environment variables. These files can be sourced from `bashrc.sh` to keep things modular and well-organized. For instance, here are some files already present in the `env` directory:

- **`bash_aliases.sh`**: Contains bash aliases necessary for the project.
- **`bash_exports.sh`**: Defines export statements for project-specific variables.
- **`bash_functions.sh`**: Houses any bash functions required by the project.
- **`bash_prompt.sh`**: Configures the bash prompt that will be used within the container.

> **Note:**  
> The files in the `env` directory are sourced in the order they are listed within `bashrc.sh`. Be mindful of the sequence to avoid potential conflicts between environment variables or other settings.

## `tmux.conf`

The `tmux.conf` file sets up the configuration for `tmux`, a terminal multiplexer, and is copied into the container as `/etc/tmux.conf` during the build process. This file is sourced every time a new `tmux` session starts inside the container, ensuring your `tmux` setup is consistent with your shell environment.

Here’s an example of what’s already configured:

```bash
set-option -g default-command "bash --rcfile /etc/bash.bashrc"
```

This line ensures that every new `tmux` session automatically sources the `/etc/bash.bashrc` file, giving you the same environment in both shell and `tmux` sessions.

```bash
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
```

These lines change the default `tmux` prefix key from `C-b` to `C-a`, which is a popular customization for easier use.

By configuring the environment in this way, you can maintain a clean, organized, and consistent setup for your project within the container.