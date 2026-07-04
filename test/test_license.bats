#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the "license_check.sh" script

setup_file() {
    true
    export SCRIPT="$BATS_TEST_DIRNAME/../scripts/license_check.sh"
    export EXAMPLE_REPO_DIR="$BATS_TEST_DIRNAME/example_repo"
    export LICENSE="GPL-3.0-or-later"
    export COPYRIGHT="Cotti"
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"
}

teardown() {
    true
}

teardown_file() {
    true
}

@test "target_dir is a required argument" {
    run "${SCRIPT}"
    assert_failure
    assert_output --partial "[ERROR]"
    assert_output --partial "Usage:"
}

@test "Passing a non-existing folder as target_dir should fail" {
    run "${SCRIPT}" "random_dir"
    assert_failure
    assert_output --partial "[ERROR]"
    assert_output --partial "random_dir"
}

@test "Require a license, copyright string and at least one file extension" {
    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}"
    assert_failure
    assert_output --partial "[ERROR]"
    assert_output --partial "Usage:"

    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}" "${LICENSE}"
    assert_failure
    assert_output --partial "[ERROR]"
    assert_output --partial "Usage:"

    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}" "${LICENSE}" "${COPYRIGHT}"
    assert_failure
    assert_output --partial "[ERROR]"
    assert_output --partial "Usage:"
}

@test "If no files match the given extensions, fail" {
    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}" "${LICENSE}" "${COPYRIGHT}" ".xd"
    assert_failure
    assert_output --partial "[ERROR]"
    assert_output --partial ".xd"
}

@test "License check example repo" {
    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}" "${LICENSE}" "${COPYRIGHT}" ".sh"
    assert_success
    assert_output --partial "[OK]"
    assert_output --partial "script1.sh"
}

@test "License check fails for wrong license or copyright" {
    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}" "MIT" "${COPYRIGHT}" ".sh"
    assert_failure
    assert_output --partial "[ERROR]"

    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}" "${LICENSE}" "Juancito" ".sh"
    assert_failure
    assert_output --partial "[ERROR]"
}

@test "License check fails if file misses the header, and list it" {
    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}" "MIT" "${COPYRIGHT}" ".md"
    assert_failure
    assert_output --partial "[ERROR]"
    assert_output --partial "README.md"
}
