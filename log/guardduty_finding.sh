#!/bin/bash

REGION="ap-northeast-1"

DETECTOR_ID=$(aws guardduty list-detectors --region "$REGION" --query 'DetectorIds[0]' --output text)

if [[ "$DETECTOR_ID" == "None" || -z "$DETECTOR_ID" ]]; then
  echo "GuardDuty が有効化されていません。"
  exit 1
fi

echo "| 検出ID | タイトル | 種別 | 検出日 | 深刻度 | リソースタイプ | 状態 | 備考 |"
echo "|--------|----------|------|--------|--------|----------------|------|------|"

FINDINGS=$(aws guardduty list-findings \
  --region "$REGION" \
  --detector-id "$DETECTOR_ID" \
  --max-results 50 \
  --query 'FindingIds' \
  --output json)

DETAILS=$(aws guardduty get-findings \
  --region "$REGION" \
  --detector-id "$DETECTOR_ID" \
  --finding-ids "$FINDINGS" \
  --output json)

echo "$DETAILS" | jq -c '.Findings[]' | while read -r finding; do
  ID=$(echo "$finding" | jq -r '.Id')
  TITLE=$(echo "$finding" | jq -r '.Title')
  TYPE=$(echo "$finding" | jq -r '.Type')
  TIME=$(echo "$finding" | jq -r '.UpdatedAt')
  SEVERITY=$(echo "$finding" | jq -r '.Severity')
  RESOURCE_TYPE=$(echo "$finding" | jq -r '.Resource.ResourceType')
  STATUS=$(echo "$finding" | jq -r '.Service.Status')

  echo "| $ID | $TITLE | $TYPE | $TIME | $SEVERITY | $RESOURCE_TYPE | $STATUS | |"
done

