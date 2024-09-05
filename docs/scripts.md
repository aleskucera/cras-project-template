# Scripts

The `scripts` directory contains the scripts that are used for building the apptainer container and running apptainer container. Also they are used for downloading and uploading the images to the remote server. You can use these scripts like this:

```bash
./scripts/build_image
```

or better use would be to set up the `setup.sh` script that will wrap the scripts into the commands. Now you can use the setup script like this:

```bash
source setup.sh
cras_project build_image
```

This way you can use the scripts as commands. Feel free to modify the `setup.sh` script to suit your needs. For example change the `cras_project` to the name of your project.