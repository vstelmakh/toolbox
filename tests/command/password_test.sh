#!/bin/bash
# shellcheck disable=SC2155

function exec_command() {
    bash "${_TOOLBOX_BIN}" "password" "${@}"
}

function test_completion_1() {
    local ACTUAL="$(exec_command "--toolbox-completion" "")"
    assert_equals "--complex" "${ACTUAL}"
}

function test_completion_2() {
    local ACTUAL="$(exec_command "--toolbox-completion" "20" "")"
    assert_equals "" "${ACTUAL}"
}

function test_completion_long() {
    local ACTUAL="$(exec_command "--toolbox-completion" "--")"
    assert_equals "--complex --help" "${ACTUAL}"
}

function test_completion_short() {
    local ACTUAL="$(exec_command "--toolbox-completion" "-")"
    assert_equals "-c -h" "${ACTUAL}"
}

function test_length_default() {
    local ACTUAL="$(exec_command)"
    assert_equals "12" "${#ACTUAL}"
}

function test_length_argument() {
    local ACTUAL="$(exec_command 20)"
    assert_equals "20" "${#ACTUAL}"
}

function test_value_simple() {
    local ACTUAL="$(exec_command 20)"
    assert_match "[A-Za-z0-9]{20}" "${ACTUAL}"
}

function test_value_complex_short() {
    local ACTUAL="$(exec_command -c 20)"
    assert_match "[!@#$%&*=+.?]+" "${ACTUAL}"
}

function test_value_complex_long() {
    local ACTUAL="$(exec_command --complex 20)"
    assert_match "[!@#$%&*=+.?]+" "${ACTUAL}"
}
