FROM nixos/nix AS runner

ARG USERNAME=shell
ARG USER_UID=1000
ARG USER_GID=1000

ENV IS_FROM_CONTAINER=true
# Zsh completion plugins use Unicode characters while they initialize. The Nix
# base image does not set a locale, so default to its available UTF-8 locale.
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
# Set up unofficial builds for nvm
ENV NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release
# (Optional) Disable IOJS from appearing on ls-remote
ENV NVM_IOJS_ORG_MIRROR=https://example.com

# The base image stores its account files in the read-only Nix store. Replace
# those symlinks with regular files before creating the unprivileged account.
RUN nix-env --uninstall man-db
RUN set -eux; \
    shadow_bin="$(dirname "$(grep '^nobody:' /etc/passwd | cut -d: -f7)")"; \
    for account_file in passwd group shadow; do \
      cp "/etc/$account_file" "/etc/$account_file.new"; \
      mv "/etc/$account_file.new" "/etc/$account_file"; \
    done; \
    "$shadow_bin/groupadd" --gid "$USER_GID" "$USERNAME"; \
    "$shadow_bin/useradd" \
      --uid "$USER_UID" \
      --gid "$USER_GID" \
      --home-dir "/home/$USERNAME" \
      --create-home \
      --shell /bin/sh \
      "$USERNAME"; \
    mkdir -p "/nix/var/nix/profiles/per-user/$USERNAME"; \
    chown -R "$USER_UID:$USER_GID" "/home/$USERNAME" /nix

RUN chmod 0644 /etc/passwd /etc/group && \
    chmod 0600 /etc/shadow

ENV HOME="/home/$USERNAME"
ENV USER="$USERNAME"
ENV PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin"
ENV MANPATH="$HOME/.nix-profile/share/man:/nix/var/nix/profiles/default/share/man"

USER "$USER_UID:$USER_GID"
WORKDIR "$HOME"

# Activate the locked Home Manager flake as the runtime user.
COPY --chown="$USER_UID:$USER_GID" ./nix-config "$HOME/.config"
RUN nix run --no-update-lock-file "$HOME/.config#home-manager" -- \
      switch \
      --impure \
      --no-write-lock-file \
      --flake "$HOME/.config#default"
RUN nix-collect-garbage --delete-old
# RUN pipx install posting && \
#   pipx install speedtest-cli
RUN git config --global --add safe.directory '*'
# Download config files
ENV USE_SSH_REMOTE=false
ENV SETUP_TERMINAL=false
RUN set -eux; \
    curl -sSLf \
      -o /tmp/user-configuration-setup.sh \
      https://raw.githubusercontent.com/DanSM-5/user-configuration/master/setup.sh; \
    bash /tmp/user-configuration-setup.sh; \
    rm /tmp/user-configuration-setup.sh
RUN touch "$HOME/.usr_conf/.uconfrc" "$HOME/.usr_conf/.ualiasrc"
COPY --chown="$USER_UID:$USER_GID" \
  ./container-config/zsh-overrides.zsh \
  "$HOME/.zsh-container-overrides.zsh"
RUN printf '%s\n' \
      'source "$HOME/.zsh-container-overrides.zsh"' \
      >> "$HOME/.zshrc"
RUN printf "%s" ". \$HOME/.bashrc" >> "$HOME/.bash_profile"
COPY --chown="$USER_UID:$USER_GID" ./prj "$HOME/.usr_conf/prj"
COPY --chown="$USER_UID:$USER_GID" .zsh_history "$HOME/.zsh_history"
RUN printf "y\ny\nn" | ~/user-scripts/fzf/install
RUN oh-my-posh disable notice
# Install nvim plugins
# RUN ls -AlF $HOME
# Config lf
RUN ln -s $HOME/user-scripts/lf $HOME/.config/lf
# Preload theme
RUN zsh -li \
  -c 'fast-theme $HOME/.usr_conf/theme/clean.ini; \
      nvm --version >/dev/null; \
      case "$(uname -m)" in \
        x86_64|amd64) test "$(nvm_get_arch)" = x64-musl ;; \
        aarch64|arm64) test "$(nvm_get_arch)" = arm64-musl ;; \
      esac'
# CLI
# call container with bash -li to use bash
CMD [ "zsh", "-li" ]
