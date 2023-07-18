#!/bin/bash
# shellcheck disable=SC2016,SC2155

function exec_command() {
    bash "${_TOOLBOX_BIN}" "url" "${@}"
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

function exec_decode() {
    local ACTUAL=$(exec_command "decode" "${1}")
    assert_equals "${2}" "${ACTUAL}"
}

function test_decode_ampersand() {
    exec_decode 'Tom%20%26%20Jerry' 'Tom & Jerry'
}

function test_decode_special_chars() {
    exec_decode 'M%40x%20Mu%24termann' 'M@x Mu$termann'
}

function test_decode_full_url() {
    exec_decode \
        'http%3A%2F%2Fuser%3Apassword%40example.com%3A80%2Fpath%2Fto%2Findex.html%3Ftext%3Dhello%26fruits%5B0%5D%3Dapple%26fruits%5B1%5D%3Dcherry%23anchor' \
        'http://user:password@example.com:80/path/to/index.html?text=hello&fruits[0]=apple&fruits[1]=cherry#anchor'
}

function test_decode_partially() {
    exec_decode \
        'http://example.com/?text=somevalue%26special%23chars' \
        'http://example.com/?text=somevalue&special#chars'
}

function exec_encode() {
    local ACTUAL=$(exec_command "encode" "${1}")
    assert_equals "${2}" "${ACTUAL}"
}

function test_encode_ampersand() {
    exec_encode 'Tom & Jerry' 'Tom%20%26%20Jerry'
}

function test_encode_special_chars() {
    exec_encode 'M@x Mu$termann' 'M%40x%20Mu%24termann'
}

function test_encode_full_url() {
    exec_encode \
        'http://user:password@example.com:80/path/to/index.html?text=hello&fruits[0]=apple&fruits[1]=cherry#anchor' \
        'http%3A%2F%2Fuser%3Apassword%40example.com%3A80%2Fpath%2Fto%2Findex.html%3Ftext%3Dhello%26fruits%5B0%5D%3Dapple%26fruits%5B1%5D%3Dcherry%23anchor'
}
