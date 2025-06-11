#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #
# BASH: INSTALLING AND UPDATING SCRIPTS
# -------------------------------------------------------------------------------------------------------------------- #
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @license    MIT
# @version    0.1.0
# @link
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID != 0 )) && { echo >&2 'This script should be run as root!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION
# -------------------------------------------------------------------------------------------------------------------- #

# Parameters.
DIR="${1:?}"; readonly DIR
NAME="${2:?}"; readonly NAME
TAG="${3:?}"; readonly TAG
ACTION="${4:-install}"; readonly ACTION

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

function download() {
  local refs; [[ "${TAG}" == 'main' ]] && refs='heads' || refs='tags'
  local url; url="https://github.com/pkgstore/${NAME}/archive/refs/${refs}/${TAG}.tar.gz"
  curl -fLo "${NAME}-main.tar.gz" "${url}"
}

function unpack() {
  tar -xzf "${NAME}-main.tar.gz" && { cd "${NAME}-main" || exit; }
}

function install_app() {
  [[ "${ACTION}" == 'update' ]] && { for i in app_*.sh; do install -m '0644' -Dt "${DIR}" "${i}"; done; return 0; }
  for i in app_*; do install -m '0644' -Dt "${DIR}" "${i}"; done;
}

function install_cron() {
  [[ "${ACTION}" == 'update' ]] && return 0
  for i in cron_*; do install -m '0644' -Dt '/etc/cron.d' "${i}"; done;
}

function perms() {
  chmod +x "${DIR}"/*.sh
}

function main() {
  download && unpack && install_app && install_cron && perms
}; main "$@"
