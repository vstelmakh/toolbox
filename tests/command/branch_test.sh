#!/bin/bash
# shellcheck disable=SC2155

function exec_command() {
    bash "${_TOOLBOX_BIN}" "branch" "${@}"
}

function test_completion_1() {
    local ACTUAL="$(exec_command "--toolbox-completion" "")"
    assert_equals "--checkout" "${ACTUAL}"
}

function test_completion_2() {
    local ACTUAL="$(exec_command "--toolbox-completion" "encode" "")"
    assert_equals "" "${ACTUAL}"
}

function test_completion_long() {
    local ACTUAL="$(exec_command "--toolbox-completion" "--")"
    assert_equals "--checkout --help" "${ACTUAL}"
}

function test_completion_short() {
    local ACTUAL="$(exec_command "--toolbox-completion" "-")"
    assert_equals "-c -h" "${ACTUAL}"
}

function test_branch_ticket() {
    local ACTUAL="$(exec_command 'WS-13 Define new project structure')"
    assert_equals "WS-13-define-new-project-structure" "${ACTUAL}"
}

function test_branch_no_ticket() {
    local ACTUAL="$(exec_command 'Define new project structure')"
    assert_equals "define-new-project-structure" "${ACTUAL}"
}

function test_branch_separate_args() {
    local ACTUAL="$(exec_command Define new project structure)"
    assert_equals "define-new-project-structure" "${ACTUAL}"
}

function test_branch_at() {
    local ACTUAL="$(exec_command 'Stay @ home')"
    assert_equals "stay-at-home" "${ACTUAL}"
}

function test_branch_and() {
    local ACTUAL="$(exec_command 'Tom & Jerry')"
    assert_equals "tom-and-jerry" "${ACTUAL}"
}

function test_branch_specialchars() {
    local ACTUAL="$(exec_command 'Hey! Thi`s (is) we~ird --> text $$$ for | branch.   Or not!?')"
    assert_equals "hey-this-is-we-ird-text-for-branch-or-not" "${ACTUAL}"
}

function test_branch_umlauts() {
    local ACTUAL="$(exec_command 'Text with umlauts: ä Ä ö Ö ü Ü ß')"
    assert_equals "text-with-umlauts-ae-ae-oe-oe-ue-ue-ss" "${ACTUAL}"
}

function test_branch_non_ascii() {
    local ACTUAL="$(exec_command 'Text українською')"
    assert_equals "text" "${ACTUAL}"
}
