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
    echo "Update toolbox to the latest version"
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
    local DIR_PROJECT_ROOT="$(get_project_root_dir)"
    echo "Updating toolbox to latest version"
    echo -e "Location: \e[32m${DIR_PROJECT_ROOT}\e[0m"
    cd "${DIR_PROJECT_ROOT}" || exit 1

    local CURRENT_BRANCH="$(git branch --show-current)"
    if [ "${CURRENT_BRANCH}" != "master" ]; then
        echo -e "Active branch is not \e[33mmaster\e[0m. Change branch to \e[33mmaster\e[0m to proceed."
        exit 1
    fi

    local COMMIT_HASH_OLD="$(git rev-parse --short HEAD)"
    git pull --quiet
    local COMMIT_HASH_NEW="$(git rev-parse --short HEAD)"

    [ "${COMMIT_HASH_OLD}" != "${COMMIT_HASH_NEW}" ] && echo "Update successful" || echo "Already up to date"
    echo -e "Version: \e[33mmaster\e[0m \e[36m${COMMIT_HASH_NEW}\e[0m"

    local FILE_CHANGES="$(git -c color.ui=always status --short --untracked-files=no)"
    if [ -n "${FILE_CHANGES}" ]; then
        echo
        echo -e "\e[103m !\e[0m Project dir contains local file changes:"
        echo -e "${FILE_CHANGES}"
    fi
}

function get_project_root_dir() {
    local SCRIPT=$(readlink -f "${0}")
    local DIR=$(dirname "${SCRIPT}")
    readlink -f "${DIR}/../.." || exit 1
}

function command_help() {
    local COMMAND="$(basename -- "${0}" | sed -E 's/\.sh$//g')"
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  ${COMMAND} [options]

\e[33mOptions:\e[0m
  \e[32m-h, --help\e[0m  Display this help
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
