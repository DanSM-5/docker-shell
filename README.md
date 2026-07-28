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
docker run -e TERM=xterm-256color -it edsm5/shell-config # Defaults to zsh
# use bash shell instead
docker run -e TERM=xterm-256color -it edsm5/shell-config bash -li
```

> [!WARNING]
> This container is about 4GB uncompressed. Be sure to have enough disk space and a stable internet connection.

The image intentionally leaves `TERM` to the caller because the correct value
depends on the terminal running the container. Use
`-e TERM=xterm-256color` as shown above to enable 256-color syntax
highlighting.

The container runs as the unprivileged `shell` user (UID/GID `1000`) by
default. Its home directory is `/home/shell`. To match a different host UID or
GID when building locally:

```bash
docker build \
  --build-arg USERNAME=shell \
  --build-arg USER_UID="$(id -u)" \
  --build-arg USER_GID="$(id -g)" \
  -t docker-shell .
```

Nix and Home Manager are configured through the locked flake in
`~/.config/flake.lock`. To update the locked inputs and activate the result
without root access:

```bash
cd "$HOME/.config"
nix flake update nixpkgs home-manager
home-manager switch --impure --flake .#default
```

See [Nix and Home Manager usage](docs/nix.md) for the file layout, package
changes, updates, and pinning details.

## Reading projects

Set the variable `PROJECTS` to a path within the container for the mapping `ctrl-o p` (project switch keybinding). You can use a volume for this path to allow searching in a directory within your system.

```bash
docker run \
  -e TERM=xterm-256color \
  -e PROJECTS=/tmp/projects -v "$HOME/projects:/tmp/projects" \
  -it edsm5/shell-config
```

## Using NVM

Node from Nix is available by default for Neovim and other build-time tools.
NVM can install and select additional Node versions for interactive work:

```bash
nvm install 14.9.0
nvm use 14.9.0
node -v
```

NVM uses the unofficial musl builds because the container has no traditional
Linux filesystem hierarchy. The image exposes a small, Nix-pinned musl runtime
at `/lib` so the downloaded `node` and `npm` executables can run.

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
