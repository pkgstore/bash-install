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

# Variables.
ORG='pkgstore'

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

function download() {
  local dir; dir="${NAME}.$( date '+%s' ).tmp"
  local ref; ref='tags'; [[ "${TAG}" == 'main' ]] && ref='heads'
  local url; url="https://github.com/${ORG}/${NAME}/archive/refs/${ref}/${TAG}.tar.gz"
  mkdir -p "${dir}" && { cd "${dir}" || exit 1; } && curl -fLo "${NAME}-${TAG}.tar.gz" "${url}"
}

function unpack() {
  tar -xzf "${NAME}-${TAG}.tar.gz" && { cd "${NAME}-${TAG}" || exit 1; }
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
