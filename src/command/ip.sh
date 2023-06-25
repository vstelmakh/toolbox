#!/bin/bash

function main() {
    case "${1}" in
        "--toolbox-description")
            command_description
            ;;
        "--toolbox-completion")
            command_completion "${@:2}"
            ;;
        *)
            command_execute "$@"
            ;;
    esac
}

function command_description() {
    echo "Detect and print current public IP"
    exit 0
}

function command_completion() {
    case "${#@}" in
        1)
            echo "4 6 64"
            ;;
    esac
}

function command_execute() {
    case "${1}" in
        ""|"4")
            curl "https://api.ipify.org" && echo
            exit 0
            ;;
        "6"|"64")
            curl "https://api64.ipify.org" && echo
            exit 0
            ;;
        *)
            echo "Unexpected IP version argument"
            exit 1
            ;;
    esac
}

main "$@"
