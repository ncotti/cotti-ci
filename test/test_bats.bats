#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the "bats_test.sh" script.
## Unfortunately, testing that the submodules are correctly
## fetched is too much of a hassle and trying to execute the DUT from
## this test results in a circular dependency, so only the argument
## validation is tested here. The fetching mechanism was manually tested.

setup_file() {
    export SCRIPT="$BATS_TEST_DIRNAME/../scripts/bats_test.sh"
    export EXAMPLE_BATS_TEST_DIR="$BATS_TEST_DIRNAME"
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

    git submodule update --init \
        "${EXAMPLE_BATS_TEST_DIR}/framework/bats" \
        "${EXAMPLE_BATS_TEST_DIR}/framework/bats-assert" \
        "${EXAMPLE_BATS_TEST_DIR}/framework/bats-file" \
        "${EXAMPLE_BATS_TEST_DIR}/framework/bats-support"
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

@test "Passing a dir with no .bats file in it should fail" {
    run "${SCRIPT}" "${EXAMPLE_BATS_TEST_DIR}/example_repo"
    assert_failure
    assert_output --partial "[ERROR]"
}
