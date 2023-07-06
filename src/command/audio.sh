#!/bin/bash
# shellcheck disable=SC2155

# Configuration
# Use "bluetoothctl paired-devices" to check for bluetooth mac address. Device should be paired already.
# Value example: 00:00:00:00:00:00
BLUETOOTH_DEVICE_MAC="${CONFIG_AUDIO_BLUETOOTH_DEVICE_MAC}"
# Value example: 00_00_00_00_00_00
BLUETOOTH_DEVICE_MAC_UNDERSCORE="$(echo "${CONFIG_AUDIO_BLUETOOTH_DEVICE_MAC}" | sed -E "s/:/_/g")"

# Use "pactl list cards" or "pactl list cards short" to check for audio cards devices names.
# To check if your card supports "handsfree head unit (HFP)" profile use "pactl list cards" and check for "profile" section.
CARD_HEADPHONES_NAME="bluez_card.${BLUETOOTH_DEVICE_MAC_UNDERSCORE}"

# Use "pactl list sinks" or "pactl list sinks short" to check for audio output devices names.
SINK_HEADPHONES_NAME="bluez_sink.${BLUETOOTH_DEVICE_MAC_UNDERSCORE}.a2dp_sink"
SINK_HEADSET_NAME="bluez_sink.${BLUETOOTH_DEVICE_MAC_UNDERSCORE}.handsfree_head_unit"
# Value example: alsa_output.pci-0000_00_00.0.analog-stereo
SINK_BUILTIN_NAME="${CONFIG_AUDIO_SINK_BUILTIN_NAME}"

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
    echo "Switch system audio output"
}

function command_completion() {
    case "${#@}" in
        1)
            [[ ${1} = "--"* ]] && echo "--help" && exit
            [[ ${1} = "-"* ]] && echo "-h" && exit

            echo "builtin headphones headset reconnect"
            ;;
    esac
}

function command_execute() {
    case "${1}" in
        "headphones")
            switch_to_headphones
            ;;
        "headset")
            switch_to_headset
            ;;
        "builtin")
            switch_to_builtin
            ;;
        "reconnect")
            reconnect_bluetooth_device
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

function switch_to_headphones() {
    echo -e "Switching audio output to bluetooth \e[32mheadphones\e[0m"
    connect_bluetooth_device
    set_card_profile "a2dp_sink"
    set_audio_output ${SINK_HEADPHONES_NAME}
}

function switch_to_headset() {
    echo -e "Switching audio output to bluetooth \e[32mheadset\e[0m"
    connect_bluetooth_device
    set_card_profile "handsfree_head_unit"
    set_audio_output ${SINK_HEADSET_NAME}
}

function switch_to_builtin() {
    echo -e "Switching audio output to \e[32mbuiltin\e[0m"
    set_audio_output ${SINK_BUILTIN_NAME}
}

# Sometimes on headphones mode volume is too low, while reconnect solves an issue
function reconnect_bluetooth_device() {
    disconnect_bluetooth_device
    connect_bluetooth_device
}

function connect_bluetooth_device() {
    echo -en "Connecting bluetooth device \e[33m${BLUETOOTH_DEVICE_MAC}\e[0m"

    local OUTPUT;
    if bluetoothctl info ${BLUETOOTH_DEVICE_MAC} | grep -q "Connected: no"; then
        OUTPUT=$(bluetoothctl connect ${BLUETOOTH_DEVICE_MAC} 2>&1) && echo " [OK]" \
            || { echo " [ERROR]"; echo ${OUTPUT}; exit 1; }
    else
        echo " [OK]"
    fi
}

function disconnect_bluetooth_device() {
    echo -en "Disconnecting bluetooth device \e[33m${BLUETOOTH_DEVICE_MAC}\e[0m"

    local OUTPUT;
    if bluetoothctl info ${BLUETOOTH_DEVICE_MAC} | grep -q "Connected: yes"; then
        OUTPUT=$(bluetoothctl disconnect ${BLUETOOTH_DEVICE_MAC} 2>&1) && echo " [OK]" \
            || { echo " [ERROR]"; echo ${OUTPUT}; exit 1; }
    else
        echo " [OK]"
    fi
}

function set_card_profile() {
    local CARD_PROFILE=${1}
    echo -en "Setting audio card profile to \e[33m${CARD_PROFILE}\e[0m"

    local ATTEMPTS=30
    local OUTPUT;
    until [[ ${ATTEMPTS} -eq 0 ]] || OUTPUT=$(pactl set-card-profile ${CARD_HEADPHONES_NAME} ${CARD_PROFILE} 2>&1); do
        sleep 1
        ATTEMPTS=$((ATTEMPTS - 1))
        echo -n "."
    done

    if [[ ${ATTEMPTS} -eq 0 ]]; then
        echo " [ERROR]"
        echo ${OUTPUT}
        exit 1
    fi

    echo " [OK]"
}

function set_audio_output() {
    local SINK_NAME=${1}
    echo -en "Setting audio sink to \e[33m${SINK_NAME}\e[0m"

    local ATTEMPTS=30
    until [[ ${ATTEMPTS} -eq 0 ]] || pactl list sinks short | grep -q ${SINK_NAME}; do
        sleep 1
        ATTEMPTS=$((ATTEMPTS - 1))
        echo -n "."
    done

    if [[ ${ATTEMPTS} -eq 0 ]]; then
        echo " [ERROR]"
        echo "Audio sink \"${SINK_NAME}\" not available"
        exit 1
    fi

    pactl set-default-sink ${SINK_NAME} && echo " [OK]"
}

function command_help() {
    local TEXT=$(cat << HEREDOC
\e[33mDescription:\e[0m
  $(command_description)

\e[33mUsage:\e[0m
  audio [options] <action>
  audio headset

\e[33mArguments:\e[0m
  \e[32maction\e[0m      Audio chanel to select / action to perform. Available values: "builtin", "headphones", "headset", "reconnect".

\e[33mOptions:\e[0m
  \e[32m-h, --help\e[0m  Display this help

\e[33mHelp:\e[0m
  Remember to configure config parameters to correspond your hardware.

  Hint. Add custom keyboard shortcuts to quickly switch audio output.
  See: \e[33mSettings - \e[33mKeyboard - \e[33mCustomize Shortcuts - \e[33mCustom Shortcuts\e[0m

  Definition suggestions:
    \e[32mtoolbox audio\e[0m \e[36mheadphones\e[0m : Ctrl + Super + H
    \e[32mtoolbox audio\e[0m \e[36mheadset\e[0m    : Ctrl + Super + T
    \e[32mtoolbox audio\e[0m \e[36mbuiltin\e[0m    : Ctrl + Super + B
    \e[32mtoolbox audio\e[0m \e[36mreconnect\e[0m  : Ctrl + Super + Alt + R
HEREDOC
)
    echo -e "${TEXT}"
}

main "$@"
