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
    echo "Decode or encode base64 input"
}

function command_completion() {
    case "${#@}" in
        1)
            [[ ${1} = "--"* ]] && echo "--help" && exit
            [[ ${1} = "-"* ]] && echo "-h" && exit

            echo "decode encode"
            ;;
    esac
}

function command_execute() {
    case "${1}" in
        "decode")
            echo -n "${*:2}" | base64 --decode --ignore-garbage
            echo
            ;;
        "encode")
            echo -n "${*:2}" | base64 --wrap=0
            echo
            ;;
        "")
            echo -e "Action is required argument. See \e[32m--help\e[0m for available arguments"
            exit 1
            ;;
        *)
            echo -e "Unexpected action \e[33m${1}\e[0m. See \e[32m--help\e[0m for available arguments"
            exit 1
            ;;
    esac
}

function command_help() {
    local COMMAND="$(basename -- "${0}" | sed -E 's/\.sh$//g')"
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  ${COMMAND} [options] <action> <data>
  ${COMMAND} encode string-to-encode

\e[33mArguments:\e[0m
  \e[32maction\e[0m      Action to perform. Available values: "decode", "encode".
  \e[32mdata\e[0m        String data to decode or encode. Remember to \e[36menclose input in single quotes\e[0m to prevent shell processing special chars.

\e[33mOptions:\e[0m
  \e[32m-h, --help\e[0m  Display this help

\e[33mHelp:\e[0m
  Process file contents by the command: \e[33murl encode "\$(cat path/to/file)"\e[0m
  Redirect output to the file: \e[33murl decode > path/to/file\e[0m
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
