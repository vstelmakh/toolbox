#!/bin/bash

function assert_equals() {
    local EXPECTED="${1}"
    local ACTUAL="${2}"
    if [ "${EXPECTED}" == "${ACTUAL}" ]; then
        return 0
    else
        echo -e "\e[33mExpected: \e[0m${EXPECTED}"
        echo -e "\e[36mActual:   \e[0m${ACTUAL}"
        return 1
    fi
}

function assert_starts_with() {
    local EXPECTED="${1}"
    local ACTUAL="${2}"
    if [[ "${ACTUAL}" == "${EXPECTED}"* ]]; then
        return 0
    else
        echo -e "\e[33mExpected: \e[0m${EXPECTED}"
        echo -e "\e[36mActual:   \e[0m${ACTUAL:0:${#EXPECTED}}"
        return 1
    fi
}

function assert_not_empty() {
    local ACTUAL="${1}"
    if [ -n "${ACTUAL}" ]; then
        return 0
    else
        echo -e "\e[33mExpected: \e[0m\e[2m~not empty~\e[0m"
        echo -e "\e[36mActual:   \e[0m${ACTUAL}"
        return 1
    fi
}

function assert_match() {
    local MATCH="${1}"
    local VALUE="${2}"
    if [[ "${VALUE}" =~ ${MATCH} ]]; then
        return 0
    else
        echo -e "\e[33mMatch: \e[0m${MATCH}"
        echo -e "\e[36mValue: \e[0m${VALUE}"
        return 1
    fi
}
