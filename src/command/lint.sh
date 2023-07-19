#!/bin/bash
# shellcheck disable=SC2155

function main() {
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
    echo "Lint toolbox project shell scripts"
}

function command_completion() {
    case "${#@}" in
        1)
            [[ ${1} = "--"* ]] && echo "--help" && exit
            [[ ${1} = "-"* ]] && echo "-h" && exit

            echo ""
            ;;
    esac
}

function command_execute() {
    DIR_PROJECT_ROOT="$(get_project_root_dir)"

    shellcheck --version
    echo

    local SCRIPTS=$(get_project_scripts)
    local SCRIPTS_COUNT="$(echo "${SCRIPTS}" | wc -l)"

    echo "Checking ${SCRIPTS_COUNT} files..." && echo
    run_shellcheck "${SCRIPTS}" && echo -e "\e[42m OK \e[0m"
}

function get_project_root_dir() {
    local SCRIPT=$(readlink -f "${0}")
    local DIR=$(dirname "${SCRIPT}")
    readlink -f "${DIR}/../.." || exit 1
}

function get_project_scripts() {

    find \
        "${DIR_PROJECT_ROOT}/bin" \
        "${DIR_PROJECT_ROOT}/src" \
        "${DIR_PROJECT_ROOT}/tests" \
        -type f -print0 \
        | xargs -0 grep -lE '^#!.*/(sh|bash)'
}

# https://github.com/koalaman/shellcheck/wiki/Recursiveness
function run_shellcheck() {
    echo "${1}" | xargs shellcheck --color=always --severity=info
}

function command_help() {
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  lint [options] [<version>]
  lint

\e[33mOptions:\e[0m
  \e[32m-h, --help\e[0m  Display this help
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
