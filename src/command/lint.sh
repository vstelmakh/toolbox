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

    if [ -n "${1}" ]; then
        local FILES=$(get_files_from_arguments "${@}")
    else
        local FILES=$(get_project_scripts)
    fi

    local FILES_COUNT="$(echo "${FILES}" | wc -l)"
    if [ "${FILES_COUNT}" == 1 ]; then
        echo -e "Checking \e[36m${FILES}\e[0m..." && echo
    else
        echo -e "Checking \e[36m${FILES_COUNT}\e[0m files..." && echo
    fi

    run_shellcheck "${FILES[@]}" && echo -e "\e[42m OK \e[0m"
}

function get_project_root_dir() {
    local SCRIPT=$(readlink -f "${0}")
    local DIR=$(dirname "${SCRIPT}")
    readlink -f "${DIR}/../.." || exit 1
}

function get_files_from_arguments() {
    local FILES=()

    for FILE in "${@:1}"; do
        if [[ "${FILE}" =~ (^\.{2,}|\/\.{2,}|\.{2,}\/) ]]; then
            echo -e "Can't lint files outside project dir: \e[36m${FILE}\e[0m"
            echo -e "\e[41m Error \e[0m"
            exit 1
        fi

        local RELATIVE_FILE=$(echo "${FILE#"${DIR_PROJECT_ROOT}"}" | sed -E "s/^\///g")
        FILES=("${FILES[@]}" "${DIR_PROJECT_ROOT}/${RELATIVE_FILE}")
    done

    IFS=$'\n'; echo "${FILES[*]}"
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
    echo "${@}" | xargs shellcheck --color=always --severity=info
}

function command_help() {
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  lint [options] [<files>...]
  lint src/command/anycommand.sh

\e[33mArguments:\e[0m
  \e[32mfiles\e[0m       Specific files to process. If ommited all the project shell scripts will be processed.

\e[33mOptions:\e[0m
  \e[32m-h, --help\e[0m  Display this help
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
