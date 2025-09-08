#!/bin/bash

REGION="ap-northeast-1"

echo "| 検出ID | タイトル | 深刻度 | ステータス | リソースタイプ | リソースID | 最終更新日 |"
echo "|--------|----------|--------|------------|----------------|-------------|--------------|"

FINDING_ARNS=$(aws inspector2 list-findings \
  --region "$REGION" \
  --max-results 50 \
  --query 'findings[*].findingArn' \
  --output text)

if [[ -z "$FINDING_ARNS" ]]; then
  echo "| - | - | - | - | - | - | - |"
else
  for ARN in $FINDING_ARNS; do
    FINDING=$(aws inspector2 get-findings \
      --region "$REGION" \
      --finding-arns "$ARN" \
      --query 'findings[0]' \
      --output json)

    ID=$(echo "$FINDING" | jq -r '.findingArn' | awk -F'/' '{print $NF}')
    TITLE=$(echo "$FINDING" | jq -r '.title')
    SEVERITY=$(echo "$FINDING" | jq -r '.severity')
    STATUS=$(echo "$FINDING" | jq -r '.status')
    RESOURCE_TYPE=$(echo "$FINDING" | jq -r '.resources[0].type')
    RESOURCE_ID=$(echo "$FINDING" | jq -r '.resources[0].id')
    UPDATED=$(echo "$FINDING" | jq -r '.updatedAt')

    echo "| $ID | $TITLE | $SEVERITY | $STATUS | $RESOURCE_TYPE | $RESOURCE_ID | $UPDATED |"
  done
fi

