#!/bin/bash
# shellcheck disable=SC2155

readonly DEFAULT_LENGTH=12

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
    echo "Generate random password"
}

function command_completion() {
    case "${#@}" in
        1)
            [[ ${1} = "--"* ]] && echo "--complex --help" && exit
            [[ ${1} = "-"* ]] && echo "-c -h" && exit

            echo "--complex"
            ;;
    esac
}

function command_execute() {
    local IS_COMPLEX=false
    local LENGTH="${DEFAULT_LENGTH}"

    local ARGUMENTS=("${0}")
    while [[ "$#" -gt 0 ]]; do
        case "${1}" in
            "-c"|"--complex")
                IS_COMPLEX=true
                shift
                ;;
            -*)
                echo "Option \"${1}\" do not exist"
                exit 1
                ;;
            *)
                ARGUMENTS+=("${1}")
                shift
                ;;
        esac
    done

    local LENGTH=${ARGUMENTS[1]:-${LENGTH}}

    echo "$(generate_password "${LENGTH}" "${IS_COMPLEX}")"
}

function generate_password() {
    local LENGTH="${1}"
    local IS_COMPLEX="${2}"
    local CHARSET=$([ "${IS_COMPLEX}" != true ] && echo "A-Za-z0-9" || echo "A-Za-z0-9!@#$%&*=+.?")
    local AMBIGUOUS_CHARS="IOl"
    local PASSWORD="$(head /dev/urandom | tr -dc "${CHARSET}" | tr -d "${AMBIGUOUS_CHARS}" | head -c"${LENGTH}")"

    # make sure complex password always contains specialchar
    if [ "${IS_COMPLEX}" == true ]; then
        local SPECIALCHARS='!@#$%&*=+.?'
        local CHAR="${SPECIALCHARS:$(( ${RANDOM} % ${#SPECIALCHARS} )):1}"
        local POS=$((1 + ${RANDOM} % ${#PASSWORD}))
        POS=$([ "${POS}" == "${LENGTH}" ] && echo $((POS - 1)) || echo ${POS})
        PASSWORD="${PASSWORD:0:${POS}}${CHAR}${PASSWORD:$((POS + 1))}"
    fi

    echo "${PASSWORD}"
}

function command_help() {
    local COMMAND="$(basename -- "${0}" | sed -E 's/\.sh$//g')"
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  ${COMMAND} [options] [<length>]
  ${COMMAND} -c 10

\e[33mArguments:\e[0m
  \e[32mlength\e[0m        Generated password length \e[33m[default: ${DEFAULT_LENGTH}]\e[0m

\e[33mOptions:\e[0m
  \e[32m-c, --complex\e[0m Generate more complex password with punctuation characters
  \e[32m-h, --help\e[0m    Display this help
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
