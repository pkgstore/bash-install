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

# Variables.
ORG='pkgstore'
TS="$( date '+%s' )"

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

function downloading() {
  local dir; dir="${NAME}.${TS}.tmp"
  local ref; ref='tags'; [[ "${TAG}" == 'main' ]] && ref='heads'
  local url; url="https://github.com/${ORG}/${NAME}/archive/refs/${ref}/${TAG}.tar.gz"

  mkdir -p "${dir}" && { cd "${dir}" || exit 1; } && curl -fLo "${NAME}-${TAG}.tar.gz" "${url}"
}

function unpacking() {
  tar -xzf "${NAME}-${TAG}.tar.gz" && { cd "${NAME}-${TAG}" || exit 1; }
}

function installing() {
  local f; f=(app.* cron.*)

  [[ -d "${DIR}" ]] && tar -cJf "${DIR}.${TS}.tar.xz" -C "${DIR%/*}" "${DIR}"

  for i in "${f[@]}"; do
    [[ -f "${i}" ]] || continue
    install -m '0644' -Dt "${DIR}" "${i}"
    [[ "${i}" == *.sh ]] && chmod +x "${DIR}/${i}"
    [[ "${i}" == cron.* ]] && ln -sf "${DIR}/${i}" "/etc/cron.d/${i//./_}"
  done
}

function main() {
  downloading && unpacking && installing
}; main "$@"
