#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

# shellcheck disable=SC2059    # Variable expansion in printf

set -e
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/colors.sh"
source "${SCRIPT_DIR}/common.sh"

###############################################################################
# Constants
###############################################################################
MSG_INSTALL="Did not find shellcheck, installing..."
MSG_RUNNING="Running shellcheck..."
MSG_OK="Shell scripts OK."

MSG_USAGE=$(cat <<EOF
${BOLD_MAGENTA}Usage:${NC}
    ${0} <target_dir>

Where:
* ${BOLD}${UNDERLINE}<target_dir>${NC}: Root directory from where all markdown files
  will be evaluated.
EOF
)

MSG_NO_TARGET_DIR="No target directory argument."

MSG_TARGET_DIR_IS_NOT_A_DIR="target_dir is not a directory: %s"

###############################################################################
# Arguments and argument validation
###############################################################################
target_dir="$1"

if [ -z "${target_dir}" ]; then
    error "${MSG_NO_TARGET_DIR}"
    printf "${MSG_USAGE}"
    exit 1
fi

if [ ! -d "${target_dir}" ]; then
    error "${MSG_TARGET_DIR_IS_NOT_A_DIR}" "${target_dir}"
    exit 1
fi

###############################################################################
# Tool installation
###############################################################################
if ! command -v shellcheck &>/dev/null; then
    warning "${MSG_INSTALL}"
    sudo apt install shellcheck
fi

###############################################################################
# Script
###############################################################################
info "${MSG_RUNNING}"
find "${target_dir}" -type f -name "*.sh" -exec \
    shellcheck --format=tty --severity=style -x {} +
ok "${MSG_OK}"
