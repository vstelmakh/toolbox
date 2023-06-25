# shellcheck disable=SC2155,SC2207

_toolbox_completions() {
    case "${#COMP_WORDS[@]}" in
        1)
            return 0
            ;;
        2)
            local COMMANDS=$(toolbox --toolbox-completion)
            COMPREPLY=($(compgen -W "${COMMANDS}" "${COMP_WORDS[1]}"))
            ;;
        *)
            # TODO: take suggestions from corresponding command
            ;;
    esac
}

complete -F _toolbox_completions toolbox
