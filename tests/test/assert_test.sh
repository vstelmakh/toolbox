#!/bin/bash

function expect_status_success() {
    STATUS=${1}
    if [ "${STATUS}" -gt 0 ]; then
        echo "# Assert status: ${STATUS}, expected: 0"
        return 1
    fi
}

function expect_status_fail() {
    STATUS=${1}
    if [ "${STATUS}" -lt 1 ]; then
        echo "# Assert status: ${STATUS}, expected: >0"
        return 1
    fi
}

function test_assert_equals_success() {
    assert_equals "A" "A"
    expect_status_success $?
}

function test_assert_equals_fail() {
    assert_equals "A" "B"
    expect_status_fail $?
}

function test_assert_starts_with_success() {
    assert_starts_with "A" "ABC"
    expect_status_success $?
}

function test_assert_starts_with_fail() {
    assert_starts_with "A" "CBA"
    expect_status_fail $?
}

function test_assert_not_empty_success() {
    assert_not_empty "A"
    expect_status_success $?
}

function test_assert_not_empty_fail() {
    assert_not_empty ""
    expect_status_fail $?
}

function test_assert_match_success() {
    assert_match "[0-9]+" "Hello 1st visitor"
    expect_status_success $?
}

function test_assert_match_fail() {
    assert_match "[0-9]+" "Hello visitor"
    expect_status_fail $?
}
