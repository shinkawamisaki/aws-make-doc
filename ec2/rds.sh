#!/bin/bash

REGION="ap-northeast-1"

echo "| DB識別子 | エンジン | エンジンバージョン | ステータス | マルチAZ | ストレージタイプ | 暗号化 | VPC | パブリックアクセス | 備考 |"
echo "|-----------|---------|-------------------|-----------|----------|----------------|--------|-----|------------------|------|"

aws rds describe-db-instances --region "$REGION" --query 'DBInstances[*]' --output json | jq -c '.[]' | while read -r db; do
  IDENTIFIER=$(echo "$db" | jq -r '.DBInstanceIdentifier')
  ENGINE=$(echo "$db" | jq -r '.Engine')
  VERSION=$(echo "$db" | jq -r '.EngineVersion')
  STATUS=$(echo "$db" | jq -r '.DBInstanceStatus')
  MULTI_AZ=$(echo "$db" | jq -r '.MultiAZ')
  STORAGE_TYPE=$(echo "$db" | jq -r '.StorageType')
  ENCRYPTED=$(echo "$db" | jq -r '.StorageEncrypted')
  VPC=$(echo "$db" | jq -r '.DBSubnetGroup.VpcId')
  PUBLIC_ACCESS=$(echo "$db" | jq -r '.PubliclyAccessible')

  MULTI_AZ_ICON="NG"
  [[ "$MULTI_AZ" == "true" ]] && MULTI_AZ_ICON="OK"

  ENC_ICON="NG"
  [[ "$ENCRYPTED" == "true" ]] && ENC_ICON="OK"

  PUB_ICON="NG"
  [[ "$PUBLIC_ACCESS" == "true" ]] && PUB_ICON="OK"

  echo "| $IDENTIFIER | $ENGINE | $VERSION | $STATUS | $MULTI_AZ_ICON | $STORAGE_TYPE | $ENC_ICON | $VPC | $PUB_ICON | |"
done

