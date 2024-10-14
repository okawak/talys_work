#!/bin/bash

# path to the binary of talys
#talys_bin="${HOME}/repos/talys/bin/talys"
talys_bin="${HOME}/talys/bin/talys"

# work directory
current_dir=$(
  cd "$(dirname "$0")" || err "cannot get current dir"
  pwd
)

# output format
if ! command -v tput >/dev/null 2>&1; then
  printf "need 'tput' (command not found)\n"
  exit 1
fi
# shellcheck disable=SC2034
bold="$(tput bold 2>/dev/null || printf '')"
# shellcheck disable=SC2034
gray="$(tput setaf 0 2>/dev/null || printf '')"
# shellcheck disable=SC2034
underline="$(tput smul 2>/dev/null || printf '')"
# shellcheck disable=SC2034
red="$(tput setaf 1 2>/dev/null || printf '')"
# shellcheck disable=SC2034
green="$(tput setaf 2 2>/dev/null || printf '')"
# shellcheck disable=SC2034
yellow="$(tput setaf 3 2>/dev/null || printf '')"
# shellcheck disable=SC2034
blue="$(tput setaf 4 2>/dev/null || printf '')"
# shellcheck disable=SC2034
magenta="$(tput setaf 5 2>/dev/null || printf '')"
# shellcheck disable=SC2034
no_format="$(tput sgr0 2>/dev/null || printf '')"

# main structure
main() {
  if [ $# -ne 1 ]; then
    usage
    err "need correct argument"
  fi

  printf "project name: %s\n" "${yellow}$1${no_format}"
  confirm
  local yes_no="${RETVAL}"
  case ${yes_no} in
  n)
    info "cancelled"
    return
    ;;
  esac
  local project_name="$1"

  if [ ! -e "${current_dir}/talys.inp" ]; then
    err "cannot find file: talys.inp"
  fi

  cd "${current_dir}" || err "cannot move to ${current_dir}"
  if [ -d "${project_name}" ]; then
    rm -rf "${project_name}"
  fi
  mkdir "${project_name}"
  cp "talys.inp" "${project_name}/talys.inp"
  if [ -e "${current_dir}/energies" ]; then
    cp "energies" "${project_name}/energies"
  fi
  cd "${project_name}" || err "cannot move to ${project_name}"

  info "start to calculation"
  $talys_bin <"talys.inp" >"talys.out"
  info "finished!"

  cd "${current_dir}" || err "cannot move to ${current_dir}"
}

usage() {
  printf "running script for talys code\n"
  printf "need project name to store the output files!\n\n"
  printf "%s \$ ./run.sh [ARGUMENT]\n\n" "${bold}${underline}Usage:${no_format}"
  printf "%s\n" "${bold}${underline}Argument:${no_format}"
  printf "  \$1       project name \"ex.) si26a\"\n\n"
}

# useful function
info() {
  printf '%s\n' "${bold}info:${no_format} $*"
}

warn() {
  printf '%s\n' "${yellow}warning: $*${no_format}"
}

err() {
  printf '%s\n' "${red}error: $*${no_format}" >&2
  exit 1
}

blue_msg() {
  printf '%s\n' "${blue}$*${no_format}"
}

need_cmd() {
  if ! check_cmd "$1"; then
    err "need '$1' (command not found)"
  fi
}

check_cmd() {
  command -v "$1" >/dev/null 2>&1
}

confirm() {
  while true; do
    read -rp "Is it okay? (y/n): " _read_value
    case ${_read_value} in
    y)
      break
      ;;
    n)
      break
      ;;
    esac
  done
  RETVAL=${_read_value}
}

# execute part
main "$@" || exit 1
