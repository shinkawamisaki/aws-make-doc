#!/bin/bash

REGION="ap-northeast-1"

echo "| バケット名 | リージョン | サーバーサイド暗号化 | 公開ブロック（全設定） | 備考 |"
echo "|------------|------------|----------------------|-------------------------|------|"

BUCKETS_JSON=$(aws s3api list-buckets --output json)
BUCKET_NAMES=$(echo "$BUCKETS_JSON" | jq -r '.Buckets[].Name')

for BUCKET in $BUCKET_NAMES; do
  LOCATION=$(aws s3api get-bucket-location --bucket "$BUCKET" --output text)
  [[ "$LOCATION" == "None" ]] && LOCATION="us-east-1"

  ENCRYPTION=$(aws s3api get-bucket-encryption --bucket "$BUCKET" --region "$REGION" 2>/dev/null \
    | jq -r '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' 2>/dev/null)
  [[ -z "$ENCRYPTION" ]] && ENCRYPTION="NG 無効"

  BLOCK_PUBLIC=$(aws s3api get-bucket-policy-status --bucket "$BUCKET" --region "$REGION" 2>/dev/null \
    | jq -r '.PolicyStatus.IsPublic')
  [[ "$BLOCK_PUBLIC" == "true" ]] && BLOCK_STATUS="NG 公開" || BLOCK_STATUS="OK 非公開"

  echo "| $BUCKET | $LOCATION | $ENCRYPTION | $BLOCK_STATUS | |"
done

