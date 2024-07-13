docker-shell
==========

Configured shell based on [user-configuration](https://github.com/DanSM-5/user-configuration) and [user-scripts](https://github.com/DanSM-5/user-scripts).

The image is based on `nixos/nix`. It adds packages and config files from repositories to configure the environment for interactive use.

You can use it as a demo to test different tools or scripts from the `user-configuration` and `user-scripts`.

```bash
# pull image
docker pull edsm5/shell-config:latest
# run image
docker run -it edsm5/shell-config # Defaults to zsh
# use bash shell instead
docker run -it edsm5/shell-config bash -li
```
