# Custom Commands

In Apptainer, you may want to create custom commands that are tailored to your specific project needs. As an example, this project includes a predefined command called `hello_apptainer`, located in the `commands` directory. To test this command from within the Apptainer container, simply run the following:

```bash
hello_apptainer
```

The expected output should look like this:

```bash __________________________________
< Hello from within the container! >
 ----------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

## Creating Your Own Custom Commands

You can easily create your own custom commands by adding a new script to the `commands` directory. Here’s how:

1. **Create a Script:** Write a new script in the `commands` directory with a descriptive name for your command. For example, you could create a script called `my_custom_command`.
2. **Add a Shebang:** Make sure the script starts with a shebang line (e.g., `#!/bin/bash`) to specify the interpreter.
3. **Build the Container:** After creating the script, you’ll need to rebuild the container. During the build process, all scripts in the `commands` directory are made executable and sourced, so your custom commands will be available in the container environment.

Once the container is rebuilt, you’ll be able to use your new custom command just like any other command. 

For example, if you created a script called `my_custom_command`, you could run it from within the container like this:

```bash
my_custom_command
```