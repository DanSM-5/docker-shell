docker-shell
==========

Configured shell based on [user-configuration](https://github.com/DanSM-5/user-configuration) and [user-scripts](https://github.com/DanSM-5/user-scripts).

The image is based on `nixos/nix`. It adds packages and config files from repositories to configure the environment for interactive use.

You can use it as a demo to test different tools or scripts from the `user-configuration` and `user-scripts`.

```bash
# pull image
docker pull edsm5/shell-config:latest
# run image
docker run -e LC_ALL=C.UTF-8 -e COLORTERM -e TERM -w /root -it edsm5/shell-config # Defaults to zsh
# use bash shell instead
docker run -e LC_ALL=C.UTF-8 -e COLORTERM -e TERM -w /root -it edsm5/shell-config bash -li
```

Set the variable `PROJECTS` to a path within the container for the mapping `ctrl-o p`. You can use a volume for this path to allow searching in a directory within your system.

```bash
docker run -e LC_ALL=C.UTF-8 -e COLORTERM -e TERM -w /root -e PROJECTS=/tmp/projects -v "$HOME/projects:/tmp/projects" -it edsm5/shell-config
```

