#!/bin/bash

REGION="ap-northeast-1"

echo "| トピック名 | トピックARN | サブスクリプション数 | プロトコル | エンドポイント | 備考 |"
echo "|------------|-------------|--------------------|-----------|--------------|------|"

TOPIC_ARNS=$(aws sns list-topics --region "$REGION" --query 'Topics[*].TopicArn' --output text)

for TOPIC_ARN in $TOPIC_ARNS; do
  TOPIC_NAME=$(echo "$TOPIC_ARN" | awk -F':' '{print $NF}')

  SUBSCRIPTIONS=$(aws sns list-subscriptions-by-topic --region "$REGION" --topic-arn "$TOPIC_ARN" --output json)
  SUB_COUNT=$(echo "$SUBSCRIPTIONS" | jq '.Subscriptions | length')

  if [[ "$SUB_COUNT" -eq 0 ]]; then
    echo "| $TOPIC_NAME | $TOPIC_ARN | 0 | - | - | |"
  else
    echo "$SUBSCRIPTIONS" | jq -c '.Subscriptions[]' | while read -r sub; do
      PROTOCOL=$(echo "$sub" | jq -r '.Protocol')
      ENDPOINT=$(echo "$sub" | jq -r '.Endpoint')
      echo "| $TOPIC_NAME | $TOPIC_ARN | $SUB_COUNT | $PROTOCOL | $ENDPOINT | |"
    done
  fi
done

