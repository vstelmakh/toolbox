#!/bin/bash
# shellcheck disable=SC2155

function exec_command() {
    bash "${_TOOLBOX_BIN}" "base64" "${@}"
}

function test_completion_1() {
    local ACTUAL="$(exec_command "--toolbox-completion" "")"
    assert_equals "decode encode" "${ACTUAL}"
}

function test_completion_2() {
    local ACTUAL="$(exec_command "--toolbox-completion" "encode" "")"
    assert_equals "" "${ACTUAL}"
}

function test_completion_long() {
    local ACTUAL="$(exec_command "--toolbox-completion" "--")"
    assert_equals "--help" "${ACTUAL}"
}

function test_completion_short() {
    local ACTUAL="$(exec_command "--toolbox-completion" "-")"
    assert_equals "-h" "${ACTUAL}"
}

function test_empty_action_status() {
    exec_command "" >> /dev/null
    assert_equals 1 $?
}

function test_empty_action_output() {
    local ACTUAL="$(exec_command "")"
    assert_starts_with "Action is required" "${ACTUAL}"
}

function test_unknown_action_status() {
    exec_command "unknown_action" >> /dev/null
    assert_equals 1 $?
}

function test_unknown_action_output() {
    local ACTUAL="$(exec_command "unknown_action")"
    assert_starts_with "Unexpected action" "${ACTUAL}"
}

function test_decode() {
    local ACTUAL=$(exec_command "decode" "VGhpcyBpcyB0ZXN0IHN0cmluZw==")
    assert_equals "This is test string" "${ACTUAL}"
}

function test_encode() {
    local ACTUAL=$(exec_command "encode" "This is test string")
    assert_equals "VGhpcyBpcyB0ZXN0IHN0cmluZw==" "${ACTUAL}"
}
