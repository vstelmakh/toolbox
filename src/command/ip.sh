#!/bin/bash

function main() {
    case "${1}" in
        "--toolbox-description")
            command_description
            ;;
        "--toolbox-completion")
            command_completion
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
    echo ""
    exit 0
}

function command_execute() {
    curl "https://api.ipify.org"
    echo
}

main "$@"
