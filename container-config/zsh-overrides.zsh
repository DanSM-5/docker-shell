# zsh-nvm loads nvm.sh only when an NVM command is first used. nvm.sh then
# replaces any nvm_get_arch function that was defined earlier in startup.
# Wrap the lazy loader so the unofficial-builds musl architecture is selected
# after nvm.sh has loaded.
if [[ "${IS_FROM_CONTAINER:-}" == true ]] \
  && (( ${+functions[_zsh_nvm_load]} )) \
  && (( ! ${+functions[_docker_shell_nvm_load]} )); then
  functions[_docker_shell_nvm_load]=$functions[_zsh_nvm_load]

  _zsh_nvm_load() {
    _docker_shell_nvm_load "$@"

    functions[_docker_shell_nvm_get_arch]=$functions[nvm_get_arch]
    nvm_get_arch() {
      case "$(command uname -m)" in
        x86_64 | amd64)
          nvm_echo x64-musl
          ;;
        aarch64 | arm64)
          nvm_echo arm64-musl
          ;;
        *)
          _docker_shell_nvm_get_arch "$@"
          ;;
      esac
    }
  }
fi
