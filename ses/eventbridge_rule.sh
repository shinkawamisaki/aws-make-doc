#!/bin/bash

REGION="ap-northeast-1"

echo "| ルール名 | イベントバス | 状態 | スケジュール式 | ターゲット数 | 備考 |"
echo "|----------|--------------|------|----------------|---------------|------|"

RULES=$(aws events list-rules --region "$REGION" --output json)

echo "$RULES" | jq -c '.Rules[]' | while read -r rule; do
  NAME=$(echo "$rule" | jq -r '.Name')
  BUS=$(echo "$rule" | jq -r '.EventBusName')
  STATE=$(echo "$rule" | jq -r '.State')
  SCHEDULE=$(echo "$rule" | jq -r '.ScheduleExpression // "-"')

  TARGETS=$(aws events list-targets-by-rule --region "$REGION" --rule "$NAME" --event-bus-name "$BUS" --output json)
  TARGET_COUNT=$(echo "$TARGETS" | jq '.Targets | length')

  echo "| $NAME | $BUS | $STATE | $SCHEDULE | $TARGET_COUNT | |"
done

