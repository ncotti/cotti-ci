#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

# shellcheck disable=SC2034     # Unused variables
# shellcheck disable=SC2059     # printf variable expansion

###############################################################################
# Global constants
###############################################################################

## Error log
function error() {
    printf "${BOLD_RED}[ERROR]${NC} "
    printf "$@"
    printf "\n"
}

## Info log
function info() {
    printf "${BOLD_MAGENTA}[INFO] ${NC} "
    printf "$@"
    printf "\n"
}

## Warning log
function warning() {
    printf "${BOLD_RED}[WARN] ${NC} "
    printf "$@"
    printf "\n"
}
