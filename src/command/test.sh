#!/bin/bash
# shellcheck disable=SC2155

function main() {
    export _TOOLBOX_PROJECT_ROOT=$(get_project_root_dir)
    export _TOOLBOX_BIN="${_TOOLBOX_PROJECT_ROOT}/bin/toolbox"
    DIR_TESTS="${_TOOLBOX_PROJECT_ROOT}/tests"
    TEST_FUNCTION_PREFIX='test_'

    case "${1}" in
        "--toolbox-description")
            command_description
            ;;
        "--toolbox-completion")
            command_completion "${@:2}"
            ;;
        "-h"|"--help")
            command_help "${@:2}"
            ;;
        *)
            command_execute "$@"
            ;;
    esac
}

function command_description() {
    echo "Run toolbox project tests"
}

function command_completion() {
    case "${#@}" in
        1)
            [[ ${1} = "--"* ]] && echo "--help" && exit
            [[ ${1} = "-"* ]] && echo "-h" && exit

            local SCRIPTS=()
            readarray -t SCRIPTS <<< "$(get_all_test_scripts)"
            local COMPLETION=""
            for FILE in "${SCRIPTS[@]}"; do
                COMPLETION="${COMPLETION} $(echo "${FILE#"${DIR_TESTS}"}" | sed -E "s/^\///g")"
            done
            echo "${COMPLETION}"
            ;;
        2)
            local TEST_SCRIPT=$(get_one_test_script "${1}")
            if ! validate_test_script_path "${TEST_SCRIPT}" >> /dev/null; then
                exit
            fi
            get_test_functions "${TEST_SCRIPT}"
            ;;
    esac
}

function command_execute() {
    source "${_TOOLBOX_PROJECT_ROOT}/src/test/asserts.sh"

    local ARG_FILE=${1}
    local ARG_FUNCTION=${2}

    local PROGRESS_MAX_WIDTH=80
    local COUNT_TOTAL=0
    local COUNT_SUCCESS=0
    local COUNT_FAIL=0

    local FAIL_SCRIPTS=()
    local FAIL_FUNCTIONS=()
    local FAIL_OUTPUTS=()

    local TIME_START=$(date +%s)

    if [ -n "${ARG_FILE}" ]; then
        local TEST_SCRIPTS=$(get_one_test_script "${ARG_FILE}")
        validate_test_script_path "${TEST_SCRIPTS}"
    else
        local TEST_SCRIPTS=$(get_all_test_scripts)
    fi

    for TEST_SCRIPT in ${TEST_SCRIPTS}; do
        if [ -n "${ARG_FUNCTION}" ]; then
            validate_test_function "${TEST_SCRIPT}" "${ARG_FUNCTION}"
            local TEST_FUNCTIONS="${ARG_FUNCTION}"
        else
            local TEST_FUNCTIONS="$(get_test_functions "${TEST_SCRIPT}")"
        fi

        for TEST_FUNCTION in ${TEST_FUNCTIONS}; do
            ((COUNT_TOTAL++))

            # Impossible to make local because local is a command itself and its exit-code will overwrite that of the assigned function
            TEST_OUTPUT="$(run_test "${TEST_SCRIPT}" "${TEST_FUNCTION}")"
            local TEST_STATUS_CODE=$?

            if [ ${TEST_STATUS_CODE} == 0 ]; then
                echo -n "."
                ((COUNT_SUCCESS++))
            else
                echo -en "\e[1m\e[31mF\e[0m"
                ((COUNT_FAIL++))
                FAIL_SCRIPTS+=("${TEST_SCRIPT#"${DIR_TESTS}/"}")
                FAIL_FUNCTIONS+=("${TEST_FUNCTION}")
                FAIL_OUTPUTS+=("${TEST_OUTPUT}")
            fi

            if [ $((COUNT_TOTAL % PROGRESS_MAX_WIDTH)) == 0 ]; then
                echo
            fi
        done
    done
    local TIME_END=$(date +%s)
    echo

    echo
    local RUNTIME=$((TIME_END - TIME_START))
    echo "Time: $(get_readable_runtime "${RUNTIME}")"
    echo "Tests: ${COUNT_TOTAL}, Successful: ${COUNT_SUCCESS}, Failed: ${COUNT_FAIL}"

    echo
    if [ "${COUNT_FAIL}" -gt 0 ]; then
        echo -e "\e[41m Failures \e[0m"
        echo
        for I in "${!FAIL_SCRIPTS[@]}"; do
            echo -e "\e[1m$((I+1)))\e[0m ${FAIL_SCRIPTS[$I]} :: ${FAIL_FUNCTIONS[$I]}"
            echo "${FAIL_OUTPUTS[$I]}"
            echo
        done
        exit 1
    else
        echo -e "\e[42m OK \e[0m"
        exit 0
    fi
}

function get_project_root_dir() {
    local SCRIPT=$(readlink -f "${0}")
    local DIR=$(dirname "${SCRIPT}")
    readlink -f "${DIR}/../.." || exit 1
}

function get_one_test_script() {
    local FILE="${1}"

    local RELATIVE_FILE=$(echo "${FILE#"${DIR_TESTS}"}" | sed -E "s/^\///g")
    local TEST_SCRIPT="${DIR_TESTS}/${RELATIVE_FILE}"

    echo "${TEST_SCRIPT}"
}

function validate_test_script_path() {
    local FILE="${1}"

    if [[ "${FILE}" =~ (^\.{2,}|\/\.{2,}|\.{2,}\/) ]]; then
        echo -e "Can't test files outside tests dir: \e[36m${FILE}\e[0m"
        echo -e "\e[41m Error \e[0m"
        exit 1
    fi

    if [ ! -f "${FILE}" ]; then
        local RELATIVE_FILE=$(echo "${FILE#"${DIR_TESTS}"}" | sed -E "s/^\///g")
        echo -e "Test script does not exist:"
        echo -e "\e[90m${DIR_TESTS}/\e[0m\e[36m${RELATIVE_FILE}\e[0m"
        echo -e "\e[41m Error \e[0m"
        exit 1
    fi
}

function get_all_test_scripts() {
    find "${DIR_TESTS}" -name '*_test.sh' -print
}

function validate_test_function() {
    local FILE="${1}"
    local FUNCTION="${2}"

    bash -c "source '${FILE}' && declare -F '${FUNCTION}'" > /dev/null
    if [ $? -gt 0 ]; then
        echo -e "Test function does not exist:"
        echo -e "\e[90m${FILE}\e[0m :: \e[36m${FUNCTION}\e[0m"
        echo -e "\e[41m Error \e[0m"
        exit 1
    fi

    if [[ ! "${FUNCTION}" =~ ^${TEST_FUNCTION_PREFIX} ]]; then
        echo -e "Test function \e[36m${FUNCTION}\e[0m should be prefixed by \e[36m${TEST_FUNCTION_PREFIX}\e[0m"
        echo -e "\e[41m Error \e[0m"
        exit 1
    fi
}

function get_test_functions() {
    bash -c "source '${1}' && declare -F | cut -d ' ' -f3 | grep '^${TEST_FUNCTION_PREFIX}'"
}

function run_test() {
    bash -c "source '${1}' && ${2}"
}

function get_readable_runtime() {
    local RESULT=""
    local SECONDS=${1}
    local PREFIX=""

    if [ "${SECONDS}" == 0 ]; then
        RESULT="<1 sec"
    fi

    if [ "${SECONDS}" -ge 3600 ]; then
        local HOURS="$((SECONDS / 3600))"
        SECONDS="$((SECONDS % 3600))"
        RESULT="${HOURS} hrs"
        PREFIX=" "
    fi

    if [ "${SECONDS}" -ge 60 ]; then
        local MINUTES="$((SECONDS / 60))"
        SECONDS="$((SECONDS % 60))"
        RESULT="${RESULT}${PREFIX}${MINUTES} min"
        PREFIX=" "
    fi

    if [ "${SECONDS}" -gt 0 ]; then
        RESULT="${RESULT}${PREFIX}${SECONDS} sec"
    fi

    echo "${RESULT}"
}

function command_help() {
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  test [options] [<file>] [<function>]
  test command/url_test.sh

\e[33mArguments:\e[0m
  \e[32mfile\e[0m       Specific test file to execute. If ommited all the project tests will be executed.
  \e[32mfunction\e[0m   Specific test function to execute. If ommited all the file tests will be executed.

\e[33mOptions:\e[0m
  \e[32m-h, --help\e[0m  Display this help
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
