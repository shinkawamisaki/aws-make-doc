#!/bin/bash

REGION="ap-northeast-1"

echo "| バケット名 | リージョン | 作成日 | パブリックアクセス | バージョニング | 暗号化 | 備考 |"
echo "|------------|------------|--------|---------------------|----------------|--------|------|"

BUCKETS_JSON=$(aws s3api list-buckets)
BUCKET_NAMES=$(echo "$BUCKETS_JSON" | jq -r '.Buckets[].Name')

for BUCKET in $BUCKET_NAMES; do
  CREATED=$(echo "$BUCKETS_JSON" | jq -r ".Buckets[] | select(.Name==\"$BUCKET\") | .CreationDate")

  LOCATION=$(aws s3api get-bucket-location --bucket "$BUCKET" --output text 2>/dev/null)
  [ "$LOCATION" == "None" ] && LOCATION="us-east-1"
  [ -z "$LOCATION" ] && LOCATION="取得不可"

  PUBLIC_STATUS=$(aws s3api get-bucket-policy-status --bucket "$BUCKET" 2>/dev/null \
    | jq -r '.PolicyStatus.IsPublic // "false"')
  PUBLIC="NG"
  [ "$PUBLIC_STATUS" == "true" ] && PUBLIC="⚠️"

  VERSIONING=$(aws s3api get-bucket-versioning --bucket "$BUCKET" 2>/dev/null \
    | jq -r '.Status // "無効"')
  [ -z "$VERSIONING" ] && VERSIONING="無効"

  ENCRYPTION=$(aws s3api get-bucket-encryption --bucket "$BUCKET" 2>/dev/null \
    | jq -r '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' 2>/dev/null)
  [ -z "$ENCRYPTION" ] && ENCRYPTION="なし"

  NOTE=""
  if [[ "$LOCATION" == "取得不可" ]]; then NOTE="リージョン取得失敗"; fi

  echo "| $BUCKET | $LOCATION | $CREATED | $PUBLIC | $VERSIONING | $ENCRYPTION | $NOTE |"

done
