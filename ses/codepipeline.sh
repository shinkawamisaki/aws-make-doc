#!/bin/bash

REGION="ap-northeast-1"

echo "| パイプライン名 | 状態 | 作成日 | 最終更新日 | ステージ数 | 備考 |"
echo "|----------------|------|--------|--------------|-------------|------|"

PIPELINES=$(aws codepipeline list-pipelines --region "$REGION" --query 'pipelines[*].name' --output text)

for PIPELINE in $PIPELINES; do
  DETAIL=$(aws codepipeline get-pipeline --name "$PIPELINE" --region "$REGION")
  STATE=$(aws codepipeline get-pipeline-state --name "$PIPELINE" --region "$REGION" \
    | jq -r '.stageStates[].latestExecution.status' | sort | uniq | paste -sd "," -)

  CREATED=$(echo "$DETAIL" | jq -r '.metadata.created')
  UPDATED=$(echo "$DETAIL" | jq -r '.metadata.updated')
  STAGE_COUNT=$(echo "$DETAIL" | jq -r '.pipeline.stages | length')

  echo "| $PIPELINE | $STATE | $CREATED | $UPDATED | $STAGE_COUNT | |"
done

