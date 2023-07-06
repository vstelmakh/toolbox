#!/bin/bash
# shellcheck disable=SC2155,SC1090

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
    echo "Validate config file"
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
    case "${1}" in
        "--execute-without-env")
            command_execute_without_env "${@:2}"
            ;;
        *)
            env -i bash "${0}" "--execute-without-env" "${@}"
            ;;
    esac
}

# It's important to execute this command without env variables
# to not pollute validation environment with existing config variables
function command_execute_without_env() {
    local _CONFIG_FILE="$(get_config_file_path)"
    declare -A PARAMETERS_MISSING=()
    declare -A PARAMETERS_UNEXPECTED=()
    declare -A PARAMETERS_DEFINED=()

    echo -en "\e[33mConfig:\e[0m "
    if [ -f "${_CONFIG_FILE}" ]; then
        readlink -f "${_CONFIG_FILE}"
    else
        echo "Not exist"
    fi

    local PREFIX="CONFIG_"
    if [ -n "${1}" ]; then
        PREFIX=$(echo "${PREFIX}${1^^}_" | sed -E "s/[^a-z0-9]/_/gi")
    fi
    local VAR_SUBSTITUTION="\${!${PREFIX}@}"
    echo -en "\e[33mPrefix:\e[0m "
    echo "${PREFIX}"

    set -o allexport
    source "${_CONFIG_FILE}.dist"
    set +o allexport

    PARAMETERS="$(eval echo "${VAR_SUBSTITUTION}")"
    for PARAMETER in ${PARAMETERS}; do
        PARAMETERS_MISSING+=([${PARAMETER}]="")
        unset "${PARAMETER}"
    done

    if [ -f "${_CONFIG_FILE}" ]; then
        set -o allexport
        source "${_CONFIG_FILE}"
        set +o allexport
    fi

    PARAMETERS="$(eval echo "${VAR_SUBSTITUTION}")"
    for PARAMETER in ${PARAMETERS}; do
        if [ -z ${PARAMETERS_MISSING["${PARAMETER}"]+x} ]; then
            PARAMETERS_UNEXPECTED+=([${PARAMETER}]=${!PARAMETER})
        else
            unset PARAMETERS_MISSING["${PARAMETER}"]
            PARAMETERS_DEFINED+=([${PARAMETER}]=${!PARAMETER})
        fi
        unset "${PARAMETER}"
    done

    echo -en "\e[33mLegend:\e[0m "
    echo -e "\e[1m\e[31mM\e[0missing, \e[1m\e[93mU\e[0mnexpected, \e[1m\e[32mS\e[0met"
    echo

    echo -e "\e[33mParameters:\e[0m"
    for PARAMETER in "${!PARAMETERS_MISSING[@]}"; do
        echo -en "\e[1m\e[31mM\e[0m "
        echo -en "${PARAMETER}\e[33m=\e[0m"
        echo -e "\e[33m${PARAMETERS_MISSING[${PARAMETER}]}\e[0m"
    done

    for PARAMETER in "${!PARAMETERS_UNEXPECTED[@]}"; do
        echo -en "\e[1m\e[93mU\e[0m "
        echo -en "${PARAMETER}\e[33m=\e[0m"
        echo -e "${PARAMETERS_UNEXPECTED[${PARAMETER}]}"
    done

    for PARAMETER in "${!PARAMETERS_DEFINED[@]}"; do
        echo -en "\e[1m\e[32mS\e[0m "
        echo -en "${PARAMETER}\e[33m=\e[0m"
        echo -e "${PARAMETERS_DEFINED[${PARAMETER}]}"
    done

    if [ ${#PARAMETERS_MISSING[@]} -eq 0 ]; then
        exit 0
    else
        echo
        echo -e "\e[93mWarning:\e[0m"
        echo -e "Config does not contain all the required parameters, some commands may not work."
        echo -e "Set configuration parameters in \e[33mconfig.env\e[0m. Check \e[33mconfig.env.dist\e[0m for configuration reference."
        exit 1
    fi
}

function get_config_file_path() {
    local SCRIPT=$(readlink -f "${0}")
    local DIR=$(dirname "${SCRIPT}")
    echo "${DIR}/../../config.env" || exit 1
}

function command_help() {
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  config [options] [<prefix>]
  config audio

\e[33mArguments:\e[0m
  \e[32mprefix\e[0m      Prefix (command) to check for specifically prefixed parameters (limit the scope to one command).

\e[33mOptions:\e[0m
  \e[32m-h, --help\e[0m  Display this help

\e[33mHelp:\e[0m
  Compare \e[33mconfig.env\e[0m with \e[33mconfig.env.dist\e[0m and print missing parameters as well as values of existing ones.
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
