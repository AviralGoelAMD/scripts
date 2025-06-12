alias docker_ck='docker run --rm -it \
  --privileged \
  --group-add sudo \
  --network host \
  -w /root/workspace \
  -v "$(pwd)":/root/workspace \
  -v ~/.my_docker_bashrc:/root/.my_docker_bashrc \
  rocm/composable_kernel:ck_ub24.04_rocm6.4.1 \
  /bin/bash -c "echo '\''source ~/.my_docker_bashrc'\'' >> ~/.bashrc && exec bash"'

clone() {
  case "$1" in
    ck) git clone https://github.com/ROCm/composable_kernel ;;
    mlse-tools-internal) git clone https://github.com/ROCm/mlse-tools-internal ;;
    MIOpen) git clone https://github.com/ROCm/MIOpen ;;
    *) git clone "$@" ;;
  esac
}
