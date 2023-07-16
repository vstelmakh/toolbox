#!/bin/bash
# shellcheck disable=SC2155

function get_commands() {
    local COMMANDS=()
    local SCRIPTS=$(ls "${_TOOLBOX_PROJECT_ROOT}/src/command"/*.sh)
    for SCRIPT in ${SCRIPTS}; do
        local COMMAND=$(echo "${SCRIPT}" | sed -E "s/^.+\///g" | sed -E "s/\.sh$//g")
        COMMANDS+=("${COMMAND}")
    done
    echo "${COMMANDS[@]}"
}

function test_description() {
    local COMMANDS=()
    IFS=" " read -r -a COMMANDS <<< "$(get_commands)"

    local FAILURES=0
    local PREFIX=""
    local EMPTY_DESCRIPTION_COMMANDS=""
    for COMMAND in "${COMMANDS[@]}"; do
        local ACTUAL="$(bash "${_TOOLBOX_BIN}" "${COMMAND}" "--toolbox-description")"
        assert_not_empty "${ACTUAL}" >> /dev/null
        if [ $? -gt 0 ]; then
            ((FAILURES++))
            EMPTY_DESCRIPTION_COMMANDS="${EMPTY_DESCRIPTION_COMMANDS}${PREFIX}${COMMAND}"
            PREFIX=", "
        fi
    done

    if [ "${FAILURES}" -gt 0 ]; then
        echo -e "\e[36mEmpty description for:\e[0m ${EMPTY_DESCRIPTION_COMMANDS}"
    fi
    return "${FAILURES}"
}

function test_completion() {
    local COMMANDS=()
    IFS=" " read -r -a COMMANDS <<< "$(get_commands)"

    local FAILURES=0
    local PREFIX=""
    local ERROR_COMPLETION_COMMANDS=""
    for COMMAND in "${COMMANDS[@]}"; do
        bash "${_TOOLBOX_BIN}" "${COMMAND}" "--toolbox-completion" >> /dev/null
        assert_equals 0 $? >> /dev/null
        if [ $? -gt 0 ]; then
            ((FAILURES++))
            ERROR_COMPLETION_COMMANDS="${ERROR_COMPLETION_COMMANDS}${PREFIX}${COMMAND}"
            PREFIX=", "
        fi
    done

    if [ "${FAILURES}" -gt 0 ]; then
        echo -e "\e[36mCompletion fails for:\e[0m ${ERROR_COMPLETION_COMMANDS}"
    fi
    return "${FAILURES}"
}
