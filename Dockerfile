FROM nixos/nix AS runner

# Setup home manager
ENV HOME="/root"
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
# Setup SpaceVim: nvim only
RUN curl -sLf https://spacevim.org/install.sh | bash -s -- --install neovim
# Last known good commit of SpaceVim
RUN cd "$HOME/.SpaceVim" && \
  git pull --unshallow && \
  git checkout 721e3118
RUN python3 -m pip install neovim
RUN pipx install posting && \
  pipx install speedtest-cli
# Download config files
ENV USE_SSH_REMOTE="${USE_SSH_REMOTE:-false}"
ENV SETUP_TERMINAL="${SETUP_TERMINAL:-false}"
ENV TERM="${TERM:-xterm-256color}"
RUN curl -sSLf https://raw.githubusercontent.com/DanSM-5/user-configuration/master/setup.sh | bash
RUN touch "$HOME/.usr_conf/.uconfrc" "$HOME/.usr_conf/.ualiasrc"
RUN printf "%s" ". \$HOME/.bashrc" >> "$HOME/.bash_profile"
ADD ./prj "$HOME/.usr_conf/prj"
# Config lf
RUN ln -s $HOME/user-scripts/lf $HOME/.config/lf
# Preload theme
RUN zsh -li \
  -c 'fast-theme $HOME/.usr_conf/theme/clean.ini'
# CLI
# First time fzf-zsh-completion.sh always fails with error
# fzf-zsh-completion.sh:4: character not in range
# but works fine after LC_ALL and LANG are exported and a new shell is opened
CMD [ "zsh", "-li", "-c", "exec zsh" ]
