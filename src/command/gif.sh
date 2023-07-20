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
    echo "Convert input video to gif"
}

function command_completion() {
    case "${#@}" in
        1)
            [[ ${1} = "--"* ]] && echo "--duration --fps --help --loglevel --loop --pause --skip --width" && exit
            [[ ${1} = "-"* ]] && echo "-d -f -h -l -p -s -w" && exit

            echo ""
            ;;
    esac
}

# https://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality
# http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
function command_execute() {
    local LOG_LEVEL="warning"
    local SKIP_SEC="0"
    local DURATION_SEC="3600"
    local FPS="24"
    local WIDTH_PX="0"
    local LOOP="0"
    local FINAL_DELAY_MS="0"

    local ARGUMENTS=()
    while [[ "$#" -gt 0 ]]; do
        case "${1}" in
            --loglevel)
                LOG_LEVEL="${2}"
                shift
                ;;
            -s|--skip)
                SKIP_SEC="${2}"
                shift
                ;;
            -d|--duration)
                DURATION_SEC="${2}"
                shift
                ;;
            -f|--fps)
                FPS="${2}"
                shift
                ;;
            -w|--width)
                WIDTH_PX="${2}"
                shift
                ;;
            -l|--loop)
                LOOP="${2}"
                shift
                ;;
            -p|--pause)
                FINAL_DELAY_MS="${2}"
                shift
                ;;
            *)
                ARGUMENTS=("${ARGUMENTS[@]}" "${1}")
                ;;
        esac
        shift
    done

    local INPUT="${ARGUMENTS[0]}"
    local OUTPUT="${ARGUMENTS[1]}"
    if [ -z "${OUTPUT}" ]; then
        OUTPUT="$(echo "${INPUT}" | sed -E "s/\..+$//g").gif"
    fi

    ffmpeg -hide_banner \
        -loglevel "${LOG_LEVEL}" \
        -i "${INPUT}" \
        -ss "${SKIP_SEC}" \
        -t "${DURATION_SEC}" \
        -vf "fps=${FPS},scale=${WIDTH_PX}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
        -loop "${LOOP}" \
        -final_delay "${FINAL_DELAY_MS}" \
        "${OUTPUT}" \
    && echo -e "Conversion complete" \
    && echo -e "Result saved as: \e[36m$(readlink -f "${OUTPUT}")\e[0m"
}

function command_help() {
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  gif [options] <input> [<output>]
  gif /path/to/video.mp4

\e[33mArguments:\e[0m
  \e[32minput\e[0m           Input video file path
  \e[32moutput\e[0m          Output gif file path

\e[33mOptions:\e[0m
  \e[32m-d, --duration\e[0m  Max duration N seconds. \e[33m[default: 3600]\e[0m
  \e[32m-f, --fps\e[0m       Frames per second. \e[33m[default: 24]\e[0m
  \e[32m-h, --help\e[0m      Display this help
  \e[32m--loglevel\e[0m      Output verbosity level. Available values: "info", "warning", "error". \e[33m[default: warning]\e[0m
  \e[32m-l, --loop\e[0m      Value of 0 is infinite looping, -1 is no looping, and 1 will loop once meaning it will play twice. \e[33m[default: 0]\e[0m
  \e[32m-p, --pause\e[0m     Delay (in ms) after last frame (each iteration). \e[33m[default: 0]\e[0m
  \e[32m-s, --skip\e[0m      Skip first N seconds. \e[33m[default: 0]\e[0m
  \e[32m-w, --width\e[0m     Resize the output to N px width. 0 - keep the original size, -1 keep proportion to height. \e[33m[default: 0]\e[0m
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
