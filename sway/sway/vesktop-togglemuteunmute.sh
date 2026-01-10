#!/bin/bash

DISCORD_IDS=("dev.vencord.Vesktop" "io.github.equicord.equibop")

APP_ID_SELECTORS="("
for i in "${!DISCORD_IDS[@]}"; do
  APP_ID_SELECTORS+=".info.props.\"pipewire.access.portal.app_id\" == \"${DISCORD_IDS[$i]}\""
  if [[ $i -lt $((${#DISCORD_IDS[@]} - 1)) ]]; then
    APP_ID_SELECTORS+=" or "
  else
    APP_ID_SELECTORS+=")"
  fi
done

STREAM_IDS=($(pw-dump | jq ".[] | select(${APP_ID_SELECTORS} and .info.props.\"media.name\" == \"RecordStream\" and .info.props.\"target.object\" != \"vencord-screen-share\") | .id"))

if [[ ${#STREAM_IDS[@]} -eq 0 || -z "${STREAM_IDS[0]}" ]]; then
  exit 0
fi

STATE=$(pw-cli enum-params "${STREAM_IDS[0]}" Props | awk '/Prop: key.*mute/{getline; print $2}')

for STREAM_ID in "${STREAM_IDS[@]}"; do
  if [[ "$STATE" == "true" ]]; then
    pw-cli set-param "$STREAM_ID" Props "{mute: false}" >/dev/null
  else
    pw-cli set-param "$STREAM_ID" Props "{mute: true}" >/dev/null
  fi
done

if [[ "$STATE" == "true" ]]; then
  notify-send -i microphone-sensitivity-high -a "Discord" "Microphone" "Enabled"
else
  notify-send -i microphone-sensitivity-muted -a "Discord" "Microphone" "Muted"
fi
