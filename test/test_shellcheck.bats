#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the "bash_lint.sh" script

setup_file() {
    true
    export SCRIPT="$BATS_TEST_DIRNAME/../scripts/bash_lint.sh"
    export EXAMPLE_REPO_DIR="$BATS_TEST_DIRNAME/example_repo"
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

@test "Shellcheck example repo" {
    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}"
    assert_success
    assert_output --partial "[OK]"
}

@test "Shellcheck shows error on file" {

    # This one has an error
    mkdir "$BATS_TEST_TMPDIR/dir1"
    printf "%s" "$(cat<<EOF
#!/bin/bash
# An echo with a \n is an style error
echo "hi from script1\n"
EOF
)" > "$BATS_TEST_TMPDIR/dir1/script1.sh"

    # This file also has an error
    mkdir "$BATS_TEST_TMPDIR/dir2"
    printf "%s" "$(cat<<EOF
# No shebang
echo "hi from script2"
EOF
)" > "$BATS_TEST_TMPDIR/dir2/script2.sh"

    # This one is ok and should not appear
    mkdir "$BATS_TEST_TMPDIR/dir3"
    printf "%s" "$(cat<<EOF
#!/bin/bash
echo "hi from script3"
EOF
)" >> "$BATS_TEST_TMPDIR/dir3/script3.sh"

    run "${SCRIPT}" "$BATS_TEST_TMPDIR"
    assert_failure
    assert_output --partial "$BATS_TEST_TMPDIR/dir1/script1.sh"
    assert_output --partial "$BATS_TEST_TMPDIR/dir2/script2.sh"
    refute_output --partial "$BATS_TEST_TMPDIR/dir3/script3.sh"
}