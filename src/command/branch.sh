#!/bin/bash
# shellcheck disable=SC2155

readonly SPACER="-"

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
    echo "Convert ticket title to Git branch name"
}

function command_completion() {
    case "${#@}" in
        1)
            [[ ${1} = "--"* ]] && echo "--checkout --help" && exit
            [[ ${1} = "-"* ]] && echo "-c -h" && exit

            echo "--checkout"
            ;;
    esac
}

function command_execute() {
    local HAS_TO_CHECKOUT=false
    if [ "${1}" == "-c" ] || [ "${1}" == "--checkout" ]; then
        shift
        HAS_TO_CHECKOUT=true

        local IS_GIT_REPO="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
        if [ "${IS_GIT_REPO}" != true ]; then
            echo "Unable to checkout branch. Current workdir is not a Git repository."
            exit 1
        fi
    fi

    if [ -z "${*}" ]; then
        echo "Ticket title not provided. Impossible to generate branch name for empty title."
        exit 1
    fi

    local TICKET_NUMBER=$(get_ticket_number "${*}")
    local TICKET_TITLE=$(get_ticket_title "${TICKET_NUMBER}" "${*}")

    local BRANCH_NAME="${TICKET_TITLE}"
    BRANCH_NAME=$(get_normalized_punctuation "${BRANCH_NAME}")
    BRANCH_NAME=$(get_normalized_chars "${BRANCH_NAME}")
    BRANCH_NAME=$(get_as_ascii "${BRANCH_NAME}")
    BRANCH_NAME=$(get_as_lowercase "${BRANCH_NAME}")
    BRANCH_NAME=$(get_whitespace_as_spacer "${BRANCH_NAME}")
    BRANCH_NAME=$(get_trim_spacer "${BRANCH_NAME}")

    if [[ -n "${TICKET_NUMBER}" ]]; then
        local BRANCH="${TICKET_NUMBER}${SPACER}${BRANCH_NAME}"
    else
        local BRANCH="${BRANCH_NAME}"
    fi

    echo "${BRANCH}"

    if [ "${HAS_TO_CHECKOUT}" == true ]; then
        git checkout -b "${BRANCH}"
    fi
}

function get_ticket_number() {
    local STRING="$1"
    echo "${STRING}" | grep -Po "^\S+\d\s" | grep -Po "\S+"
}

function get_ticket_title() {
    local TICKET_NUMBER="$1"
    local STRING="$2"
    echo "${STRING#"${TICKET_NUMBER}"}" | sed -E "s/^\s+//g" | sed -E "s/\s+$//g"
}

function get_normalized_punctuation() {
    local STRING="$1"
    echo "${STRING}" |
        sed -E "s/@+/ at /g" |
        sed -E "s/&+/ and /g" |
        sed -E "s/[.,?\!@\$#;:_=+\/\\|~-]+/ /g" | # punctuation to whitespace
        sed -E "s/[$%^*(){}'\"\`<>]+//g" # remove special chars and brackets
}

function get_normalized_chars() {
    local STRING="$1"
    echo "${STRING}" |
        sed -E "s/[äÄ]/ae/g" |
        sed -E "s/[öÖ]/oe/g" |
        sed -E "s/[üÜ]/ue/g" |
        sed -E "s/[ß]/ss/g"
}

function get_as_ascii() {
    local STRING="$1"
    echo "${STRING}" | LANG=C sed -E "s/[\d128-\d255]//g" # remove non ascii
}

function get_as_lowercase() {
    local STRING="$1"
    echo "${STRING,,}"
}

function get_whitespace_as_spacer() {
    local STRING="$1"
    echo "${STRING}" | sed -E "s/\s+/${SPACER}/g"
}

function get_trim_spacer() {
    local STRING="$1"
    echo "${STRING}" | sed -E "s/^${SPACER}+|${SPACER}+$//g"
}

function command_help() {
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  branch [options] <title>
  branch WS-13 Define new project structure

\e[33mArguments:\e[0m
  \e[32mtitle\e[0m          Ticket title. Expected to look like: "WS-13 Define new project structure"

\e[33mOptions:\e[0m
  \e[32m-c, --checkout\e[0m Checkout to generated branch in current workdir
  \e[32m-h, --help\e[0m     Display this help
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
