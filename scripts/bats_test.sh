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
MSG_RUNNING="Running BATS tests..."
MSG_OK="All tests finished successfully."

MSG_USAGE=$(cat <<EOF
${BOLD_MAGENTA}Usage:${NC}
    ${0} <target_dir>

Where:
* ${BOLD}${UNDERLINE}<target_dir>${NC}: Directory where the bats tests are.
EOF
)

MSG_WRONG_USAGE="Wrong or missing parameters."

MSG_TARGET_DIR_IS_NOT_A_DIR="target_dir is not a directory: %s"

MSG_NO_TESTS_FOUND="target_dir: \"%s\" is valid, but there are no tests in it."

MSG_INSTALL_FAIL="Couldn't find BATS as a submodule in your repo."

###############################################################################
# Arguments and argument validation
###############################################################################
target_dir="$1"

if [ -z "${target_dir}" ]; then
    error "${MSG_WRONG_USAGE}"
    printf "${MSG_USAGE}\n"
    exit 1
fi

if [ ! -d "${target_dir}" ]; then
    error "${MSG_TARGET_DIR_IS_NOT_A_DIR}" "${target_dir}"
    exit 1
fi

# Check if there are at least one valid ".bats" test file in the target dir
if ! compgen -G "${target_dir}/*.bats" >/dev/null; then
    error "${MSG_NO_TESTS_FOUND}" "${target_dir}"
    exit 1
fi

###############################################################################
# Tool installation
###############################################################################
# Try to find the submodules for bats
BATS=""
if ! which bats; then
    info "Searching for bats submodule in your repo..."
    bats_submodules="$(cd "${target_dir}" && git submodule status | grep 'bats' | awk '{print $2}')"
    if [ -n "${bats_submodules}" ]; then
        #shellcheck disable=SC2086  # Allow word splitting for ${bats_submodules}
        cd "${target_dir}" && git submodule update --init ${bats_submodules}

        for submodule in ${bats_submodules}; do
            printf "%s\n" "${target_dir}/${submodule}/bin/bats"
            if [ -x "${target_dir}/${submodule}/bin/bats" ]; then
                BATS="${target_dir}/${submodule}/bin/bats"
                break
            fi
        done
    fi
else
    BATS=$(which bats)
fi

if [ -z "${BATS}" ]; then
    error "${MSG_INSTALL_FAIL}"
    exit 1
fi

info "Found BATS executable at: %s" "${BATS}"

###############################################################################
# Script
###############################################################################
info "${MSG_RUNNING}"
"${BATS}" "${target_dir}"
ok "${MSG_OK}"
