#!/bin/bash

REGION="ap-northeast-1"

echo "| アラーム名 | メトリクス名 | 名前空間 | 閾値 | 比較演算子 | 状態 | 対象リソース | アクション先 | 備考 |"
echo "|-------------|--------------|-----------|-------|---------------|--------|----------------|---------------|------|"

ALARMS=$(aws cloudwatch describe-alarms --region "$REGION" --query 'MetricAlarms' --output json)

echo "$ALARMS" | jq -c '.[]' | while read -r alarm; do
  NAME=$(echo "$alarm" | jq -r '.AlarmName')
  METRIC=$(echo "$alarm" | jq -r '.MetricName')
  NAMESPACE=$(echo "$alarm" | jq -r '.Namespace')
  THRESHOLD=$(echo "$alarm" | jq -r '.Threshold')
  OPERATOR=$(echo "$alarm" | jq -r '.ComparisonOperator')
  STATE=$(echo "$alarm" | jq -r '.StateValue')
  
  DIMENSIONS=$(echo "$alarm" | jq -r '.Dimensions[]? | "\(.Name)=\(.Value)"' | paste -sd "," -)
  DIMENSIONS=${DIMENSIONS:-"-"}

  ACTIONS=$(echo "$alarm" | jq -r '.AlarmActions[]?' | paste -sd "," -)
  ACTIONS=${ACTIONS:-"-"}

  echo "| $NAME | $METRIC | $NAMESPACE | $THRESHOLD | $OPERATOR | $STATE | $DIMENSIONS | $ACTIONS | |"
done

