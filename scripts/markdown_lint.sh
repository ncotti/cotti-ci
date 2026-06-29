#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

# shellcheck disable=SC2059    # Variable expansion in printf

## Checks whether all markdown from a target directory follow the linting
## guidelines specified in the configuration file.
## https://github.com/DavidAnson/markdownlint-cli2

set -e
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/colors.sh"
source "${SCRIPT_DIR}/common.sh"

###############################################################################
# Constants
###############################################################################
DEFAULT_CONFIG_FILE="${SCRIPT_DIR}/defaults/.markdownlint-cli2.jsonc"

MSG_NO_TARGET_DIR="No target directory argument."

MSG_TARGET_DIR_IS_NOT_A_DIR="target_dir is not a directory: %s"

MSG_USAGE=$(cat <<EOF
${BOLD_MAGENTA}Usage:${NC}
    ${0} <target_dir> [config_file]

Where:
* ${BOLD}${UNDERLINE}<target_dir>${NC}: Root directory from where all markdown files will be evaluated.
* ${BOLD}${UNDERLINE}[config_file]${NC}: .markdownlint-cli2.jsonc configuration file, relative to the <target_dir>. If not provided, a default one will be used.
EOF
)

MSG_WRONG_CONFIG_FILE="Config file does not exist: \"%s\"."

MSG_INSTALL="Did not find markdownlint-cli2, installing..."

MSG_DEFAULT_CONFIG="Using default config"

MSG_RUNNING="Running markdownlint-cli2..."
MSG_OK="Markdown files OK."

###############################################################################
# Arguments and argument validation
###############################################################################
target_dir="$1"
config_file="$2"

if [ -z "${target_dir}" ]; then
    error "${MSG_NO_TARGET_DIR}"
    printf "${MSG_USAGE}\n"
    exit 1
fi

if [ ! -d "${target_dir}" ]; then
    error "${MSG_TARGET_DIR_IS_NOT_A_DIR}" "${target_dir}"
    exit 1
fi

if [ -z "${config_file}" ]; then
    info "${MSG_DEFAULT_CONFIG}"
    config_file="${DEFAULT_CONFIG_FILE}"
fi

if [ ! -f "${config_file}" ]; then
    error "${MSG_WRONG_CONFIG_FILE}" "${config_file}"
    exit 1
fi

###############################################################################
# Tool installation
###############################################################################
if ! command -v markdownlint-cli2 &>/dev/null; then
    warning "${MSG_INSTALL}"
    sudo npm install markdownlint-cli2 --global
fi

###############################################################################
# Script
###############################################################################
info "${MSG_RUNNING}"
(cd "${target_dir}" && markdownlint-cli2 --config "${config_file}")
ok "${MSG_OK}"
