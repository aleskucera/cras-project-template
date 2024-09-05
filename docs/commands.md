# Custom Commands

In apptainer we might want to use custom commands, that are specificaly suited for our project. As showcase there is a `hello_apptainer` command that is defined in the `commands` directory. You can test this command in the apptainer container by running the following command:

```bash
hello_apptainer
```

the output should be:

```bash __________________________________
< Hello from within the container! >
 ----------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

You can also create your own custom commands by creating a new script in the `commands` directory. The script should have a shebang line at the top (e.g. `#!/bin/bash`). The scripts are made executable and sourced during the build process, so you can will have to rebuild the container in order to use the new command.