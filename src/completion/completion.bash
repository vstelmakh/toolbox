# shellcheck disable=SC2155,SC2207

_toolbox_completions() {
    case "${#COMP_WORDS[@]}" in
        1)
            return 0
            ;;
        2)
            local COMPLETION=$(toolbox --toolbox-completion)
            COMPREPLY=($(compgen -W "${COMPLETION}" "${COMP_WORDS[1]}"))
            return 0
            ;;
        *)
            local COMPLETION=$(toolbox "${COMP_WORDS[1]}" --toolbox-completion "${COMP_WORDS[@]:2}")
            COMPREPLY=($(compgen -W "${COMPLETION}" \""${COMP_WORDS[-1]}"\"))
            return 0
            ;;
    esac
}

complete -F _toolbox_completions toolbox
