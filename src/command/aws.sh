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
    echo "Run AWS CLI command in Docker container"
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
    docker run --rm -ti -v "${HOME}/.aws:/root/.aws" -v "$(pwd):/aws" amazon/aws-cli "$@"
}

function command_help() {
    local COMMAND="$(basename -- "${0}" | sed -E 's/\.sh$//g')"
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  ${COMMAND} [options] [<commands>...]
  ${COMMAND} ec2 describe-instances

\e[33mArguments:\e[0m
  \e[32mcommands\e[0m    AWS CLI commands

\e[33mOptions:\e[0m
  \e[32m-h, --help\e[0m  Display this help

\e[33mHelp:\e[0m
  Keep in mind only \e[33mcurrent work dir\e[0m is synchronized with container.
  Which means only \e[33m.\e[0m is allowed as a path to store something e.g. while downloading from s3.
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
