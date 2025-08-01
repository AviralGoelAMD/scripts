alias docker_ck='docker run --rm -it \
  --privileged \
  --group-add sudo \
  --network host \
  -w /root/workspace \
  -v "$(pwd)":/root/workspace \
  -v ~/.my_docker_bashrc:/root/.my_docker_bashrc \
  rocm/composable_kernel:ck_ub24.04_rocm6.4.1 \
  /bin/bash -c "echo '\''source ~/.my_docker_bashrc'\'' >> ~/.bashrc && exec bash"'



#### Alias to git clone repos
clone() {
  case "$1" in
    ck)
      git clone https://github.com/ROCm/composable_kernel
      cd composable_kernel || return
      if [ -n "$2" ]; then
        git checkout "$2"
      fi
      mkdir -p build
      ;;
    mlse-tools-internal)
      git clone https://github.com/ROCm/mlse-tools-internal
      ;;
    MIOpen)
      git clone https://github.com/ROCm/MIOpen
      ;;
    *)
      git clone "$@"
      ;;
  esac
}



# mkcd
mkcd() {
  mkdir -p "$1" && cd "$1"
}

alias readysetgit='git config --global --add safe.directory "$(pwd)" && \
git config --global user.name "AviralGoelAMD" && \
git config --global user.email "aviral.goel@amd.com"'
