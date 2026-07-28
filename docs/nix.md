# Nix and Home Manager usage

This project uses a Nix flake to install the command-line tools in the
container. A flake has two important parts:

- `flake.nix` says where dependencies come from and how to build the
  configuration.
- `flake.lock` records the exact revisions and hashes that were resolved.

As long as `flake.lock` does not change, rebuilding the image uses the same
Nixpkgs and Home Manager revisions. This pins the Nix packages as well: a
package such as Neovim is resolved from the locked Nixpkgs revision.

## Files in this project

| File | Purpose |
| --- | --- |
| `nix-config/flake.nix` | Declares Nixpkgs, Home Manager, and the musl runtime needed by NVM-downloaded Node versions. |
| `nix-config/flake.lock` | Pins the exact dependency revisions and content hashes. Commit this file. |
| `nix-config/home-manager/home.nix` | Lists the packages and user settings installed in the container. |
| `nix-config/nix/nix.conf` | Enables the `nix` command and flake features. |
| `Dockerfile` | Copies `nix-config` to `~/.config` and activates the locked configuration as the unprivileged user. |

Inside the image, the files from `nix-config` are available in
`/home/shell/.config` when the default username is used.

## Build with the locked versions

From the repository root:

```bash
docker build -t docker-shell .
```

The build uses the committed `nix-config/flake.lock`. It does not update the
lock file automatically.

## Add or remove a package

Edit the `home.packages` list in
`nix-config/home-manager/home.nix`. Package names can be searched on
[search.nixos.org/packages](https://search.nixos.org/packages).

Then build the image again:

```bash
docker build -t docker-shell .
```

If the package name is invalid or unavailable at the locked Nixpkgs revision,
the build stops with an error.

`home.nix` also contains `home.stateVersion = "24.05"`. This is a compatibility
setting, not the installed Home Manager version. Do not change it during normal
updates.

## Update Nixpkgs and Home Manager

Run this from the project checkout:

```bash
cd nix-config
nix flake update nixpkgs home-manager
cd ..
git diff -- nix-config/flake.lock
docker build -t docker-shell .
```

The update changes only `flake.lock`. Review and commit that change after the
image builds successfully. Updating Nixpkgs can change the versions of all
packages in `home.packages`; updating Home Manager can change configuration
behavior.

To update just one input, name only that input:

```bash
cd nix-config
nix flake update nixpkgs
```

or:

```bash
cd nix-config
nix flake update home-manager
```

If an update is not wanted, restore `nix-config/flake.lock` from Git and build
again.

## Apply the configuration inside a running container

The default `shell` user can update and activate the configuration without
root access:

```bash
cd "$HOME/.config"
nix flake update nixpkgs home-manager
home-manager switch --impure --flake .#default
```

`home-manager switch` builds the new user environment and makes it active.
This changes the running container and its copy of `flake.lock`; it does not
change the source repository unless that directory is mounted from the host.
For a reproducible image update, update and commit the repository's
`nix-config/flake.lock`, then rebuild the image instead.

The `--impure` option is needed because this image can be built with a custom
username, home directory, and CPU architecture. Those three values come from
the container environment. Dependency revisions still come from `flake.lock`.

## Check what is pinned

From `nix-config`:

```bash
nix flake metadata
```

The output shows the locked revision for Nixpkgs, Home Manager, and their
transitive inputs. The readable source of truth is also
`nix-config/flake.lock`.

## Channels versus flakes

`nix-channel` is still available, but channels no longer control the packages
installed by this project. In particular, `nix-channel --update` does not
update `flake.lock`. Use `nix flake update` for this configuration.

## What this lock file does not pin

The flake currently pins Nixpkgs, Home Manager, and packages obtained through
them. The separate Git repositories downloaded by `setup.sh`—for example
`user-configuration`, `user-scripts`, and the Neovim configurations—are not
yet recorded in this flake lock. They need the separate Git manifest discussed
for the next step.
