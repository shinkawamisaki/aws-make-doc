#!/bin/bash

REGION="ap-northeast-1"

echo "| クラスター名 | サービス名 | タスク定義 | コンテナ名 | イメージ | CPU | メモリ | タスク数 | 起動タイプ |"
echo "|--------------|-------------|------------|------------|--------|-----|--------|----------|-------------|"

CLUSTERS=$(aws ecs list-clusters --region "$REGION" --query 'clusterArns[*]' --output text)

for CLUSTER_ARN in $CLUSTERS; do
  CLUSTER_NAME=$(basename "$CLUSTER_ARN")

  SERVICES=$(aws ecs list-services --cluster "$CLUSTER_NAME" --region "$REGION" --query 'serviceArns[*]' --output text)

  for SERVICE_ARN in $SERVICES; do
    SERVICE_NAME=$(basename "$SERVICE_ARN")

    SERVICE_DETAIL=$(aws ecs describe-services \
      --cluster "$CLUSTER_NAME" \
      --services "$SERVICE_NAME" \
      --region "$REGION" \
      --query 'services[0]' \
      --output json)

    TASK_DEF_ARN=$(echo "$SERVICE_DETAIL" | jq -r '.taskDefinition')
    DESIRED_COUNT=$(echo "$SERVICE_DETAIL" | jq -r '.desiredCount')
    LAUNCH_TYPE=$(echo "$SERVICE_DETAIL" | jq -r '.launchType // empty')

    if [[ -z "$LAUNCH_TYPE" || "$LAUNCH_TYPE" == "null" ]]; then
      LAUNCH_TYPE=$(echo "$SERVICE_DETAIL" | jq -r '.capacityProviderStrategy[0].capacityProvider // "UNKNOWN"')
    fi

    TASK_DEF=$(aws ecs describe-task-definition \
      --task-definition "$TASK_DEF_ARN" \
      --region "$REGION" \
      --query 'taskDefinition' \
      --output json)

    TASK_DEF_NAME=$(basename "$TASK_DEF_ARN")

    CONTAINERS=$(echo "$TASK_DEF" | jq -c '.containerDefinitions[]')
    for CONTAINER in $CONTAINERS; do
      CONTAINER_NAME=$(echo "$CONTAINER" | jq -r '.name')
      IMAGE=$(echo "$CONTAINER" | jq -r '.image')
      CPU=$(echo "$CONTAINER" | jq -r '.cpu')
      MEMORY=$(echo "$CONTAINER" | jq -r '.memory')

      echo "| $CLUSTER_NAME | $SERVICE_NAME | $TASK_DEF_NAME | $CONTAINER_NAME | $IMAGE | $CPU | $MEMORY | $DESIRED_COUNT | $LAUNCH_TYPE |"
    done
  done
done

