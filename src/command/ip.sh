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
    echo "Detect and print current public IP"
}

function command_completion() {
    case "${#@}" in
        1)
            echo "4 64"
            ;;
    esac
}

function command_execute() {
    case "${1}" in
        ""|"4")
            curl "https://api.ipify.org" && echo
            ;;
        "64")
            curl "https://api64.ipify.org" && echo
            ;;
        *)
            echo "Unexpected IP version argument"
            exit 1
            ;;
    esac
}

function command_help() {
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  ip [options] [<version>]
  ip 64

\e[33mArguments:\e[0m
  \e[32mversion\e[0m     IP version to detect. Available values: "4", "64". \e[33m[default: 4]\e[0m

\e[33mOptions:\e[0m
  \e[32m-h, --help\e[0m  Display this help
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
