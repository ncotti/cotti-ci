#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the "markdown_lint.sh" script

setup_file() {
    true
    export SCRIPT="$BATS_TEST_DIRNAME/../scripts/markdown_lint.sh"
    export EXAMPLE_REPO_DIR="$BATS_TEST_DIRNAME/example_repo"
    export CONFIG_FILE="$BATS_TEST_DIRNAME/../default_config/.markdownlint-cli2.jsonc"
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

@test "Formatting should be applied to all .md files inside the folder recursively" {
    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}"
    assert_success
    # Message stating default configuration
    assert_output --partial "[INFO]"
    assert_output --partial "default"
    # 3 files should have been processed
    assert_output --partial "README.md"
    assert_output --partial "docs/doc_a.md"
    assert_output --partial "docs/inner_docs/doc_b.md"
}

@test "If a custom config_file is provided and it does not exists, fail" {
    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}" "xd_file"
    assert_failure
    assert_output --partial "[ERROR]"
    assert_output --partial "xd_file"
}

@test "If a custom config_file is provided and it does exists, use it" {
    run "${SCRIPT}" "${EXAMPLE_REPO_DIR}" "${CONFIG_FILE}"
    assert_success
    refute_output --partial "default"
}

@test "If a file does not pass linting, fail" {
    printf "%s" "$(cat<<EOF
## First title should have a single numeral

File should end with a newline (this does not).
EOF
)" >> "$BATS_TEST_TMPDIR/sample.md"
    run "${SCRIPT}" "$BATS_TEST_TMPDIR"
    assert_failure
    assert_output --partial "sample.md"
    assert_output --partial "MD041"     # First level heading
    assert_output --partial "MD047"     # Trailing newline required
}
