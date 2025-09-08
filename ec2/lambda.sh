#!/bin/bash


REGION="ap-northeast-1"

echo "| 関数名 | タイムアウト(s) | メモリ(MB) | 最終更新日 | ランタイム | ロール | トリガー | VPC接続 | バージョン | レイヤー | 環境変数に機密？ | 備考 |"
echo "|--------|------------------|------------|--------------|------------|--------|----------|----------|------------|----------|------------------|------|"

FUNCTIONS=$(aws lambda list-functions --region $REGION --query 'Functions[*].FunctionName' --output text)

for FUNCTION in $FUNCTIONS; do
  CONFIG=$(aws lambda get-function-configuration --function-name "$FUNCTION" --region $REGION)

  TIMEOUT=$(echo "$CONFIG" | jq -r '.Timeout')
  MEMORY=$(echo "$CONFIG" | jq -r '.MemorySize')
  UPDATED=$(echo "$CONFIG" | jq -r '.LastModified')
  RUNTIME=$(echo "$CONFIG" | jq -r '.Runtime')
  ROLE=$(echo "$CONFIG" | jq -r '.Role' | awk -F'/' '{print $NF}')
  VERSION=$(echo "$CONFIG" | jq -r '.Version')
  VPC=$(echo "$CONFIG" | jq -r '.VpcConfig.VpcId // empty')
  VPC_STATUS="NG"
  [[ -n "$VPC" ]] && VPC_STATUS="OK"

  LAYERS=$(echo "$CONFIG" | jq -r '.Layers | map(.Arn) | join(", ") // ""')
  [[ -z "$LAYERS" ]] && LAYERS="なし"

  SECRETS=$(echo "$CONFIG" | jq -r '.Environment.Variables // {}' | grep -iE 'secret|token|key|AKIA|password')
  SECRET_FLAG=""

  [[ -n "$SECRETS" ]] && SECRET_FLAG="⚠️"

  TRIGGERS=$(aws lambda list-event-source-mappings --function-name "$FUNCTION" --region $REGION --query 'EventSourceMappings[*].EventSourceArn' --output text)
  [[ -z "$TRIGGERS" ]] && TRIGGERS="（手動またはAPI Gateway等）"

  echo "| $FUNCTION | $TIMEOUT | $MEMORY | $UPDATED | $RUNTIME | $ROLE | $TRIGGERS | $VPC_STATUS | $VERSION | $LAYERS | $SECRET_FLAG | |"

done
