docker-shell
==========

Configured shell based on [user-configuration](https://github.com/DanSM-5/user-configuration) and [user-scripts](https://github.com/DanSM-5/user-scripts).

The image is based on `nixos/nix`. It adds packages and config files from repositories to configure the environment for interactive use.

You can use it as a demo to test different tools or scripts from the `user-configuration` and `user-scripts`.

## Usage

Run the container with the commands:

```bash
# pull image
docker pull edsm5/shell-config:latest
# run image
docker run -e LC_ALL=C.UTF-8 -e COLORTERM -e TERM -w /root -it edsm5/shell-config # Defaults to zsh
# use bash shell instead
docker run -e LC_ALL=C.UTF-8 -e COLORTERM -e TERM -w /root -it edsm5/shell-config bash -li
```

> [!WARNING]
> This container is about 4GB uncompressed. Be sure to have enough disk space and a stable internet connection.

## Reading projects

Set the variable `PROJECTS` to a path within the container for the mapping `ctrl-o p` (project switch keybinding). You can use a volume for this path to allow searching in a directory within your system.

```bash
docker run \
  -e LC_ALL=C.UTF-8 -e COLORTERM -e TERM \
  -w /root \
  -e PROJECTS=/tmp/projects -v "$HOME/projects:/tmp/projects" \
  -it edsm5/shell-config
```

## Using auto-remove

Add `--rm` to the docker run command to auto remove the container on exit.

## Included repos

- DanSM-5/user-config
- DanSM-5/user-scripts
- DanSM-5/vim-config
- DanSM-5/omp-theme

There are some other repos included which are not relevant for the demo.

### Sync repos

On first use run `rupdate` built-in function to sync all important repos to use latest config available.
To update your current session run `spf`.

