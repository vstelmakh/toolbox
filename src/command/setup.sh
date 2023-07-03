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
    echo "Setup toolbox executable and command autocompletion for current user"
}

function command_completion() {
    case "${#@}" in
        1)
            echo "install uninstall"
            ;;
        2)
            echo "--force"
            ;;
    esac
}

function command_execute() {
    DIR_PROJECT_ROOT="$(get_project_root_dir)"
    BIN_NAME="toolbox"

    BIN="${DIR_PROJECT_ROOT}/bin/toolbox"
    BIN_DIR="${HOME}/.local/bin"
    BIN_LINK="${BIN_DIR}/${BIN_NAME}"

    COMPLETION="${DIR_PROJECT_ROOT}/src/completion/completion.bash"
    COMPLETION_DIR="${HOME}/.local/share/bash-completion/completions"
    COMPLETION_LINK="${COMPLETION_DIR}/${BIN_NAME}"

    IS_FORCE=false
    if [ "${2}" == "-f" ] || [ "${2}" == "--force" ]; then
        IS_FORCE=true
    fi

    case "${1}" in
        ""|"install")
            do_install
            ;;
        "uninstall")
            do_uninstall
            ;;
        *)
            echo -e "Unexpected action \e[33m${1}\e[0m. See \e[32m--help\e[0m for available arguments"
            exit 1
            ;;
    esac
}

function do_install() {
    print_heading "Installing toolbox"

    echo
    echo -e "Creating symlink: $(print_file_path "${BIN_LINK}" "${BIN}")"
    if [ "$(is_safe_to_override)" != true ]; then
        local EXISTING_BIN="$(get_existing_bin_print)"
        print_warning "Binary ${EXISTING_BIN} already exist. To override run: \e[33msetup -f\e[0m"
        echo
        print_error "Installation failed"
        exit 1
    fi

    mkdir -p "${BIN_DIR}"
    ln -sf "${BIN}" "${BIN_LINK}"

    echo "Creating symlink: $(print_file_path "${COMPLETION_LINK}" "${COMPLETION}")"
    mkdir -p "${COMPLETION_DIR}"
    ln -sf "${COMPLETION}" "${COMPLETION_LINK}"

    echo
    print_success "Installation complete"
    print_info "Remember to re-login for changes to be applied"
}

function do_uninstall() {
    print_heading "Uninstalling toolbox"

    echo
    echo -e "Removing symlink: $(print_file_path "${BIN_LINK}")"
    if [ "$(is_safe_to_override)" != true ]; then
        local EXISTING_BIN="$(get_existing_bin_print)"
        print_warning "Binary ${EXISTING_BIN} (potentially) is not related to toolbox. To force remove run: \e[33msetup uninstall -f\e[0m"
        echo
        print_error "Uninstallation failed"
        exit 1
    fi

    rm -f "${BIN_LINK}"

    echo -e "Removing symlink: $(print_file_path "${COMPLETION_LINK}")"
    rm -f "${COMPLETION_LINK}"

    echo
    print_success "Uninstallation complete"
}

function is_safe_to_override() {
    if [ -f "${BIN_LINK}" ] && [ ${IS_FORCE} != true ]; then
        local EXISTING_BIN_LINK=$(readlink -f "${BIN_LINK}")
        if [ "${BIN}" != "${EXISTING_BIN_LINK}" ]; then
            echo false
        fi
    fi

    echo true
}

function get_existing_bin_print() {
    local EXISTING_BIN_LINK=$(readlink -f "${BIN_LINK}")
    if [ "${BIN_LINK}" != "${EXISTING_BIN_LINK}" ]; then
        print_file_path "${BIN_LINK}" "${EXISTING_BIN_LINK}"
    else
        print_file_path "${BIN_LINK}"
    fi
}

function get_project_root_dir() {
    local SCRIPT=$(readlink -f "${0}")
    local DIR=$(dirname "${SCRIPT}")
    readlink -f "${DIR}/../.." || exit 1
}

function print_file_path() {
    local SYMLINK=$1
    local TARGET=$2

    if [ -z "${TARGET}" ]; then
        echo -e "\e[32m${SYMLINK}\e[0m"
    else
        echo -e "\e[36m${SYMLINK}\e[0m -> \e[32m${TARGET}\e[0m"
    fi
}

function print_heading() {
    local MESSAGE=$1
    echo -e "\e[1m#\e[0m ${MESSAGE}"
}

function print_warning() {
    local MESSAGE=$1
    echo -e "\e[1m\e[93mW\e[0m ${MESSAGE}"
}

function print_error() {
    local MESSAGE=$1
    echo -e "\e[1m\e[31mE\e[0m ${MESSAGE}"
}

function print_success() {
    local MESSAGE=$1
    echo -e "\e[1m\e[32mS\e[0m ${MESSAGE}"
}

function print_info() {
    local MESSAGE=$1
    echo -e "\e[1m\e[34mI\e[0m ${MESSAGE}"
}

function command_help() {
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  ip [options] [<action>]
  setup install -f

\e[33mArguments:\e[0m
  \e[32maction\e[0m      Action to perform. Available values: "install", "uninstall". \e[33m[default: install]\e[0m

\e[33mOptions:\e[0m
  \e[32m-f, --force\e[0m Perform action despite warning
  \e[32m-h, --help\e[0m  Display this help
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
