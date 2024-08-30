FROM nixos/nix AS runner

# Setup home location
ENV HOME="${HOME_PATH:-/root}"
ENV IS_FROM_CONTAINER=true
# Set up unofficial builds for nvm
ENV NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release
# (Optional) Disable IOJS from appearing on ls-remote
ENV NVM_IOJS_ORG_MIRROR=https://example.com
# Setup home manager
ADD ./nix-config "$HOME/.config"
RUN nix-env --uninstall man-db
RUN nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
RUN nix-channel --update
RUN nix-shell '<home-manager>' -A install
RUN home-manager switch
RUN nix-collect-garbage --delete-old
# Get fzf. Separately obtained to get latest version and bindings
RUN git clone https://github.com/junegunn/fzf ~/.software/fzf
RUN printf "y\ny\nn" | ~/.software/fzf/install
# RUN pipx install posting && \
#   pipx install speedtest-cli
RUN git config --global --add safe.directory '*'
# Download config files
ENV USE_SSH_REMOTE="${USE_SSH_REMOTE:-false}"
ENV SETUP_TERMINAL="${SETUP_TERMINAL:-false}"
RUN curl -sSLf https://raw.githubusercontent.com/DanSM-5/user-configuration/master/setup.sh | bash
RUN touch "$HOME/.usr_conf/.uconfrc" "$HOME/.usr_conf/.ualiasrc"
RUN echo 'nvm_get_arch() { nvm_echo x64-musl; } # Needed to build the download URL' >> "$HOME/.usr_conf/.uconfrc"
RUN printf "%s" ". \$HOME/.bashrc" >> "$HOME/.bash_profile"
ADD ./prj "$HOME/.usr_conf/prj"
ADD .zsh_history "$HOME/.zsh_history"
# Install nvim plugins
# RUN ls -AlF $HOME
# Config lf
RUN ln -s $HOME/user-scripts/lf $HOME/.config/lf
# Preload theme
RUN zsh -li \
  -c 'fast-theme $HOME/.usr_conf/theme/clean.ini && nvm ls-remote'
# CLI
# call container with bash -li to use bash
CMD [ "zsh", "-li" ]

