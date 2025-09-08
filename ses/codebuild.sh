#!/bin/bash

REGION="ap-northeast-1"

echo "| プロジェクト名 | ソースタイプ | 最終ビルド日 | ビルド状態 | 環境タイプ | イメージ | タイムアウト | アーティファクト | 備考 |"
echo "|----------------|--------------|--------------|------------|-------------|----------|--------------|----------------|------|"

PROJECTS=$(aws codebuild list-projects --region "$REGION" --query 'projects' --output text)

for PROJECT in $PROJECTS; do
  CONFIG=$(aws codebuild batch-get-projects --region "$REGION" --names "$PROJECT" | jq -r '.projects[0]')

  SOURCE_TYPE=$(echo "$CONFIG" | jq -r '.source.type')
  ENV_TYPE=$(echo "$CONFIG" | jq -r '.environment.type')
  IMAGE=$(echo "$CONFIG" | jq -r '.environment.image')
  TIMEOUT=$(echo "$CONFIG" | jq -r '.timeoutInMinutes')
  ARTIFACTS=$(echo "$CONFIG" | jq -r '.artifacts.type')

  LAST_BUILD_ID=$(aws codebuild list-builds-for-project --project-name "$PROJECT" --region "$REGION" \
    --query 'ids[0]' --output text)

  if [[ "$LAST_BUILD_ID" != "None" && -n "$LAST_BUILD_ID" ]]; then
    BUILD_INFO=$(aws codebuild batch-get-builds --ids "$LAST_BUILD_ID" --region "$REGION" | jq -r '.builds[0]')
    LAST_BUILD_DATE=$(echo "$BUILD_INFO" | jq -r '.startTime')
    BUILD_STATUS=$(echo "$BUILD_INFO" | jq -r '.buildStatus')
  else
    LAST_BUILD_DATE="なし"
    BUILD_STATUS="未実行"
  fi

  echo "| $PROJECT | $SOURCE_TYPE | $LAST_BUILD_DATE | $BUILD_STATUS | $ENV_TYPE | $IMAGE | ${TIMEOUT}分 | $ARTIFACTS | |"
done

