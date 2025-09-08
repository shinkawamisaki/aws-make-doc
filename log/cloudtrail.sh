#!/bin/bash

REGION="ap-northeast-1"

echo "| トレイル名 | S3バケット | 暗号化(KMS) | CloudWatch連携 | マルチリージョン | 組織トレイル | 状態 | 備考 |"
echo "|------------|-------------|---------------|------------------|------------------|----------------|--------|------|"

TRAILS=$(aws cloudtrail describe-trails --region "$REGION" --query 'trailList[*]' --output json)

echo "$TRAILS" | jq -c '.[]' | while read -r TRAIL; do
  NAME=$(echo "$TRAIL" | jq -r '.Name')
  S3_BUCKET=$(echo "$TRAIL" | jq -r '.S3BucketName')
  IS_MULTI=$(echo "$TRAIL" | jq -r '.IsMultiRegionTrail')
  IS_ORG=$(echo "$TRAIL" | jq -r '.IsOrganizationTrail')
  CLOUDWATCH=$(echo "$TRAIL" | jq -r '.CloudWatchLogsLogGroupArn // "なし"')
  KMS_KEY=$(echo "$TRAIL" | jq -r '.KmsKeyId // "なし"')

  [[ "$IS_MULTI" == "true" ]] && MULTI="OK" || MULTI="NG"
  [[ "$IS_ORG" == "true" ]] && ORG="OK" || ORG="NG"
  [[ "$CLOUDWATCH" != "なし" ]] && CW="OK" || CW="NG"
  [[ "$KMS_KEY" != "なし" ]] && ENC="OK" || ENC="NG"

  STATUS=$(aws cloudtrail get-trail-status --name "$NAME" --region "$REGION")
  IS_LOGGING=$(echo "$STATUS" | jq -r '.IsLogging')
  [[ "$IS_LOGGING" == "true" ]] && STATE="🟢有効" || STATE="🔴無効"

  echo "| $NAME | $S3_BUCKET | $ENC | $CW | $MULTI | $ORG | $STATE | |"

done
