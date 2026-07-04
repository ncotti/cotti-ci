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
MSG_RUNNING="Checking for licenses and copyright notices in the following file extensions: %s"
MSG_OK="All files have their license and copyright notices."

MSG_USAGE=$(cat <<EOF
${BOLD_MAGENTA}Usage:${NC}
    ${0} <target_dir> <license> <copyright> <file extensions ...>

Where:
* ${BOLD}${UNDERLINE}<target_dir>${NC}: Root directory from where all files will be evaluated.
* ${BOLD}${UNDERLINE}<license>${NC}: The string \"SPDX-License-Identifier: <license>\" will be searched on all source and header files.
* ${BOLD}${UNDERLINE}<copyright>${NC}: This string will be searched on all source and header files verbatim.
* ${BOLD}${UNDERLINE}<file_extensions>${NC}: White-space separated list of file extensions that should have a license and copyright in their header.
EOF
)

MSG_WRONG_USAGE="Wrong or missing parameters."

MSG_TARGET_DIR_IS_NOT_A_DIR="target_dir is not a directory: %s"

MSG_NO_FILE_EXTENSIONS="At least one file extension must be provided."
MSG_NO_FILES_CHECKED="No files matched the provided file extensions."
MSG_CHECKED_FILES="Total files checked: %d"
MSG_FAILING_FILES="Failing files:"
MSG_OK_FILES="Compliant files:"

###############################################################################
# Arguments and argument validation
###############################################################################
target_dir="$1"
license="$2"
copyright="$3"

if [ -z "${target_dir}" ]; then
    error "${MSG_WRONG_USAGE}"
    printf "${MSG_USAGE}\n"
    exit 1
fi

if [ ! -d "${target_dir}" ]; then
    error "${MSG_TARGET_DIR_IS_NOT_A_DIR}" "${target_dir}"
    exit 1
fi

if [ -z "${license}" ]; then
    error "${MSG_WRONG_USAGE}"
    printf "${MSG_USAGE}\n"
    exit 1
fi

if [ -z "${copyright}" ]; then
    error "${MSG_WRONG_USAGE}"
    printf "${MSG_USAGE}\n"
    exit 1
fi

shift 3;
file_extensions=""
while [ $# -gt 0 ]; do
    file_extensions="${file_extensions} $1"
    shift
done

if [ -z "${file_extensions}" ]; then
    error "${MSG_NO_FILE_EXTENSIONS}"
    printf "${MSG_USAGE}\n"
    exit 1
fi

###############################################################################
# Script
###############################################################################
export files_with_no_license_or_copyright=""
export files_ok=""
export files_checked=0

function check_license() {
    local files="$1"

    for file in ${files}; do
        if  ! head -n 5 "${file}" | grep -q "SPDX-License-Identifier: ${license}" ||
            ! head -n 5 "${file}" | grep -q "${copyright}"; then
            files_with_no_license_or_copyright="${file}\n${files_with_no_license_or_copyright}"
        else
            files_ok="${file}\n${files_ok}"
        fi
        files_checked=$((files_checked + 1))
    done
}

info "${MSG_RUNNING}" "${file_extensions}"
for file_extension in ${file_extensions}; do
    check_license "$(find "${target_dir}" -type f -name "*${file_extension}" -print)"
done

if [ "${files_checked}" -eq 0 ]; then
    error "${MSG_NO_FILES_CHECKED}"
    exit 1
fi

info "${MSG_CHECKED_FILES}" "${files_checked}"
info "${MSG_OK_FILES}"
printf "${files_ok}"
if [ -n "${files_with_no_license_or_copyright}" ]; then
    error "${MSG_FAILING_FILES}"
    printf "${files_with_no_license_or_copyright}"
    exit 1
fi

ok "${MSG_OK}"
